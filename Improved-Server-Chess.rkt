;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Improved-Server-Chess) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/tcp)
(require racket/base)
(require "logic.rkt")
(require racket/udp)
(provide start-server)

;;;;;;;;;; CODE FOR THE SERVER ;;;;;;;;;;;;;

;; DATA TYPE DEFINITIONS ;;

; a Move is a List<Posn>: (list (make-posn before-column before-row) (make-posn after-column after-row))

; Examples

(define WHITE-PAWN-E4 (list (make-posn 4 6) (make-posn 4 4)))
(define BLACK-BISHOP-C4 (list (make-posn 5 0) (make-posn 2 4)))

; a Port is one of:
; - #false, if it's closed
; - a Number, if it's open

; a Color is a String and is one of:
; - "White"
; - "Black"
; color of the player's pieces

; a Connection is a Structure (make-connection server-input server-output color) where:
; - server-input: Port, the server receives the data when Number
; - server-output: Port, the server sends the data when Number
; - color: Color
; interpretation: the connection of a player to the server
(define-struct connection [server-input server-output color] #:transparent)

; Examples

(define C1 (make-connection 23 27 "White"))
(define C2 (make-connection 109 228 "Black"))

;; PLAYERS BEFORE CONNECTING ;;

(define initial-white-connection (make-connection #false #false "White"))
(define initial-black-connection (make-connection #false #false "Black"))

;; OBTAINING THE IP ADDRESS ;;

;; obtain-ip: -> String
; obtains the IP address of the server
; header: (define (obtain-ip) "")

;; Template

; (define (obtain-ip)
;  (... with-handlers ...
;       (begin
;         (... udp-connect! ...)
;         (... udp-close ...))))

(define (obtain-ip)
  (let ((socket (udp-open-socket))) ; `udp-open-socket`: returns a socket that connects and sends data
    (with-handlers ; `with-handlers`: built-in function for handling exceptions, that in this case are network errors
        ((exn:fail:network? ; `exn:fail:network?`: checks if an exception is related to the network
          (lambda (exception)
            "127.0.0.1"))) ; if so, it returns the localhost (127.0.0.1)
      (begin
        (udp-connect! socket "8.8.8.8" 53) ; `udp-connect!`: connects the socket to the ip address and the port
                                           ; 8.8.8.8 and 53: IP address and port used by DNS, specifically 8.8.8.8 referers to Google's DNS
                                           ; and it allows us to obtain the IP address of the computer
        (let-values (((local-ip local-port remote-ip remote-port) (udp-addresses socket #true))) ; `udp-addresses`: with #true, it returns the address and the port of the local machine
                                                                                                 ; and the address and the port of the remote machine,
                                                                                                 ; if the port is closed, it raises `exn:fail:network`
          (udp-close socket) ; `udp-close`: closes the socket
          local-ip)))))

;; CONNECTION MANAGEMENT ;;

;; connection-management: Port Port Color -> Connection
; manages the player's connection by informing that they connected and outputting the ports and giving a color to the player who connected
; header: (define (connection-management server-input server-output color) (make-connection #false #false "White"))

;; Template

; (define (connection-management server-input server-output color)
;    (... color ... server-output ...)
;    (... server-input ... server-output ... color ...))

(define (connection-management server-input server-output color)
    (displayln (string-append color " is connected")) ; `displayln`: "White is connected" or "Black is connected"
  (write color server-output) ; sends player's color to the client
  (flush-output server-output)
    (make-connection server-input server-output color))

;; Examples

(check-expect (connection-management 1001 2000 "White") (make-connection 1001 2000 "White"))
(check-expect (connection-management 5878 1999 "Black") (make-connection 5878 1999 "Black"))

;; PLAYER'S CONNECTION ;;

;; player-connection: TCP listener Color -> Connection
; accepts the connection of a player
; header: (define (player-connection listener color) (make-connection #false #false "White"))

;; Template

; (define (player-connection listener color)
;  (... listener ... color ...))

(define (player-connection listener color)
  (define-values (server-input server-output) (tcp-accept listener)) ; `define-values`: allocates the values of the multiple outputs of a function (`tcp-accept`) to
                                                                     ; different variables (`server-input`, `server-output`), one for each value. In this case the outputs are the input and output ports
                                                                     ; `tcp-accept`: accepts client's connection request
  (connection-management server-input server-output color))

;; RECEIVING PLAYER'S MOVES ;;

;; receive-move: Connection Color -> Any
; receives the player's moves
; header: (define (receive-move connection color) (list (make-posn 0 0) (make-posn 2 2)))

;; Template

; (define (receive-move client color)
;  (... with-handlers ...)
;  (cond
;    [... list? ...]
;    (cond
;      [... in-bounds? ...]
;      [else ...])
;    [equal? ... 'quit ...]
;    [else ...]))
    
(define (receive-move connection color)
    (with-handlers
        ((exn:fail:network?
          (lambda (exception)
            (displayln (string-append color " got disconnected")) 'disconnect))) ; in case of a network error, the function signals that the player got disconnected
      (let ((input-data (read (connection-server-input connection)))) ; reads the data of the input port
        (cond
  [(and (list? input-data) (= (length input-data) 4)) ; if the data is a list (specifically a list with 4 elements),
   (let ((before-move (make-posn (first input-data) (second input-data)))
         (after-move (make-posn (third input-data) (fourth input-data))))
     (cond
       [(and (in-bounds? before-move) (in-bounds? after-move)) ; and the position is valid,
        (list before-move after-move)] ; it outputs the positions before and after the move
       [else 'invalid-move]))]
  [(equal? input-data 'quit) (displayln (string-append color " has quit the game")) 'quit] ; if the player quits, the function signals it
  [else 'invalid-move])))) ; otherwise, the move is indicated as invalid

;; CHECKING IF THE MOVES ARE VALID ;;

;; check-move: Move Color -> Boolean
; checks if a move is a valid chess move and if the moving player is correct
; header: (define (check-move move color) #true)

;; Template

; (define (check-move move color)
;  (cond
;    [... piece ...]
;    [... piece-type ... move ...]
;    [... piece-color ...]
;    [else ... move ...]))

(define (check-move move color)
  (let ((starting-piece (get-piece (first move)))) ; gets the piece at the starting position
    (cond
      [(not (= (length move) 2)) #false] ; checks if the move contains an initial and a final position
      [(not (piece? starting-piece)) #false] ; if there isn't any piece, the move is not valid
      [(not (equal? (piece-color starting-piece) color)) #false] ; checks if the color of the moving player is correct
      [(equal? (piece-type starting-piece) "pawn") ; if the piece is a pawn
       (member (second move) (possible-pawn-moves (list (get-piece (second move))) ; gets the possible moves
                              (first move)))] ; and checks if it's a valid move for the pawn
      [else ; otherwise, if the piece is not a pawn
       (member (second move) (apply append
                                         (calculate-all-moves
                                          (first move) (piece-movement starting-piece) (piece-repeatable? starting-piece))))]))) ; the function checks if its move is valid

;; INTERPRETING THE MOVES

;; interpret-move: Connection Color Connection Color Move -> Boolean
; interprets the moves according to the input received
; header: (define (interpret-move moving-player moving-color opponent-player opponent-color move) #false)

;; Template

; (define (interpret-move moving-player moving-color opponent-player opponent-color move)
;  (cond
;    [... move ...]
;    [... move ...]
;    [... move ... moving-color ...]
;    [else
;      (begin (... move-piece ...)
;             (... write ... opponent-player ...))]))

(define (interpret-move moving-player moving-color opponent-player opponent-color move)
  (cond
    [(equal? move 'disconnect)
     (displayln (string-append moving-color " got disconnected")) #false] ; if the player making the move gets disconnected, the function signals it and the game ends
    [(equal? move 'quit)
     (displayln (string-append opponent-color " wins for opponent's quitting")) #false] ; if the player making the move quits, the opponent wins
    [(false? (check-move move moving-color)) 'invalid-move #true] ; if the move is not valid, the function signals it and the game continues
    [else
     (begin
       (move-piece (first move) (second move)) ; moves the piece according to the player's move
       (write move (connection-server-input opponent-player)) ; the move is sent to the opponent
     (flush-output (connection-server-input opponent-player)) ; `flush-output`: guarantees that the data is immediately sent to `opponent-player` in case of a buffer
     #true)])) ; the game continues

;; Examples

(check-expect (interpret-move C1 "White" C2 "Black" 'quit) #false)

;; MANAGING A SINGLE GAME ;;

;; game-management: Connection Connection -> void
; manages a single game between the two players
; header: (define (game-management white-connection black-connection) void)

;; Template

; (define (game-management white-connection black-connection)
;  (cond
;   [equal? ... white-move ...]
;    [... check-move ...
;         (begin
;           (... move-piece ...)
;           (... white-move ... connection-server-output ... black-connection ...))
;           (cond
;             [equal? ...
;              (... interpret-move ...)]
;            [... check-move ...
;                  (begin
;                    (... move-piece ...)
;                    (... connection-server-output ... white-connection ...))
;                    (... game-management ...)]
;             [else
;              ... game-management ...])]
;    [else
;    ... game-management ...]))

(define (game-management white-connection black-connection)
  ; Start of White player moves
  (let ((white-move (receive-move white-connection "White")))
    (cond
      [(or (equal? white-move 'disconnect) (equal? white-move 'quit))
       (interpret-move white-connection "White"
                       black-connection "Black"
                       white-move)] ; if the player gets disconnected or quits,
                                    ; the move is interpreted accordingly, so the game ends
      [(and (list? white-move) (= (length white-move) 2)
            (check-move white-move "White")) ; if the move is valid,
       (begin
         (move-piece (first white-move) (second white-move)) ; the piece is moved
         (write white-move (connection-server-input black-connection)) ; and the move is sent to the opponent
         (flush-output (connection-server-input black-connection)))
       ; Start of Black player moves
         (let ((black-move (receive-move black-connection "Black")))
           (cond
             [(or (equal? black-move 'disconnect) (equal? black-move 'quit))
              (interpret-move black-connection "Black"
                              white-connection "White"
                              black-move)]
             [(and (list? black-move) (= (length black-move) 2)
                   (check-move black-move "Black"))
              (begin
                (move-piece (first black-move) (second black-move))
                (write black-move (connection-server-input white-connection))
                (flush-output (connection-server-input white-connection)))
              (game-management white-connection black-connection)]
             [else
              (write 'invalid-move (connection-server-input black-connection))
              (flush-output (connection-server-input black-connection))
              (game-management white-connection black-connection)]))]
      ; End of Black player moves
         [else
          (write 'invalid-move (connection-server-input white-connection))
          (flush-output (connection-server-input white-connection))
          (game-management white-connection black-connection)])))
; End of White player moves

;; CLOSING THE CONNECTION ;;

;; close-connection: Connection Connection TCP listener -> void
; closes the active connections
; header: (define (close-connection white-connection black-connection listener) void)

;; Template

; (define (close-connection white-connection black-connection listener)
;  (cond
;    [... white-connection ... (... close-input-port ....)])
;  (cond
;    [... white-connection ... (... close-output-port ...)])
;  (cond
;    [... black-connection ... (... close-input-port ...)])
;  (cond
;    [... black-connection ... (... close-output-port ...)])
;  (cond
;    [... listener ... (... tcp-close ...)]))

(define (close-connection white-connection black-connection listener)
  (cond
    [(connection-server-input white-connection)
     (close-input-port (connection-server-input white-connection))]) ; `close-input-port`: built-in function that closes the input port
  (cond
    [(connection-server-output white-connection)
     (close-output-port (connection-server-output white-connection))]) ; `close-output-port`: same, but closes the output port
  (cond
    [(connection-server-input black-connection)
     (close-input-port (connection-server-input black-connection))])
  (cond
    [(connection-server-output black-connection)
     (close-output-port (connection-server-output black-connection))])
  (cond
    [listener
     (tcp-close listener)])) ; `tcp-close`: shuts down the server associated with `listener`

;; ALLOWING MULTIPLE GAMES ;;

;; multiple-games: TCP listener -> void
; allows to play as many games as wanted
; header: (define (multiple-games listener) void)

;; Template

; (define (multiple-games listener)
;  (... game-management ...)
;    (cond
;      [... string=? ...]
;  [else ... close-connection ...]
;  (... multiple-games ...)))

(define (multiple-games listener)
  (displayln "Waiting for the players to connect")
  (let* ((black-connection (player-connection listener "Black"))
         (white-connection (player-connection listener "White")))
    (displayln "Both players connected")
    (game-management white-connection black-connection)
    (displayln "Game ended. Do you want to play again? (yes/no)")
    (let ((answer (read-line))) ; `read-line`: built-in function that reads what the player writes
      (cond
        [(string=? answer "yes")
         (game-management white-connection black-connection)
         (multiple-games listener)]
    [else (close-connection white-connection black-connection listener)
    (multiple-games listener)]))))

;; STARTING THE SERVER ;;

;; start-server: -> void
; starts the server and manages players' connection
; header: (define (start-server) void)

;; Template

; (define (start-server)
;  (... with-handlers ...)
;  (thread
;   (local
;     (cond
;       [... read-line ...]
;       [else ...])
;     (... multiple-games ...))))

(define (start-server)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Port already in use")
          (exit)))) ; if the port is already in use, the program gets closed
    (let ((listener (tcp-listen 1234 2 #true)) ; the `listener` waits for connections on port 1234,
                                               ; allowing maximum 2 players to try to connect
                                               ; and allowing reuse of the port right after the server terminated
          (ip-address (obtain-ip)))
      (displayln (string-append "Server started on IP address " ip-address " and Port 1234"))
      (displayln "Digit 'q' and press Enter to terminate the server")
      (thread ; monitors in parallel to the rest of the function if the player wants to quit
       (local ; player-quit: -> void
         ((define (player-quit)
         (cond
           [(equal? (read-line) "q")
            (displayln "Terminating the server")
            (tcp-close listener) ; if the player wants to quit, the server is closed and
            (exit)] ; the program gets closed
         [else (player-quit)]))) ; otherwise, it keeps monitoring if the player wants to quit
         player-quit)) ; gives the function for the `thread`
    (multiple-games listener))))
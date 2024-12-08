;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname client) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/tcp)
(require racket/base)
(provide start-client)
(require 2htdp/universe)
(require "logic.rkt")

(provide CHESS-COLOR)
(define CHESS-COLOR "white") ;; default


; (require "MAIN-P1.rkt")
; (require "MAIN-P2.rkt")

;;;;;;;;; CODE FOR THE CLIENT ;;;;;;;;;;;

;; CONNECTING TO THE IP ADDRESS ;;

;; connect-ip: -> String
; the player connects to the specific ip address
; header: (define (connect-ip) "")

;; Template

; (define (connect-ip)
;  (cond
;    [... (... string=? ...) ...]
;    [else
;     (... with-handlers ... connect-ip ... (... tcp-connect ...))]))

(define (connect-ip)
  (displayln "Enter the server IP address (press Enter for localhost)")
  (let ((ip-address (read-line)))
    (cond
      [(string=? ip-address "") "localhost"] ; if the player presses Enter, the IP address is the one for localhost
      [else ; otherwise:
       (with-handlers
           ((exn:fail:network?
             (lambda (exception)
               (displayln "Unable to connect to the server. Please retry") ; there's a connection error and the program asks to retry
               (connect-ip))))
         (tcp-connect ip-address 1234) ; or it tries to connect
         ip-address)])))

;; CONNECTING TO THE SERVER ;;

;; connect-to-server: String Port -> Any
; connects the client to the server
; header: (define (connect-to-server server-ip port) #false #false)

;; Template

; (define (connect-to-server server-ip port)
;  (... with-handlers ... (... tcp-connect ... server-ip ... port ...)))

(define (connect-to-server server-ip port)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Unable to connect to the server")
          (values #false #false)))) ; if the client is unable to connect to the server, it means that the input and output ports are closed
                                    ; `values` is used for returning 2 values
    (tcp-connect server-ip port))) ; otherwise, it connects

;; SENDING MOVES TO THE SERVER ;;

;; send-move-to-server: Port Move -> void
; sends player's moves to the server
; header: (define (send-move-to-server server-input move) void)

;; Template

; (define (send-move-to-server server-input move)
;  (... with-handlers ...
;       (... list ... move ... server-input ...)))

(define (send-move-to-server server-input move)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Unable to send the move"))))
  (begin
  (write move server-input)  ; sends the move
  (flush-output server-input))))

;; RECEIVING MOVES FROM THE SERVER ;;

;; receive-move-from-server: Port -> Any
; receives a move from the server
; header: (define (receive-move-from-server server-output) #false)

;; Template

; (define (receive-move-from-server server-output)
;  (... with-handlers ...
;       (cond
;         [... list? ...
;              (cond
;                [... in-bounds? ...]
;                [else ...]
;         [else ...])])))

(define (receive-move-from-server server-output)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Disconnected from the server")
          #false))) ; signals the network error
  (let ((input-data (read server-output))) ; reads data from the server output port
    (cond
      [(and (list? input-data) (= (length input-data) 4)) ; if the data is a list of 4 elements,
       (let                                         
        ((before-move (make-posn (first input-data) (second input-data))) ; it gets the initial position
        (after-move (make-posn (third input-data) (fourth input-data)))) ; and the final position
         (cond
           [(and (in-bounds? before-move) (in-bounds? after-move))
                 (list before-move after-move)]
           [else #false]))] ; the move isn't valid, because it's not inside the chessboard
      [else #false])))) ; the data isn't correct

;; DISCONNECTING THE CLIENT FROM THE SERVER ;;

;; disconnect-client: Port Port -> void
; disconnects the client
; header: (define (disconnect-client server-output server-input) void)

;; Template

; (define (disconnect-client server-output server-input)
;  (cond
;    [... server-output ... (... close-input-port ...)])
;  (cond
;    [... server-input ... (... close-output-port ...)]))

(define (disconnect-client server-output server-input)
  (cond
    [server-output (close-input-port server-output)])
  (cond
    [server-input (close-output-port server-input)]))

;; GAMES HANDLING ;;

;; handle-game: Port Port -> void
; handles the games
; header: (define (handle-game server-output server-input) void)

;; Template

; (define (handle-game server-output server-input)
;  (cond
;    [equal? ... set! ...]
;    [else ... set! ...])
;  (cond
;    [string=? ... server-input ... handle-game ...]
;    [else ... server-input ... disconnect-client ...]))

(define (handle-game server-output server-input)
  (let ((color (read server-output))) ; receives the player's color from the server
    (displayln (string-append "Playing as " color))
    (cond
      ; Black player
      [(equal? color "Black")
       (set! CHESS-COLOR "black")]
      ; White player
      [else (set! CHESS-COLOR "white")])
    (displayln "Game ended. Do you want to play again? (yes/no)")
    (let ((answer (read-line)))
      (cond
        [(string=? answer "yes")
         (write 'continue server-input)
         (flush-output server-input)
         (handle-game server-output server-input)]
        [else
         (write 'quit server-input)
         (flush-output server-input)
         (disconnect-client server-output server-input)]))))

;; STARTING THE CLIENT

;; start-client: -> void
; starts the client and manages its connection
; header: (define (start-client) void)

;; Template

; (define (start-client)
;  (... connect-ip ...)
;  (... connect-to-server ...)
;  (cond
;    [... server-input ... server-output ...]
;    [else ...]))
    
(define (start-client)
  (let*
      ((ip-address (connect-ip))
       (connection (connect-to-server ip-address 1234)))
    (let-values
        (((server-input server-output) connection))
         (cond
           [(and server-input server-output)
            (displayln "Connected to the server")
            (handle-game server-output server-input)]
           [else
            (displayln "Failed to connect to the server")]))))
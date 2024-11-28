;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Improved-Server-Chess) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/tcp)
(require racket/base)

;;;;;;;;;; CODE FOR THE SERVER ;;;;;;;;;;;;;

; a Maybe<Channel> is one of:
; - #false: the client is not connected  
; - a Number: input or output channel
; the two channels of a client

; a Color is a String and is one of:
; - "White"
; - "Black"
; color of the player's pieces

; a Client is a Structure (make-client input-channel output-channel color) where:
; - input-channel: Maybe<Channel>, receives the data
; - output-channel: Maybe<Channel>, sends the data
; - color: Color
; interpretation: the client of one of the two players that interacts with the server, by receiving and sending data through its channels
(define-struct client [input-channel output-channel color] #:transparent)

; Examples

(define C1 (make-client 23 27 "White"))
(define C2 (make-client 109 228 "Black"))

;; TWO CLIENTS BEFORE THE PLAYERS CONNECT ;;

(define initial-white-client (make-client #false #false "White"))
(define initial-black-client (make-client #false #false "Black"))

;; LISTENER CONSTANT ;;

(define LISTENER (tcp-listen 0)) ; a channel where the server waits for incoming connection requests, `tcp-listen`: makes the server wait for connection requests on a port
                                 ; in this case the port number is 0, because in this way it allows `tcp-listen` to choose any available port

;;;; AUXILIARY FUNCTIONS ;;;; 

;; CONNECTION MANAGEMENT ;;

;; connection-management: Maybe<Channel> Maybe<Channel> Color -> Client
; manages the player's connection by informing that they connected and outputting the client that connected
; header: (define (connection-management input-channel output-channel color) (make-client #false #false "White"))

;; Template

; (define (connection-management input-channel output-channel color)
;    (... color ...)
;    (... input-channel ... output-channel ... color ...)))

(define (connection-management input-channel output-channel color)
    (println (string-append color " is connected")) ; `println`: "White is connected" or "Black is connected"
    (make-client input-channel output-channel color))

;; Examples

(check-expect (connection-management 1 2 "White") (make-client 1 2 "White"))
(check-expect (connection-management 58 99 "Black") (make-client 58 99 "Black"))

;; PLAYERS' CONNECTION ;;

;; player-connection: Maybe<Channel> Color -> Client
; allows players' connection
; header: (define (player-connection LISTENER color) (make-client #false #false "White"))

;; Template

; (define (player-connection LISTENER color)
;  (... input-channel ... output-channel ... LISTENER ...)
;  (... input-channel ... output-channel ... color ...))

(define (player-connection LISTENER color)
  (define-values (input-channel output-channel) (tcp-accept LISTENER)) ; `define-values`: allocates the values of the multiple outputs of a function (`tcp-accept`) to
                                                                       ; different variables (`input-channel`, `output-channel`), one for each value. In this case the outputs are the input and output ports
                                                                       ; `tcp-accept`: accepts client's connection request
  (connection-management input-channel output-channel color))

;; Examples

(check-expect (player-connection LISTENER "White") (make-client 12 34 "White")) ; since any available port can be accessed, I chose two random numbers
(check-expect (player-connection LISTENER "Black") (make-client 56 78 "Black"))

;; RECEIVING PLAYER'S MOVES ;;

;; receive-move: Client Color -> Any
; receives the player's moves
; header: (define (receive-move client color) #false)

;; Template

; (define (receive-move client color)
;  (... with-handlers ...)
;  (cond
;    [... (client-input-channel client) ...]
;    [else ...]))
    
(define (receive-move client color)
    (with-handlers ; built-in function for handling exceptions, that in this case are network errors
        ([exn:fail:network? ; checks if an exception is related to the network
          (lambda (exception)
            (println (string-append color " wins because the opponent disconnected")) #false)]) ; in case of a network error, the function signals that the opponent is disconnected
        (cond
  [(not (false? (client-input-channel))) (read (client-input-channel client))] ; THIS PART IS A PLACEHOLDER THAT WILL BE CHANGED ACCORDING TO THE REST OF THE PROGRAM, SO I'LL WAIT FOR THE EXAMPLES
  [else
     (println "Invalid input channel") 
     #false]))) ; if the client is disconnected, the function signals it and ends the match

;; INTERPRETING THE MOVES ;;

;; TEMPORARY DATA TYPE DEFINITION FOR MOVE

; a Move is one of:
; - 'quit
; - 'disconnect
; - a chess move (?)

;; interpret-move: Client Color Client Color Move (?) -> Any ; I DON'T KNOW OF WHAT TYPE THE MOVE IS
; interprets the moves according to the inputs received
; header: (define (interpret-move moving-client moving-color opponent-client opponent-color move) #false)

;; Template

; (define (interpret-move moving-client moving-color opponent-client opponent-color move)
;  (cond
;    [... move ...]
;    [... move ...]
;    [else
;     ... move ... opponent-client ...]))

(define (interpret-move moving-client moving-color opponent-client opponent-color move)
  (cond
    [(equal? move 'disconnect)
     (println (string-append opponent-color " wins because the opponent disconnected")) #false] ; if the player making the move gets disconnected, the opponent wins
    [(equal? move 'quit)
     (println (string-append opponent-color " wins for opponent's quitting")) #false] ; if the player making the move quits, the opponent wins
    [else
     (write move (client-output-channel opponent-client)) ; THIS PART IS A PLACEHOLDER THAT WILL BE CHANGED ACCORDING TO THE REST OF THE PROGRAM, SO I'LL WAIT FOR THE EXAMPLES
     (flush-output (client-output-channel opponent-client))])) ; `flush-output`: guarantees that the data is immediately sent to `opponent-client` in case of a buffer

;; ALTERNATING THE MOVES BETWEEN THE PLAYERS ;;

;; alternate-move: Client Color Client Color Move (?) -> Any
; alternates the moves between the two players, ensusring that they play alternately a turn each until the end of the match
; header: (define (alternate-move moving-client moving-color opponent-client opponent-color move) #false)

;; Template

; (define (alternate-move moving-client moving-color opponent-client oppoennt-color move)
;  (cond
;    [(false? (... interpret-move ...) ...]
;    [else
;     (let (... (... (... receive-move ...) ...)
;     (cond
;      [(false? (... interpret-move ...) ...]
;      [else (... alternate-move ...)]))]))

(define (alternate-move moving-client moving-color opponent-client opponent-color move)
  (cond
    [(false? (interpret-move moving-client moving-color opponent-client opponent-color move)) #false] ; if `interpret-move` returns `#false`, then the match ends
    [else
     (let ((next-move (receive-move opponent-client opponent-color))) ; otherwise, the move is received by the opponent and the match continues
     (cond
       [(false? (interpret-move opponent-client opponent-color moving-client moving-color next-move)) #false] ; if the opponents move is `#false` (they got disconnected or quitted), then the match ends
       [else (alternate-move opponent-client opponent-color moving-client moving-color next-move)]))])) ; otherwise, `alternate-move` is called recursively and the opponent makes his move
; I WAIT FOR THE EXAMPLES

;; STARTING THE SERVER ;;

; a Port is a Number
; a port for incoming connection requests

;; start-server: Port -> Client Client
; starts the server for the match
; header: (define (start-server port) (initial-white-client initial-black-client))

;; Template

; (define (start-server port)
;  (set! initial-white-client ...)
;  (set! initial-black-client ...)
;  (alternate-move ...))
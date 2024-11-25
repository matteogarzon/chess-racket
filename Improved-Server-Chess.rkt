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
    (displayln (string-append color " is connected")) ; `displayln`: "White is connected" or "Black is connected"
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
; header: (define (receive-move client color) (#false))

;; Template

; (define (receive-move client color)
;  (... with-handlers ...)
;  (cond
;    [... (client-input-channel client) ...]
;    [else ...]))
    
(define (receive-move client color)
    (with-handlers ; built-in function for handling exceptions, that in this case are network errors
        ([exn:fail:network? ; checks if an exception is related to the network
          (lambda (exception) ; anonymous function with argument `exception`, because it's needed by `with-handlers`
            (displayln (string-append color " wins because the opponent disconnected")) #false)]) ; in case of a network error, the function signals that the opponent is disconnected
        (cond
  [(not (false? (client-input-channel))) (read (client-input-channel client))] ; THIS PART IS A PLACEHOLDER THAT WILL BE CHANGED ACCORDING TO THE REST OF THE PROGRAM, SO I'LL WAIT FOR THE EXAMPLES
  [else
     (displayln "Invalid input channel") 
     #false]))) ; if the client is disconnected, the function signals it and returns the state of the `input-channel`, so `#false`
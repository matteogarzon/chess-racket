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
                                 ; in this case the port number is 0, because it allows `tcp-listen` to choose any available port

;;;; AUXILIARY FUNCTIONS ;;;; 

;; FUNCTION FOR CONNECTION MANAGEMENT ;;

;; connection-management: Maybe<Channel> Maybe<Channel> Color -> Client
; manages the player's connection by informing that they connected and outputting the client that connected

;; Template

; (define (connection-management input-channel output-channel color)
;  (begin
;    (... color ...)
;    (... input-channel ... output-channel ... color ...)))

(define (connection-management input-channel output-channel color)
  (begin ; for performing more than one operation, otherwise it would raise an error
    (displayln (string-append color " is connected")) ; `displayln`: "White is connected" or "Black is connected"
    (make-client input-channel output-channel color)))

;; Examples
(check-expect (connection-management 1 2 "White") (make-client 1 2 "White"))
(check-expect (connection-management 58 99 "Black") (make-client 58 99 "Black"))
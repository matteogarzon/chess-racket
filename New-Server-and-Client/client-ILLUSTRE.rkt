;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname client) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/tcp)
(require racket/base)
(provide start-client)
(require 2htdp/universe)
(require "logic.rkt")

(provide CHESS-COLOR)
(define CHESS-COLOR "White") ;; default

;;;;;;;;; CODE FOR THE CLIENT ;;;;;;;;;;;

;; CONNECTING TO THE IP ADDRESS ;;

;; connect-ip: -> String
; the player connects to the specific ip address
; header: (define (connect-ip) "")

;; Template

; (define (connect-ip)
;  (... with-handlers ...
;       ... tcp-connect ...)))

(define (connect-ip)
  (displayln "Enter the server IP address")
  (let ((ip-address (read-line)))
    ip-address))

;; CONNECTING TO THE SERVER ;;

;; connect-to-server: String Port -> Port Port
; connects the client to the server
; header: (define (connect-to-server server-ip port) server-input server-output)

;; Template

; (define (connect-to-server server-ip port)
;  (... with-handlers ...
;      (... tcp-connect ... server-ip ... port ...)))

(define (connect-to-server server-ip port)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Unable to connect to the server")
          (exit))))
    (define-values (server-input server-output)
    (tcp-connect server-ip port))
    (values server-input server-output)))

;; SENDING MOVES TO THE SERVER ;;

;; send-move-to-server: Port Move -> void
; sends player's moves to the server
; header: (define (send-move-to-server server-input move) void)

;; Template

; (define (send-move-to-server server-input move)
;  (... with-handlers ...
;       (... move ... server-input ...)))

(define (send-move-to-server server-input move)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Unable to send the move")
          (exit))))
  (write move server-input)  ; sends the move
  (flush-output server-input)))

;; RECEIVING MOVES FROM THE SERVER ;;

;; receive-move-from-server: Port -> Move
; receives a move from the server
; header: (define (receive-move-from-server server-output) WHITE-PAWN-E4)

;; Template

; (define (receive-move-from-server server-output)
;  (... with-handlers ...
;       (cond
;         [... list? ...
;              (cond
;                [... in-bounds? ...]
;                [else ...]
;         [else ...])])))

(define (receive-move-from-server server-input) ; Changed parameter name from server-output to server-input
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Disconnected from the server")
          (exit))))
  (let ((input-data (read server-input))) ; Changed to read from server-input instead of server-output
    (cond
      [(and (list? input-data) (= (length input-data) 4))
       (let                                         
        ((before-move (make-posn (first input-data) (second input-data)))
        (after-move (make-posn (third input-data) (fourth input-data))))
          (cond
            [(and (in-bounds? before-move) (in-bounds? after-move))
                  (list before-move after-move)]
            [else 'invalid-move]))]
      [else 'invalid-move]))))

;; DISCONNECTING THE CLIENT FROM THE SERVER ;;

;; disconnect-client: Port Port -> void
; disconnects the client
; header: (define (disconnect-client server-output server-input) void)

;; Template

; (define (disconnect-client server-output server-input)
;  (... with-handlers ...
;  (cond
;    [... server-output ... server-input ... (... server-output ...)
;                                            (... server-input ...)]
;    [... server-output ... (... server-output ...)]
;    [... server-input ... (... server-input ...)])))

(define (disconnect-client server-output server-input)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Error while disconnecting the client"))))
    (cond
      [(and server-output server-input) ; both ports open
       (close-input-port server-output)
       (close-output-port server-input)]
      [server-output ; only input port open
       (close-input-port server-output)]
      [server-input ; only output port open
       (close-output-port server-input)])))

;; HANDLING A GAME SESSION ;;

;; handle-game-session: Port Port -> void
; handles a game session made of multiple games
; header: (define (handle-game-session server-output server-input) void)

;; Template

; (define (handle-game-session server-output server-input)
;  (... with-handlers ...
;    (... CHESS-COLOR ...)
;  (cond
;    [string=? ... server-input ...
;              (... handle-game ...)]
;    [string=? ... server-input ...
;              (... disconnect-client ...)]
;    [else
;     (... handle-game-session ...)])))

(define (handle-game-session in out)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Connection error")
          (disconnect-client in out)
          (exit))))
    (displayln "Game ended. Do you want to play again? (yes/no)?")
    (let ((answer (read-line)))
      (cond
        [(string=? answer "yes")
         (write 'continue out)
         (flush-output out)
         (handle-game-session in out)]
        [(string=? answer "no")
         (write 'quit out)
         (flush-output out)
         (disconnect-client in out)]
        [else
         (displayln "Invalid answer. Type 'yes' or 'no")
         (handle-game-session in out)]))))

;; STARTING THE CLIENT

;; start-client: -> void
; starts the client and manages its connection
; header: (define (start-client) void)

;; Template

; (define (start-client)
;  (... with-handlers ...
;  (... connect-ip ...)
;  (... connect-to-server ...)
;  (cond
;    [... server-input ... server-output ...
;     (... handle-game-session ...)]
;    [else ...])))

(define (start-client)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Unable to start the client")
          (exit))))
    (let ((ip-address (connect-ip)))
      (define-values (in out)
        (tcp-connect ip-address 1234))
      (cond
        [(and in out)
         (displayln "Connected to the server")
         ; Read the color assignment from server
         (let ((color (read in)))
           (displayln (string-append "Playing as " color))
           (set! CHESS-COLOR color)
           (handle-game-session in out))]
        [else
         (displayln "Unable to connect to the server")
         (exit)]))))
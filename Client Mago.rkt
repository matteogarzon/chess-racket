;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname |Client Mago|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
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

(define (receive-move-from-server server-output)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Disconnected from the server") ; signals the network error
          (exit))))
  (let ((input-data (read server-output))) ; reads data from the server output port
    (cond
      [(and (list? input-data) (= (length input-data) 4)) ; if the data is a list of 4 elements,
       (let                                         
        ((before-move (make-posn (first input-data) (second input-data))) ; it gets the initial position
        (after-move (make-posn (third input-data) (fourth input-data)))) ; and the final position
         (cond
           [(and (in-bounds? before-move) (in-bounds? after-move)) ; if the move is valid,
                 (list before-move after-move)] ; it returns it
           [else 'invalid-move]))] ; otherwise, it's signaled as an invalid move
      [else 'invalid-move])))) ; the data isn't valid

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

(define (handle-game-session server-output server-input)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Connection error")
          (disconnect-client server-output server-input)
          (exit))))
    (let ((color (read server-output)))
      (displayln (string-append "Playing as " color))
      (set! CHESS-COLOR color)
    (displayln "Game ended. Do you want to play again? (yes/no)?")
    (let ((answer (read-line)))
      (cond
        [(string=? answer "yes")
         (write 'continue server-input)
         (flush-output server-input)
         (handle-game-session server-output server-input)]
        [(string=? answer "no")
         (write 'quit server-input)
         (flush-output server-input)
         (disconnect-client server-output server-input)]
        [else
         (displayln "Invalid answer. Type 'yes' or 'no")
         (handle-game-session server-output server-input)])))))
(define (start-client)
  (with-handlers
      ((exn:fail:network?
        (lambda (exception)
          (displayln "Unable to start the client. Check your network or server availability.")
          (exit))))
    (let ((ip-address (connect-ip)))
      (displayln (string-append "Attempting to connect to server at " ip-address " on port 1234"))
      (define-values (server-input server-output)
        (tcp-connect ip-address 1234)) ; Connetti al server
      (cond
        [(and server-input server-output)
         (displayln "Successfully connected to the server.")
         
         ;; Avvia un thread per mantenere la connessione attiva
         (thread
          (lambda ()
            (with-handlers
                ((exn:fail:network?
                  (lambda (exception)
                    (displayln "Network error occurred during communication.")
                    (exit))))
              (handle-game-session server-output server-input))))] ; Gestisci la sessione di gioco

        [else
         (displayln "Unable to connect to the server. Please try again.")
         (exit)]))))
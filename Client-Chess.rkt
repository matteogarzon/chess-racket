;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Client-Chess) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/tcp)
(require racket/base)
(require "logic.rkt")

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
  (write (list (posn-x (first move)) (posn-y (first move))
               (posn-x (second move)) (posn-y (second move))) ; sends the move
         server-input)
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

;;;;!!!!! WILL HAVE TO DEFINE FUNCTION FOR PLAYING MULTIPLE GAMES !!!!!!!!;;;;;;;;

;; STARTING THE CLIENT ;; NOT DEFINITIVE

;; start-client: String Number -> Number Number
; starts the client and connects to the server
; header: (define (start-client host port) 1 2)

;; Template

; (define (start-client host port)
;  (... host ... port ...))

 (define (start-client host port)
   (let-values (((input output) (connect-to-server host port))) ; connects to the server
  (values input output))) ; outputs the two values of the input and output ports

; (define-values (input1 output1) (start-client SERVER-HOST SERVER-PORT))
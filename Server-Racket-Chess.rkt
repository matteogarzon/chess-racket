;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Server-Racket-Chess) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/tcp)

;;;;;;;;;; CODE FOR THE SERVER ;;;;;;;;;;;;;

; Two clients before the players connect
(define white-client '())
(define black-client '())

; Listener constant
(define LISTENER (tcp-listen port)) ; listener that waits for incoming connection requests, `tcp-listen`: makes the server "listen" on a specific port

;;;; Auxiliary Functions ;;;; 

;; Function for connection management
(define (connection-management input output color)
  (displayln (string-append color " is connected")) ; `displayln`: "White is connected" or "Black is connected", it's useful for clearly dividing different messages
  (list input output)) ; `list`: groups together the input and output channels

; Connection of each player, with the information of their color (white or black)
(define (player-connection LISTENER color) ; `color`: it's a string, color of player's pieces (white or black)
  (define-values (input output) (tcp-accept LISTENER)) ; `define-values`: defines multiple values for a function that outputs different results and each of them is assigned to a different variable
                                                       ; in this case: `input` (server reads from client) and `output` (server sends to client) are the channels that receive the values
                                                       ; `tcp-accept`: the function that outputs the values, it accepts the client connection (two values: input and output)
  (connection-management input output color)) ; `connection-management`: notifies the players when they enter the game (`displayln`) and returns the input and output channels (`list`)
  
; Reading players' moves
(define (read-move client color)
  (with-handlers ((exn:fail:network? ; `with-handlers`: built-in function for handling exceptions, so in this case for network errors,
                                     ; `exn:fail:network?`: checks if an exception is related to the network
                   (lambda (exception) ; `exception` is used because `with-handlers` needs a function (`lambda`) that has an exception as its argument
                     (displayln (string-append color " wins because the opponent disconnected")) 'disconnected))) ; if the opponent gets disconnected, the other player wins,
                                                                                                               ; `'disconnected`: symbol for when a player gets disconnected
    (read (first client)))) ; `read`: reads the player's move, if there isn't any network error, in which case there will be an exception

; Interpreting the moves
(define (move-interpreter moving-client opponent-client moving-color opponent-color move) ; `moving-client`: who makes the move, `opponent-client`: who receives the move
                                                                                          ; `moving-color`: the color of who makes the move, `opponent-color`: the color of who receives the move
                                                                                          ; `move`: the move made, also considering a possible quitting or disconnection
  (cond
    [(equal? move 'quit)
     (displayln (string-append opponent-color " wins for opponent's quitting"))] ; if the player making the move quits, the opponent wins
    [(equal? move 'disconnect)
     (displayln (string-append opponent-color " wins because the opponent disconnected"))] ; if the player making the move gest disconnected, the opponent wins
    [else (write move (rest opponent-client)) ; if the move is a chess move, then it's sent to the opponent
          (flush-output (rest opponent-client))])) ; `flush-output`: guarantees that the data is immediately sent to the opponent, in case of a buffer

;;;; Moves' handling ;;;; NEEDS TO BE CHANGED ACCORDING TO WHAT I DID ABOVE!!!!
(define (move-handler white-client black-client)
    ; White player's moves
    (define white-move (read (first white-client))) ; `move`: player's move, read: reads the move of the white player, first: gets the input (first element: `white-input`) of `white-client`
  (cond
    [(equal? white-move 'quit)
     (displayln "Black wins for opponent's quitting!")] ; if the white quits, the game terminates and the opponent wins
    [else
     (write white-move (rest black-client)) ; `write`: the move is sent to `black-client`, rest: gets the output (second element: `black-output`) of `black-client`
    (flush-output (rest black-client))] ; `flush-output`: guarantees that the data is immediately sent to `black-client`, in case of a buffer
    ; Black player's moves
    (define black-move (read (first black-client)))
  (cond
    [(equal? black-move 'quit)
     (displayln "White wins for opponent's quitting!")]
    [else
     (write black-move (rest white-client))
    (flush-output (rest white-client))])))

;;;; Starting the server ;;;;
(define (starting-server port) ; `port`: port of the server
  (displayln (string-append "Server listening on port " (number->string port))) ; `displayln`: says that the server is waiting for the players to connect
                                                                                ; `number->string`: built-in function that transforms numbers into strings
  (set! white-client (player-connection LISTENER "White")) ; `set!`: changes the connection state of `white-client`, because it connected
  (set! black-client (player-connection LISTENER "Black")) ; `set!`: changes the connection state of `black-client`, because it connected
  (move-handler white-client black-client)) ; for handling the two player's moves

(starting-server 50000) ; 50000: just a symbolic port
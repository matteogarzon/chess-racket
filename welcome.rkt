;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname welcome) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)
(require "Improved-Server-Chess.rkt")
(require "Client-Chess.rkt")

;; Constants for the welcome screen
(define WINDOW-WIDTH 600)
(define WINDOW-HEIGHT 600)
(define TEXT-BACKGROUND-WIDTH 300) 
(define TEXT-BACKGROUND-HEIGHT 80)
(define TEXT-BACKGROUND-COLOR "lightgreen")
(define TEXT-COLOR "black")
(define INITIAL-STATE 'waiting)

;; Create the welcome screen elements
(define TITLE-TEXT (text "Welcome to Chess!" 40 TEXT-COLOR))
(define AUTHORS-TEXT (text "By Leonardo Longhi, Loris Vasirani & Matteo Garzon" 20 TEXT-COLOR))

(define INSTRUCTIONS-TEXT
   (above
    (text "Instructions:" 24 TEXT-COLOR)
    (text "• Press 'h' to host a game." 18 TEXT-COLOR)
    (text "• Press 'j' to join a game." 18 TEXT-COLOR)
    (text "• During the game, press 'q' and Enter to leave." 18 TEXT-COLOR)))

;; Key handler
(define (key-handler state key)
  (cond
    [(and (equal? state 'waiting) (equal? key "h"))
     (start-server)
     (exit)]
    [(and (equal? state 'waiting) (equal? key "j"))
     (start-client)
     (exit)]
    [else state]))

;; Main welcome screen scene
(define (welcome-scene state)
  (place-images
   (list TITLE-TEXT
         AUTHORS-TEXT
         INSTRUCTIONS-TEXT)
   (list (make-posn (/ WINDOW-WIDTH 2) 150)
         (make-posn (/ WINDOW-WIDTH 2) 180)
         (make-posn (/ WINDOW-WIDTH 2) (/ WINDOW-HEIGHT 2)))
   (empty-scene WINDOW-WIDTH WINDOW-HEIGHT "honeydew")))

;; Run the welcome screen
(define (run-welcome)
  (big-bang 'waiting
    [name "Chess"]
    [to-draw welcome-scene]
    [on-key key-handler]))

(run-welcome)
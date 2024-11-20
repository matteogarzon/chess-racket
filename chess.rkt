;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname chess) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; CONSTANTS

; BOARD
; board size (from screen width)
; square size (from screen width divided by...)
; board width (* square-size board-size)
; NOTE: what if screen changes? we can't set!


;; CLASS
;; Types of Moves (as posn, where (posn 0 0) is the reference point before the move)
; diagonal-moves (posn 1 1) (posn 1 -1)
; straight-moves (posn 1 0) (posn 0 1)
; knight-moves (posn 2 1) (posn 2 -1)



;;;; HELPER FUNCTIONS

;; TO MOVE PAWNS
; can-move-here? (in bounds, and not occupied by a piece of same color)
; is-piece-here?
; in-bounds?
; get-piece (called by is-piece-here?)

; move-piece

;; BOARD RENDER HELPERS
; decide-square-color
; highlight-square (called when e.g., draw-possible-moves)
; draw-possible-moves
; press-square (clicking square, finds which one we are clicking on)


;;; BIG BANG
;; ON SCREEN RE-SIZE
; Modify size of chess board
; call render function, which draws board + pawns

; ON MOUSE CLICK
; if we set the chess board to the top and bottom of screen...
; we get mouse-x and mouse-y
; use math to calculate in which square it is


;; ROAD MAP

; (ROLE 1)
; 1. Display chess board
; 2. Put element(s) inside chess board
; 3. Replace those elements with actual pawns
; 4. Place each pawn in correct starting position
; 5. Select a pawn
; 6. Move a pawn (either drag or simple click on square)
; 7. Display dot on correct squares
; 8. Place pawns on other side

; (ROLE 2)
; 1. Implementation to move to different screens (welcome page to "insert username" page to actual game page)
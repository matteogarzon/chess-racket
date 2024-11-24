;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname logic) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
; constants
(define DIAGONAL-MOVES (list (make-posn 1 1) (make-posn 1 -1) (make-posn -1 1) (make-posn -1 -1)))
(define VERTICAL-MOVES (list (make-posn 1 0) (make-posn -1 0)))
(define HORIZONTAL-MOVES (list (make-posn 0 1) (make-posn 0 -1)))
(define KNIGHT-MOVES   (list (make-posn 2 1) (make-posn 2 -1) (make-posn -2 1) (make-posn -2 -1) (make-posn 1 2) (make-posn 1 -2) (make-posn -1 2) (make-posn -1 -2)))

(define KING-QUEEN-MOVES (append DIAGONAL-MOVES VERTICAL-MOVES HORIZONTAL-MOVES))
(define ROOK-MOVES (append VERTICAL-MOVES HORIZONTAL-MOVES))

; Pawn is a strucutre
; type is a string and can be one of the following:
; - king
; - queen
; ...

; player is a number and one of the following
; 1 = local player
; 2 = other player
; color can be one of the following
; - black
; - white
; movement is a list of posn
; repeatable is a boolean
(define-struct piece [type movement repeatable player color])

;; STARTING PIECES
; BLACK
(define BLACK-KING (make-piece "king" KING-QUEEN-MOVES false 1 "BLACK"))
(define BLACK-QUEEN (make-piece "queen" KING-QUEEN-MOVES true 1 "BLACK"))

(define BLACK-KNIGHT (make-piece "knight" KNIGHT-MOVES false 1 "BLACK"))
(define BLACK-ROOK (make-piece "rook" ROOK-MOVES true 1 "BLACK"))
(define BLACK-BISHOP (make-piece "bishop" DIAGONAL-MOVES true 1 "BLACK"))

; WHITES
(define WHITE-KING (make-piece "king" KING-QUEEN-MOVES false 1 "WHITE"))
(define WHITE-QUEEN (make-piece "queen" KING-QUEEN-MOVES true 1 "WHITE"))

(define WHITE-KNIGHT (make-piece "knight" KNIGHT-MOVES false 1 "WHITE"))
(define WHITE-ROOK (make-piece "rook" ROOK-MOVES true 1 "WHITE"))
(define WHITE-BISHOP (make-piece "bishop" DIAGONAL-MOVES true 1 "WHITE"))

; positions pawns in the BOARD-GAMES in the corresponding starting points
(define BOARD-VECTOR
  (vector
    (vector BLACK-ROOK BLACK-KNIGHT BLACK-BISHOP BLACK-QUEEN BLACK-KING BLACK-BISHOP BLACK-KNIGHT BLACK-ROOK)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector WHITE-ROOK WHITE-KNIGHT WHITE-BISHOP WHITE-QUEEN WHITE-KING WHITE-BISHOP WHITE-KNIGHT WHITE-ROOK)))


; possible-moves : Piece -> List<Posn>
; from position and type of movement of piece, returns possible moves
(define (possible-moves piece)
  )


; move-piece : Posn Posn -> void
; moves piece from original posn position to new position, and mutates BOARD-VECTOR accordingly
(define (move-piece current-posn new-posn)
  (begin ;;;;;;; OK????
    (set-piece new-posn)
    (set-null current-posn)))

;; HELPER FUNCTIONS FOR 'move-piece'
; set-piece: Posn -> void
(define (set-piece position)
  (vector-set! (vector-ref BOARD-VECTOR (posn-x position)) (posn-y position) (get-piece position)))

; set-null : Posn -> void
(define (set-null position)
    (vector-set! (vector-ref BOARD-VECTOR (posn-x position)) (posn-y position) 0))


;; HELPER FUNCTIONS
; get-piece : Posn -> Piece
(define (get-piece position)
  (vector-ref (vector-ref BOARD-VECTOR (posn-x position)) (posn-y position)))

; my-piece? : Piece -> Boolean
; checks if piece is of the local player, based on the color (black)
(define (my-piece? piece)
  (cond
    [(piece-color = "BLACK") #true]
    [else #false]))


;; TO MOVE PAWNS
; in-bounds?
; get-piece (called by is-piece-here?)
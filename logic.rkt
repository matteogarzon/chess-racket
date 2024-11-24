;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname logic) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; NOTA PER LORIS E LEONARDO
; Per simplificare la logica a livello di array 2D, le pedine del giocatore locale sono state posizionate dalla parte dell'avversario (così basta dire posizione 0 e 0 al posto di 7 e 7, ecc..)
; Quindi, a livello di UI bisogna cambiare l'ordine una volta che si mettono le pedine nella scacchiera visiva.

; Types of Moves
(define DIAGONAL-MOVES (list (make-posn 1 1) (make-posn 1 -1) (make-posn -1 1) (make-posn -1 -1)))
(define VERTICAL-MOVES (list (make-posn 1 0) (make-posn -1 0)))
(define HORIZONTAL-MOVES (list (make-posn 0 1) (make-posn 0 -1)))
(define KNIGHT-MOVES   (list (make-posn 2 1) (make-posn 2 -1) (make-posn -2 1) (make-posn -2 -1) (make-posn 1 2) (make-posn 1 -2) (make-posn -1 2) (make-posn -1 -2)))

(define KING-QUEEN-MOVES (append DIAGONAL-MOVES VERTICAL-MOVES HORIZONTAL-MOVES))
(define ROOK-MOVES (append VERTICAL-MOVES HORIZONTAL-MOVES))

;; DATA TYPES
; Piece is a strucutre:
;   (make-piece type movement repeatable player color)
; where:

; type is a string and can be one of the following:
; - King
; - Queen
; - Knight
; - Rook
; - Bishop
; - Piece

; player is a Number and one of the following:
; 1 = local player
; 2 = other player

; color is a String and one of the following;
; - Black
; - White

; movement is a list of posn (representing the types of movements)
; repeatable is a boolean
(define-struct piece [type movement repeatable player color])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; STARTING PIECES
; BLACK
(define BLACK-KING (make-piece "king" KING-QUEEN-MOVES false 1 "BLACK"))
(define BLACK-QUEEN (make-piece "queen" KING-QUEEN-MOVES true 1 "BLACK"))

(define BLACK-KNIGHT (make-piece "knight" KNIGHT-MOVES false 1 "BLACK"))
(define BLACK-ROOK (make-piece "rook" ROOK-MOVES true 1 "BLACK"))
(define BLACK-BISHOP (make-piece "bishop" DIAGONAL-MOVES true 1 "BLACK"))
(define BLACK-PAWN (make-piece "pawn" '(make-posn 0 1) false 1 "BLACK"))

; WHITES
(define WHITE-KING (make-piece "king" KING-QUEEN-MOVES false 2 "WHITE"))
(define WHITE-QUEEN (make-piece "queen" KING-QUEEN-MOVES true 2 "WHITE"))

(define WHITE-KNIGHT (make-piece "knight" KNIGHT-MOVES false 2 "WHITE"))
(define WHITE-ROOK (make-piece "rook" ROOK-MOVES true 2 "WHITE"))
(define WHITE-BISHOP (make-piece "bishop" DIAGONAL-MOVES true 2 "WHITE"))
(define WHITE-PAWN (make-piece "pawn" '(make-posn 0 1) false 2 "WHITE"))

; Board, with initial 
(define BOARD-VECTOR
  (vector
    (vector BLACK-ROOK BLACK-KNIGHT BLACK-BISHOP BLACK-QUEEN BLACK-KING BLACK-BISHOP BLACK-KNIGHT BLACK-ROOK)
    (vector BLACK-PAWN BLACK-PAWN BLACK-PAWN BLACK-PAWN BLACK-PAWN BLACK-PAWN BLACK-PAWN BLACK-PAWN)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector WHITE-PAWN WHITE-PAWN WHITE-PAWN WHITE-PAWN WHITE-PAWN WHITE-PAWN WHITE-PAWN)
    (vector WHITE-ROOK WHITE-KNIGHT WHITE-BISHOP WHITE-QUEEN WHITE-KING WHITE-BISHOP WHITE-KNIGHT WHITE-ROOK)))


;;;;;;;;;;;;;;;
;; PAWN ONLY ;;
;;;;;;;;;;;;;;;


;;;; ASK THIS INSTEAD OF MUTABLE LISTS
; possible-pawn-moves : Posn -> List<Posn>
; returns list of possible moves for pawns
(define (possible-pawn-moves current-position)
  (if (move-one-forward? current-position)
      (if (move-left-diagonal? current-position)
          (if (move-right-diagonal? current-position)
              (if (move-two-forward? current-position)
                  (list (make-posn ))
                  (list (make-posn )))
      (t)))

;;;;;;;;
;;;;;;;;

; possible-moves : Posn, List<Posn>, Boolean -> List<Posn>
; from position and type of movement of piece, returns possible moves
; only used for non-pawn pieces.
(define (possible-moves current-position movements is-repeatable)
 (map (lambda (move) (calculate-move move current-position)) (piece-movement)))

; calculate-move : Posn, Posn -> ???????
(define (calculate-move move current-position)
  (local [(define new-posn (make-posn (+ (posn-x move) (posn-x current-position)) (+ (posn-y move) (posn-y current-position))))]
  (when (and (in-bounds? new-posn) (not(my-piece? new-posn))) 1))) ; new pos is good!
;;;;;; ADD RECURSION

; in-bounds : Posn -> Boolean
(define (in-bounds? position)
  (cond
    [(and (and (>= (posn-x position) 0) (<= (posn-x position) 7)) (and (>= (posn-y position) 0) (<= (posn-y position) 7))) #true]
    [else #false]))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; HELPER FUNCTIONS
; get-piece : Posn -> Maybe<Piece>
(define (get-piece position)
  (vector-ref (vector-ref BOARD-VECTOR (posn-x position)) (posn-y position)))

; my-piece? : Piece -> Boolean
; checks if piece is of the local player, based on the player number on piece
(define (my-piece? piece)
  (cond
    [(equal? piece-player 1) #true]
    [else #false]))

; is-there-piece? : Posn -> Boolean
; checks whether there's a piece in the specified position
(define (is-there-piece position)
  (cond
    ;;;; ADD INBOUNDS
    [(= 0 (get-piece position)) #false]
    [else #true]))


;; CAN USE SLIDE 9??????
; move-one-forward? : Posn -> Boolean
(define (move-one-forward position)
  (cond
    [(not(is-there-piece? (make-posn (+ 1 (posn-x position)) (+ 1 (posn-y position))))) #true]
    [else #false]))

; move-two-forward? : Posn -> Boolean
(define (move-two-forward position)
  (cond
    [(not(is-there-piece? (make-posn (+ 2 (posn-x position)) (+ 2 (posn-y position))) #true))]
    [else #false]))

; move-left-oblique? : Posn -> Boolean
(define (move-left-oblique position)
  (cond
    [(not(is-there-piece? (make-posn (- 1 (posn-x position)) (+ 1 (posn-y position))) #true))]
    [else #false]))


; move-right-oblique? : Posn -> Boolean
(define (move-right-oblique position)
  (cond
    [(not(is-there-piece? (make-posn (+ 1 (posn-x position)) (+ 1 (posn-y position))) #true))]
    [else #false]))
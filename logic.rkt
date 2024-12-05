;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname logic) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require racket/base)
(provide get-piece)
(provide piece?)
(provide piece-type)
(provide possible-pawn-moves)
(provide calculate-all-moves)
(provide piece-movement)
(provide piece-repeatable?)
(provide BOARD-VECTOR)
(provide DIAGONAL-MOVES)
(provide KNIGHT-MOVES)
(provide KING-QUEEN-MOVES)
(provide VERTICAL-MOVES)
(provide ROOK-MOVES)
(provide move-piece)
(provide is-there-piece?)
(provide is-there-opponent-piece?)
(provide set-null)
(provide set-piece)
(provide my-piece?)
(provide in-bounds?)
(require 2htdp/image)
(require 2htdp/universe)

; Types of Moves
(define DIAGONAL-MOVES (list (make-posn 1 1) (make-posn 1 -1) (make-posn -1 1) (make-posn -1 -1)))
(define VERTICAL-MOVES (list (make-posn 1 0) (make-posn -1 0)))
(define HORIZONTAL-MOVES (list (make-posn 0 1) (make-posn 0 -1)))
(define KNIGHT-MOVES (list (make-posn 2 1) (make-posn 2 -1) (make-posn -2 1) (make-posn -2 -1) 
                          (make-posn 1 2) (make-posn 1 -2) (make-posn -1 2) (make-posn -1 -2)))
(define KING-QUEEN-MOVES (append DIAGONAL-MOVES VERTICAL-MOVES HORIZONTAL-MOVES))
(define ROOK-MOVES (append VERTICAL-MOVES HORIZONTAL-MOVES))

;; DATA TYPES
; a Piece is a structure:
; where
;   type           :    String
;   movement       :    Posn
;   repeatable?    :    Boolean
;   player         :    Number
;   color          :    String
;   dragged?       :    Boolean
;   img            :    Image
;   width          :    Number
;   height         :    Number
;   present?       :    Boolean
; interpretation: a piece of the chessboard with his own type, movement-state,
; repeatable-state, player, color, dragged-state, image, width, height, and present-state
(define-struct piece [type movement repeatable? player color dragged? img width height present?] #:transparent)

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
; repeatable? is a boolean

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defining the squares colors
(define SQUARE-COLOR-1 "light blue")   ; Color 1
(define SQUARE-COLOR-2 "white") ; Color 2

; Defining the side of the squares
(define SQUARE-SIDE 64)

; Defining the division ratio (i.e. how big the pieces are in relation to the squares on the board)
(define DIV-RATIO (/ SQUARE-SIDE 130))

; Setting the images of the pieces
; Pawns
(define B-PAWN-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn
(define W-PAWN-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn

; Bishops
(define B-BISHOP-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-bishop.png"))) ; Black bishop
(define W-BISHOP-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-bishop.png"))) ; White bishop

; Kings
(define B-KING-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-king.png"))) ; Black king
(define W-KING-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-king.png"))) ; White king

; Queens
(define B-QUEEN-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-queen.png"))) ; Black queen
(define W-QUEEN-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-queen.png"))) ; White queen

; Rooks
(define B-ROOK-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-rook.png"))) ; Black rook
(define W-ROOK-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-rook.png"))) ; White rook

; Knights
(define B-KNIGHT-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-knight.png"))) ; Black knight
(define W-KNIGHT-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-knight.png"))) ; White knight

; Defining the images dimensions
(define pawn-width (image-width B-PAWN-IMAGE))   ; Pawn width
(define pawn-height (image-height B-PAWN-IMAGE)) ; Pawn height

(define bishop-width (image-width B-BISHOP-IMAGE))   ; Bishop width
(define bishop-height (image-height B-BISHOP-IMAGE)) ; Bishop height

(define king-width (image-width B-KING-IMAGE))   ; King width
(define king-height (image-height B-KING-IMAGE)) ; King height

(define queen-width (image-width B-QUEEN-IMAGE))   ; Queen width
(define queen-height (image-height B-QUEEN-IMAGE)) ; Queen height

(define rook-width (image-width B-ROOK-IMAGE))   ; Rook width
(define rook-height (image-height B-ROOK-IMAGE)) ; Rook height

(define knight-width (image-width B-KNIGHT-IMAGE))   ; Knight width
(define knight-height (image-height B-KNIGHT-IMAGE)) ; Knight height

;; STARTING PIECES
; WHITES
(define W-PAWN (make-piece "pawn" (make-posn 0 1) #f 2 "white" #f W-PAWN-IMAGE pawn-width pawn-height #t ))
(define W-KING (make-piece "king" KING-QUEEN-MOVES #f 2 "white" #f W-KING-IMAGE king-width king-height #t))
(define W-QUEEN (make-piece "queen" KING-QUEEN-MOVES #t 2 "white" #f W-QUEEN-IMAGE queen-width queen-height #t))
(define W-BISHOP (make-piece "bishop" DIAGONAL-MOVES #t 2 "white" #f W-BISHOP-IMAGE bishop-width bishop-height #t))
(define W-ROOK (make-piece "rook" ROOK-MOVES #t 2 "white" #f W-ROOK-IMAGE rook-width rook-height #t))
(define W-KNIGHT (make-piece "knight" KNIGHT-MOVES #t 2 "white" #f W-KNIGHT-IMAGE knight-width knight-height #t))

; BLACK
(define B-PAWN (make-piece "pawn" (make-posn 0 1) #f 1 "black" #f B-PAWN-IMAGE pawn-width pawn-height #t))
(define B-KING (make-piece "king" KING-QUEEN-MOVES #f 1 "black" #f B-KING-IMAGE king-width king-height #t))
(define B-QUEEN (make-piece "queen" KING-QUEEN-MOVES #t 1 "black" #f B-QUEEN-IMAGE queen-width queen-height #t))
(define B-BISHOP (make-piece "bishop" DIAGONAL-MOVES #t 1 "black" #f B-BISHOP-IMAGE bishop-width bishop-height #t))
(define B-ROOK (make-piece "rook" ROOK-MOVES #t 1 "black" #f B-ROOK-IMAGE rook-width rook-height #t))
(define B-KNIGHT (make-piece "knight" KNIGHT-MOVES #t 1 "black" #f B-KNIGHT-IMAGE knight-width knight-height #t))

; Board, with initial 
(define BOARD-VECTOR
  (vector
    (vector B-ROOK B-KNIGHT B-BISHOP B-QUEEN B-KING B-BISHOP B-KNIGHT B-ROOK)
    (vector B-PAWN B-PAWN B-PAWN B-PAWN B-PAWN B-PAWN B-PAWN B-PAWN)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector W-PAWN W-PAWN W-PAWN W-PAWN W-PAWN W-PAWN W-PAWN W-PAWN)
    (vector W-ROOK W-KNIGHT W-BISHOP W-QUEEN W-KING W-BISHOP W-KNIGHT W-ROOK)))

; in-bounds : Posn -> Boolean
; checks if position is inside chess board
; header: (define (in-bounds? (make-posn 5 5) #true))
(define (in-bounds? pos)
  (and (>= (posn-x pos) 0)
       (< (posn-x pos) 8)
       (>= (posn-y pos) 0)
       (< (posn-y pos) 8)))

(check-expect (in-bounds? (make-posn 8 8)) #false)
(check-expect (in-bounds? (make-posn 7 8)) #false)
(check-expect (in-bounds? (make-posn 0 0)) #true)
(check-expect (in-bounds? (make-posn 5 4)) #true)

; move-piece : Posn Posn -> void
; moves piece from original posn position to new position, and mutates BOARD-VECTOR accordingly
(define (move-piece current-posn new-posn)
  (begin
    (checkmate new-posn)
    (set-piece new-posn)
    (set-null current-posn)))

;; HELPER FUNCTIONS FOR 'move-piece'
; checkamte
; checks for checkmate, if so, end game.
(define (checkmate position)
  (cond
    [(= "KING" (piece-type (get-piece position))) (displayln "CHECKMATE! Press q to return to home screen.")]
    [else (void)]))

; set-piece: Posn -> void
(define (set-piece position)
  (vector-set! (vector-ref BOARD-VECTOR (posn-y position)) (posn-x position) (get-piece position)))

; set-null : Posn -> void
(define (set-null position)
    (vector-set! (vector-ref BOARD-VECTOR (posn-y position)) (posn-x position) 0))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; HELPER FUNCTIONS
; get-piece : Posn -> Maybe<Piece>
; return the piece at the determined position
; header: (define (get-piece (make-posn 0 0) BLACK-ROOK)

; template:
; (define (get-piece position)
;  (... BOARD-VECTOR ... position))
(define (get-piece position)
  (vector-ref (vector-ref BOARD-VECTOR (posn-y position)) (posn-x position)))

; examples
(check-expect (get-piece (make-posn 0 3)) 0)

; my-piece? : Piece -> Boolean
; checks if piece is of the local player, based on the player number on piece
(define (my-piece? piece)
  (cond
    [(equal? (piece-player piece) 1) #true]
    [else #false]))

; is-there-piece? : Posn -> Boolean
; checks whether there's a piece in the specified position
; header: (define (is-there-piece? (make-posn 0 0)) #true)

; template:
; (define (is-there-piece? position)
;  (cond
;    [...position... #true]
;    [else #false]))

(define (is-there-piece? position)
  (cond
    [(piece? (get-piece position)) #true]
    [else #false]))

(check-expect (is-there-piece? (make-posn 1 1)) #true)
(check-expect (is-there-piece? (make-posn 5 5)) #false)
(check-expect (is-there-piece? (make-posn 7 7)) #true)

; is-there-opponent-piece? : Posn -> Boolean
; checkes whether there's an opponent piece in the specified position
; header: (define (is-there-opponent-piece? position)

; template
; (define (is-there-opponent-piece? position)
;  (cond
;    [... position ... #true]
;    [else #false]))
(define (is-there-opponent-piece? position)
  (cond
    [(and (in-bounds? position) (piece? (get-piece position)) (= 2 (piece-player (get-piece position)))) #true]
    [else #false]))

(check-expect (is-there-opponent-piece? (make-posn 1 1)) #false)
(check-expect (is-there-opponent-piece? (make-posn 5 5)) #false)
(check-expect (is-there-opponent-piece? (make-posn 7 7)) #true)
(check-expect (is-there-opponent-piece? (make-posn 8 8)) #false)


; move-one-forward? : Posn -> Boolean
; checks whether the piece can move one position forward
; header: (define (move-one-forward? (make-posn 0 0)) #false)
(define (move-one-forward? position)
  (local [(define new-posn (make-posn (posn-x position) (add1 (posn-y position))))]
    (cond
      [(and (not (is-there-piece? new-posn)) (in-bounds? new-posn)) #true]
      [else #false])))

(check-expect (move-one-forward? (make-posn 1 2)) #true)
(check-expect (move-one-forward? (make-posn 7 6)) #false)


; move-one-forward: Posn -> Posn
; returns the position when the piece moves by one forward.
; header: (define (move-one-forward (make-posn 0 0) (make-posn 0 1))
(define (move-one-forward position)
  (make-posn (posn-x position) (add1(posn-y position))))

; move-two-forward? : Posn -> Boolean
; checks whether the piece can move by two forward (can only move if there is not a piece and is at starting point!)
; header: (define (move-one-forward? (make-posn 0 0)) #false)

; template
; (define (move-two-forward? position)
;  (local [(define new-posn (...position...))]
;    (cond
;      [(...new-posn...position...) #true]
;      [else #false])))

(define (move-two-forward? position)
  (local [(define new-posn (make-posn (posn-x position) (+ 2 (posn-y position))))]
    (cond
      [(and (not (is-there-piece? new-posn))
            (= 1 (posn-y position))
            (in-bounds? new-posn)) #true]
      [else #false])))

(check-expect (move-two-forward? (make-posn 1 1)) #true)
(check-expect (move-two-forward? (make-posn 1 2)) #false)
(check-expect (move-two-forward? (make-posn 7 5)) #false)

; move-left-diagonal? : Posn -> Boolean
; checks whether the piece can move diagonally left by one place
; header: (define (move-left-diagonal? (make-posn 0 0)) #false)

; template:
; (define (move-left-diagonal? position)
;  (cond
;    [(...position...) #false]
;    [else #true]))

(define (move-left-diagonal? position)
  (cond
    [(not(is-there-opponent-piece? (make-posn (sub1(posn-x position)) (add1(posn-y position))))) #false]
    [else #true]))

(check-expect (move-left-diagonal? (make-posn 2 2)) #false)
(check-expect (move-left-diagonal? (make-posn 4 3)) #false)
(check-expect (move-left-diagonal? (make-posn 5 5)) #true)

(define (move-left-diagonal position)
  (make-posn (sub1(posn-x position)) (add1(posn-y position))))

; examples
(check-expect (move-left-diagonal? (make-posn 2 2)) #false)
(check-expect (move-left-diagonal? (make-posn 4 3)) #false)
(check-expect (move-left-diagonal? (make-posn 5 5)) #true)

; move-right-diagonal? : Posn -> Boolean
; checks whether the piece can move diagonally right by one place
; header: (define (move-right-diagonal? (make-posn 0 0)) #false)

; template:
; (define (move-right-diagonal? position)
;  (cond
;    [(...position...) #false]
;    [else #true]))

(define (move-right-diagonal? position)
  (cond
    [(not(is-there-opponent-piece? (make-posn (add1(posn-x position)) (add1(posn-y position))))) #false]
    [else #true]))

(define (move-right-diagonal position)
  (make-posn (add1(posn-x position)) (add1(posn-y position))))

; examples:
(check-expect (move-right-diagonal? (make-posn 2 2)) #false)
(check-expect (move-right-diagonal? (make-posn 4 3)) #false)
(check-expect (move-right-diagonal? (make-posn 5 5)) #true)

;;;;;;;;;;;;;;;
;; PAWN ONLY ;;
;;;;;;;;;;;;;;;

; possible-pawn-moves : List<Posn> Posn -> List<Posn>
; returns list of possible moves for pawns
; header: (define (possible-pawn-moves (cons ()) (make-posn 1 0)) (cons ()))

(define (possible-pawn-moves possible-moves current-position)
  (local [(define row (posn-y current-position))
          (define col (posn-x current-position))
          (define piece (get-piece current-position))
          
          ; Forward moves
          (define forward-pos (make-posn col (+ row 1)))
          (define two-forward-pos (make-posn col (+ row 2)))
          
          ; Diagonal captures
          (define right-diag (make-posn (+ col 1) (+ row 1)))
          (define left-diag (make-posn (- col 1) (+ row 1)))]
    
    (let ([moves '()])
      ; Add forward move if square is empty
      (when (and (in-bounds? forward-pos)
                 (not (is-there-piece? forward-pos)))
        (set! moves (cons forward-pos moves))
        
        ; Add two-square move if at starting position and path is clear
        (when (and (or (and (equal? (piece-color piece) "white") (= row 6))
                       (and (equal? (piece-color piece) "black") (= row 1)))
                  (in-bounds? two-forward-pos)
                  (not (is-there-piece? two-forward-pos)))
          (set! moves (cons two-forward-pos moves))))
      
      ; Add diagonal captures
      (when (and (in-bounds? right-diag)
                 (is-there-piece? right-diag)
                 (not (equal? (piece-color piece)
                            (piece-color (get-piece right-diag)))))
        (set! moves (cons right-diag moves)))
      
      (when (and (in-bounds? left-diag)
                 (is-there-piece? left-diag)
                 (not (equal? (piece-color piece)
                            (piece-color (get-piece left-diag)))))
        (set! moves (cons left-diag moves)))
      
      (append possible-moves moves))))

; examples
(check-expect (possible-pawn-moves '() (make-posn 3 1)) (list (make-posn 3 2) (make-posn 3 3))) ; starting position
(check-expect (possible-pawn-moves '() (make-posn 3 2)) (list (make-posn 3 3)))
(check-expect (possible-pawn-moves '() (make-posn 5 5)) (list (make-posn 6 6) (make-posn 4 6)))

;;;;;;;;;;;;;;;;;;;
;; NON-PAWN ONLY ;;
;;;;;;;;;;;;;;;;;;;

; CASTLING
; can-move-two-right?
; checks whether the king can move two places to the right. 
(define (can-move-two-right? current-position)
  (local [(define first-posn (make-posn (add1 (posn-x current-position)) (posn-x current-position)))
          (define second-posn (make-posn (add1 (posn-x first-posn)) (posn-x first-posn)))]
    (cond
      [(and (false? (is-there-piece? first-posn) (false? (is-there-piece? second-posn)))) #true]
      [else #false])))

; can-move-two-left?
(define (can-move-two-left? current-position)
  (local [(define first-posn (make-posn (sub1 (posn-x current-position)) (posn-x current-position)))
          (define second-posn (make-posn (sub1 (posn-x first-posn)) (posn-x first-posn)))]
    (cond
      [(and (boolean=? #false (is-there-piece? first-posn) (boolean=? #false (is-there-piece? second-posn)))) #true]
      [else #false])))

; can-castle-right?
(define (can-castle-right? current-position)
  (cond
    [(and (= 0 (posn-x current-position)) (= 4 (posn-y current-position)) (= "rook" (piece-type (get-piece (make-posn 0 7)))) (can-move-two-right? current-position)) #true]
    [else #false]))

; can-castle-left?
(define (can-castle-left? current-position)
  (cond
    [(and (= 0 (posn-x current-position)) (= 4 (posn-y current-position)) (= "rook" (piece-type (get-piece (make-posn 0 0)))) (can-move-two-left? current-position)) #true]
    [else #false]))

; castling: Posn -> Maybe<List>
; returns a list with moves for castling, if possible. Otherwise, returns #false.
; header: (define (castling (make-posn 0 4)) #false)
(define (castling current-position)
  (local [(define right (can-castle-right? current-position))
          (define left (can-castle-left? current-position))]
  (cond
    [(and (boolean=? #true right) (boolean=? #true left)) (list (make-posn 0 6) (make-posn 0 4))]
    [(boolean=? #true right) (list (make-posn 0 6))]
    [(boolean=? #true left) (list (make-posn 0 4))]
    [else #false])))


; KING MOVES
; calculate-all-kings-moves: 
(define (calculate-all-kings-moves current-position movements is-repeatable)
  (local [(define CASTLING-LIST (castling current-position))
          (define KING-MOVES (calculate-all-moves current-position movements is-repeatable))]
    (cond
      [(boolean? CASTLING-LIST) KING-MOVES]
      [else (append CASTLING-LIST KING-MOVES)])))

; can-promote-pawn?
; checks whether pawn can be promoted to a Queen based on 'current-position'
(define (can-promote-pawn? current-positon)
  (cond
    [= 7 (posn-y current-positon) #true]
    [else #false]))

; promote-pawn
; promotes the pawn to a Queen in the 'current-position' posn. 
(define (promote-pawn current-position)
  (vector-set! (vector-ref BOARD-VECTOR (posn-y current-position)) (posn-x current-position) B-QUEEN))

; GENERAL
; calculate-move : List<Posn>, Posn, Boolean -> List<Posn>
; calculates possible moves based on single 'move' and 'current position'
; header:

; template:

(define (calculate-move new-moves move current-position is-repeatable)
  (local [(define new-posn (make-posn (+ (posn-x move) (posn-x current-position))
                                      (+ (posn-y move) (posn-y current-position))))]
    (cond
      [(and (in-bounds? new-posn)
            (or (not (is-there-piece? new-posn))
                (is-there-opponent-piece? new-posn)))
       (if (is-there-piece? new-posn)
           (append new-moves (list new-posn)) ; Stop if there's a piece
           (if is-repeatable
               (calculate-move (append new-moves (list new-posn)) move new-posn is-repeatable)
               (append new-moves (list new-posn))))]
      [else new-moves])))

; examples:
(check-expect (calculate-move '() (make-posn 1 0) (make-posn 2 3) true) (list (make-posn 3 3) (make-posn 4 3) (make-posn 5 3) (make-posn 6 3) (make-posn 7 3)))
(check-expect (calculate-move '() (make-posn 2 1) (make-posn 2 3) false) (list (make-posn 4 4)))

; calculate-all-moves : Posn, List<Posn>, Boolean -> List<List<Posn>>
; from position and type of movement of piece, returns possible moves
; used for non-pawn pieces
; header: (define (possible-moves (make-posn 1 0) KING-QUEEN-MOVES true) '((posn 1 2) (posn 1 3)))

; template:

(define (calculate-all-moves current-position movements is-repeatable)
  (apply append
         (map (lambda (move) (calculate-move '() move current-position is-repeatable))
              movements)))

; examples:
(calculate-all-moves (make-posn 3 1) DIAGONAL-MOVES true)
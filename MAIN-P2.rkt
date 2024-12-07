;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname MAIN-P2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;%%%%%%%%%%%%%%%%%%%%;
;#### CHESS GAME ####;
;%%%%%%%%%%%%%%%%%%%%;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Libraries ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)
(require "logic.rkt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Data type ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; a Piece is a structure:
; where:
;   type           :    String
;   movements      :    List<Posn>
;   repeatable?    :    Boolean
;   player         :    Number
;   color          :    String
;   dragged?       :    Boolean
;   img            :    Image
;   width          :    Number
;   height         :    Number
;   present?       :    Boolean
(define-struct piece [type movement repeatable? player color dragged? img width height present?] #:transparent)

; a Color is one of the following:
; - "White"
; - "Black"
; interpretation: the possible colors of the pieces

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Constants ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defining the squares colors
(define SQUARE-COLOR-1 "light blue")   ; Color 1
(define SQUARE-COLOR-2 "white") ; Color 2

; Defining the side of the squares
(define SQUARE-SIDE 64)

; Defining the division ratio (i.e. how big the pieces are in relation to the squares on the board)
(define DIV-RATIO (/ SQUARE-SIDE 130))

; Creating the chessboard squares
(define CHESSBOARD-SQUARE-1 (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)) ; Square 1
(define CHESSBOARD-SQUARE-2 (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)) ; Square 2

; Creating a transparent square in which the pieces are placed
(define TRANSPARENT-CHESSBOARD (rectangle (* 8 SQUARE-SIDE) (* 8 SQUARE-SIDE) "solid" "transparent"))

; Defining the rows of the chessboard
; When the first square is color 1
(define CHESSBOARD-ROW-1
  (beside (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)))

; When the first square is color 2
(define CHESSBOARD-ROW-2
  (beside (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-2)
          (rectangle SQUARE-SIDE SQUARE-SIDE "solid" SQUARE-COLOR-1)))

; Creating the chessboard
(define CHESSBOARD
  (above CHESSBOARD-ROW-2
         CHESSBOARD-ROW-1
         CHESSBOARD-ROW-2
         CHESSBOARD-ROW-1
         CHESSBOARD-ROW-2
         CHESSBOARD-ROW-1
         CHESSBOARD-ROW-2
         CHESSBOARD-ROW-1))

; Defining a scene with the empty chessboard
(define EMPTY-CHESSBOARD (overlay CHESSBOARD (empty-scene (* SQUARE-SIDE 8) (* SQUARE-SIDE 8))))

; Setting the images of the pieces
; Pawns
(define B-PAWN1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 1
(define B-PAWN2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 2
(define B-PAWN3-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 3
(define B-PAWN4-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 4
(define B-PAWN5-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 5
(define B-PAWN6-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 6
(define B-PAWN7-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 7
(define B-PAWN8-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-pawn.png"))) ; Black pawn 8

(define W-PAWN1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 1
(define W-PAWN2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 2
(define W-PAWN3-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 3
(define W-PAWN4-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 4
(define W-PAWN5-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 5
(define W-PAWN6-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 6
(define W-PAWN7-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 7
(define W-PAWN8-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-pawn.png"))) ; White pawn 8

; Bishops
(define B-BISHOP1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-bishop.png"))) ; Black bishop 1
(define B-BISHOP2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-bishop.png"))) ; Black bishop 2


(define W-BISHOP1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-bishop.png"))) ; White bishop 1
(define W-BISHOP2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-bishop.png"))) ; White bishop 2

; Kings
(define B-KING-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-king.png"))) ; Black king
(define W-KING-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-king.png"))) ; White king

; Queens
(define B-QUEEN-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-queen.png"))) ; Black queen
(define W-QUEEN-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-queen.png"))) ; White queen

; Rooks
(define B-ROOK1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-rook.png"))) ; Black rook 1
(define B-ROOK2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-rook.png"))) ; Black rook 2

(define W-ROOK1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-rook.png"))) ; White rook 1
(define W-ROOK2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-rook.png"))) ; White rook 2

; Knights
(define B-KNIGHT1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-knight.png"))) ; Black knight 1
(define B-KNIGHT2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-knight.png"))) ; Black knight 2

(define W-KNIGHT1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-knight.png"))) ; White knight 1
(define W-KNIGHT2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-knight.png"))) ; White knight 2

; Defining the images dimensions
(define pawn-width (image-width B-PAWN1-IMAGE))   ; Pawn width
(define pawn-height (image-height B-PAWN1-IMAGE)) ; Pawn height

(define bishop-width (image-width B-BISHOP1-IMAGE))   ; Bishop width
(define bishop-height (image-height B-BISHOP1-IMAGE)) ; Bishop height

(define king-width (image-width B-KING-IMAGE))   ; King width
(define king-height (image-height B-KING-IMAGE)) ; King height

(define queen-width (image-width B-QUEEN-IMAGE))   ; Queen width
(define queen-height (image-height B-QUEEN-IMAGE)) ; Queen height

(define rook-width (image-width B-ROOK1-IMAGE))   ; Rook width
(define rook-height (image-height B-ROOK1-IMAGE)) ; Rook height

(define knight-width (image-width B-KNIGHT1-IMAGE))   ; Knight width
(define knight-height (image-height B-KNIGHT1-IMAGE)) ; Knight height

; Defining the chessboard pieces
; White pawns
(define W-PAWN1 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN1-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN2 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN2-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN3 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN3-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN4 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN4-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN5 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN5-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN6 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN6-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN7 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN7-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN8 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN8-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?

; White king
(define W-KING (make-piece "king" 
                           KING-QUEEN-MOVES
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-KING-IMAGE 
                           king-width 
                           king-height 
                           #t)) ; present?

; White queen
(define W-QUEEN (make-piece "queen" 
                           KING-QUEEN-MOVES
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-QUEEN-IMAGE 
                           queen-width 
                           queen-height 
                           #t)) ; present?

; White bishops
(define W-BISHOP1 (make-piece "bishop" 
                           DIAGONAL-MOVES
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-BISHOP1-IMAGE 
                           bishop-width 
                           bishop-height 
                           #t)) ; present?
(define W-BISHOP2 (make-piece "bishop" 
                           DIAGONAL-MOVES
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-BISHOP1-IMAGE 
                           bishop-width 
                           bishop-height 
                           #t)) ; present?

; White rooks
(define W-ROOK1 (make-piece "rook" 
                           ROOK-MOVES
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-ROOK1-IMAGE 
                           rook-width 
                           rook-height 
                           #t)) ; present?
(define W-ROOK2 (make-piece "rook" 
                           ROOK-MOVES
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-ROOK2-IMAGE 
                           rook-width 
                           rook-height 
                           #t)) ; present?

; White knights
(define W-KNIGHT1 (make-piece "knight" 
                           KNIGHT-MOVES
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-KNIGHT1-IMAGE 
                           knight-width 
                           knight-height 
                           #t)) ; present?
(define W-KNIGHT2 (make-piece "knight" 
                           KNIGHT-MOVES
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-KNIGHT2-IMAGE 
                           knight-width 
                           knight-height 
                           #t)) ; present?

; Black pawns
(define B-PAWN1 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN1-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN2 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN2-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN3 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN3-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN4 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN4-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN5 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN5-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN6 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN6-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN7 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN7-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN8 (make-piece "pawn" 
                           VERTICAL-MOVES
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN8-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?

; Black king
(define B-KING (make-piece "king" 
                           KING-QUEEN-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-KING-IMAGE 
                           king-width 
                           king-height 
                           #t)) ; present?

; Black queen
(define B-QUEEN (make-piece "queen" 
                           KING-QUEEN-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-QUEEN-IMAGE 
                           queen-width 
                           queen-height 
                           #t)) ; present?

; Black bishops
(define B-BISHOP1 (make-piece "bishop" 
                           DIAGONAL-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-BISHOP1-IMAGE 
                           bishop-width 
                           bishop-height 
                           #t)) ; present?
(define B-BISHOP2 (make-piece "bishop" 
                           DIAGONAL-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-BISHOP1-IMAGE 
                           bishop-width 
                           bishop-height 
                           #t)) ; present?

; Black rooks
(define B-ROOK1 (make-piece "rook" 
                           ROOK-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-ROOK1-IMAGE 
                           rook-width 
                           rook-height 
                           #t)) ; present?
(define B-ROOK2 (make-piece "rook" 
                           ROOK-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-ROOK2-IMAGE 
                           rook-width 
                           rook-height 
                           #t)) ; present?

; Black knights
(define B-KNIGHT1 (make-piece "knight" 
                           KNIGHT-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-KNIGHT1-IMAGE 
                           knight-width 
                           knight-height 
                           #t)) ; present?
(define B-KNIGHT2 (make-piece "knight" 
                           KNIGHT-MOVES
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-KNIGHT2-IMAGE 
                           knight-width 
                           knight-height 
                           #t)) ; present?

; Defining INITIAL-STATE
(define INITIAL-STATE 
  (vector
    ; Row 1 - White Special Pieces row
    (vector 
      (make-piece "rook" ROOK-MOVES #t 2 "white" #f W-ROOK1-IMAGE rook-width rook-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 2 "white" #f W-KNIGHT1-IMAGE knight-width knight-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 2 "white" #f W-BISHOP1-IMAGE bishop-width bishop-height #t)
      (make-piece "queen" KING-QUEEN-MOVES #t 2 "white" #f W-QUEEN-IMAGE queen-width queen-height #t)
      (make-piece "king" KING-QUEEN-MOVES #f 2 "white" #f W-KING-IMAGE king-width king-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 2 "white" #f W-BISHOP2-IMAGE bishop-width bishop-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 2 "white" #f W-KNIGHT2-IMAGE knight-width knight-height #t)
      (make-piece "rook" ROOK-MOVES #t 2 "white" #f W-ROOK2-IMAGE rook-width rook-height #t))
    
    ; Row 2 - White pawns
    (vector 
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN1-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN2-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN3-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN4-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN5-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN6-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN7-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN8-IMAGE pawn-width pawn-height #t))
    
    ; Rows 2-5 - Empty spaces
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)

    ; Row 8 - Black pawns
    (vector 
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN1-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN2-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN3-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN4-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN5-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN6-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN7-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN8-IMAGE pawn-width pawn-height #t))

    ; Row 0 - Black Special Pieces row
    (vector 
      (make-piece "rook" ROOK-MOVES #t 1 "black" #f B-ROOK1-IMAGE rook-width rook-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 1 "black" #f B-KNIGHT1-IMAGE knight-width knight-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 1 "black" #f B-BISHOP1-IMAGE bishop-width bishop-height #t)
      (make-piece "queen" KING-QUEEN-MOVES #t 1 "black" #f B-QUEEN-IMAGE queen-width queen-height #t)
      (make-piece "king" KING-QUEEN-MOVES #f 1 "black" #f B-KING-IMAGE king-width king-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 1 "black" #f B-BISHOP2-IMAGE bishop-width bishop-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 1 "black" #f B-KNIGHT2-IMAGE knight-width knight-height #t)
      (make-piece "rook" ROOK-MOVES #t 1 "black" #f B-ROOK2-IMAGE rook-width rook-height #t))))
    

    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Functions ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; inside-image? ;;;;;

;; Input/Output
; inside-image? : Number Number Piece -> Boolean
; checks if the mouse click is within the image's clickable area

;; Examples
(check-expect (inside-image? 10 10 B-PAWN1) #f)
(check-expect (inside-image? 10 10 W-BISHOP2) #f)
(check-expect (inside-image? (/ (* SQUARE-SIDE 9) 2) (/ SQUARE-SIDE 2) B-KING) #t)

;; Implementation
(define (inside-image? mouse-x mouse-y piece)
  (let ([piece-x (* (posn-x (piece-movement piece)) SQUARE-SIDE)]
        [piece-y (* (posn-y (piece-movement piece)) SQUARE-SIDE)])
    (and (>= mouse-x (- piece-x (/ (piece-width piece) 2)))
         (<= mouse-x (+ piece-x (/ (piece-width piece) 2)))
         (>= mouse-y (- piece-y (/ (piece-height piece) 2)))
         (<= mouse-y (+ piece-y (/ (piece-height piece) 2))))))

;;;;; highlight-piece ;;;;;

; Helper function to highlight the selected piece

(define (highlight-piece piece scene x y)
  (let ([img (if (eq? piece selected-piece)
                 (overlay 
                  (overlay  ; Multiple overlays to create thicker border
                   (rectangle SQUARE-SIDE SQUARE-SIDE "outline" "Gold")
                   (rectangle (- SQUARE-SIDE 1) (- SQUARE-SIDE 1) "outline" "Gold")
                   (rectangle (- SQUARE-SIDE 2) (- SQUARE-SIDE 2) "outline" "Gold")
                   (rectangle (- SQUARE-SIDE 3) (- SQUARE-SIDE 3) "outline" "Gold")
                   (rectangle (- SQUARE-SIDE 4) (- SQUARE-SIDE 4) "outline" "Gold"))
                  (piece-img piece))
                 (piece-img piece))])
    (place-image img
                (+ (* x SQUARE-SIDE) (/ SQUARE-SIDE 2))
                (+ (* y SQUARE-SIDE) (/ SQUARE-SIDE 2))
                scene)))

;;;;; vector-to-list-of-lists ;;;;;

;; Implementation
(define (vector-to-list-of-lists vector-board)
  (map vector->list (vector->list vector-board)))

;;;;; piece-current-pos ;;;;;

; Helper function to find a piece's current position in the board

;; Implementation
(define (piece-current-pos target-piece)
  (let find-pos ([row 0])
    (if (< row 8)
        (let find-col ([col 0])
          (if (< col 8)
              (let ([current-piece (vector-ref (vector-ref BOARD-VECTOR row) col)])
                (if (eq? current-piece target-piece)
                    (make-posn col row)
                    (find-col (add1 col))))
              (find-pos (add1 row))))
        (make-posn 0 0)))) ; fallback position if piece is not found

;;;;; find-king ;;;;;

; Helper function to find a king's position

;; Implementation
(define (find-king color state)
  (let find-pos ([row 0])
    (if (< row 8)
        (let find-col ([col 0])
          (if (< col 8)
              (let ([piece (vector-ref (vector-ref state row) col)])
                (if (and (piece? piece)
                         (equal? (piece-type piece) "king")
                         (equal? (piece-color piece) color))
                    (make-posn col row)
                    (find-col (add1 col))))
              (find-pos (add1 row))))
        #f)))

;;;;; king-in-check? ;;;;;

; Helper function to check if a king is in check

;; Implementation
(define (king-in-check? king-color state)
  (let ([king-pos (find-king king-color state)])
    (let check-pieces ([row 0])
      (if (< row 8)
          (let check-col ([col 0])
            (if (< col 8)
                (let ([piece (vector-ref (vector-ref state row) col)])
                  (if (and (piece? piece)
                           (piece-present? piece)
                           (not (equal? (piece-color piece) king-color))
                           (member king-pos (get-valid-moves piece (make-posn col row) state)))
                      #t
                      (check-col (add1 col))))
                (check-pieces (add1 row))))
          #f))))

;;;;; get-attack-path ;;;;;

; Returns the path between the attacking piece and the king

;; Implementation
(define (get-attack-path attacker-pos king-pos)
  (let* ([dx (- (posn-x king-pos) (posn-x attacker-pos))]
         [dy (- (posn-y king-pos) (posn-y attacker-pos))]
         [step-x (if (= dx 0) 0 (/ dx (abs dx)))]
         [step-y (if (= dy 0) 0 (/ dy (abs dy)))])
    (let loop ([current-pos attacker-pos]
               [path '()])
      (if (and (not (equal? current-pos king-pos))
               (in-bounds? current-pos))
          (let ([next-pos (make-posn (+ (posn-x current-pos) step-x)
                                    (+ (posn-y current-pos) step-y))])
            (loop next-pos (cons current-pos path)))
          (cons current-pos path)))))

(define (get-check-path state king-color)
  (let* ([king-pos (find-king king-color state)]
         [attacking-pieces 
          (filter (lambda (pos)
                   (let ([piece (vector-ref (vector-ref state (posn-y pos)) (posn-x pos))])
                     (and (piece? piece)
                          (piece-present? piece)
                          (not (equal? (piece-color piece) king-color))
                          (member king-pos (get-valid-moves piece pos state)))))
                 (build-list 64 
                           (lambda (i) 
                             (make-posn (remainder i 8) (quotient i 8)))))])
    (if (= (length attacking-pieces) 1) ; Only consider single attacker cases
        (let* ([attacker-pos (first attacking-pieces)]
               [dx (- (posn-x king-pos) (posn-x attacker-pos))]
               [dy (- (posn-y king-pos) (posn-y attacker-pos))]
               [step-x (if (= dx 0) 0 (/ dx (abs dx)))]
               [step-y (if (= dy 0) 0 (/ dy (abs dy)))]
               [steps (max (abs dx) (abs dy))]
               [path-positions
                (build-list (sub1 steps)
                           (lambda (i)
                             (make-posn (+ (posn-x attacker-pos) (* (add1 i) step-x))
                                      (+ (posn-y attacker-pos) (* (add1 i) step-y)))))])
          (cons attacker-pos path-positions))
        '())))

;;;;; render ;;;;;

;; Implementation
(define (render state)
  (let* ([scene EMPTY-CHESSBOARD]
         [scene-with-pieces
          (foldl (lambda (row-idx scene)
                   (foldl (lambda (col-idx scene)
                            (let ([piece (vector-ref (vector-ref state row-idx) col-idx)])
                              (if (and (piece? piece) (piece-present? piece))
                                  (if (and (equal? (piece-type piece) "king")
                                         (king-in-check? (piece-color piece) state))
                                      ; Highlight king in check with red border
                                      (place-image 
                                       (overlay
                                        (overlay
                                         (rectangle SQUARE-SIDE SQUARE-SIDE "outline" "red")
                                         (rectangle (- SQUARE-SIDE 1) (- SQUARE-SIDE 1) "outline" "red")
                                         (rectangle (- SQUARE-SIDE 2) (- SQUARE-SIDE 2) "outline" "red")
                                         (rectangle (- SQUARE-SIDE 3) (- SQUARE-SIDE 3) "outline" "red")
                                         (rectangle (- SQUARE-SIDE 4) (- SQUARE-SIDE 4) "outline" "red"))
                                        (piece-img piece))
                                       (+ (* col-idx SQUARE-SIDE) (/ SQUARE-SIDE 2))
                                       (+ (* row-idx SQUARE-SIDE) (/ SQUARE-SIDE 2))
                                       scene)
                                      ; Normal piece rendering
                                      (highlight-piece piece scene col-idx row-idx))
                                  scene)))
                          scene
                          (build-list 8 values)))
                 scene
                 (build-list 8 values))])
    ; Add winning message if game is over
    (if game-over
        (place-image (text "Player 1 Wins!" 40 "red")
                    (* SQUARE-SIDE 4)  ; Center horizontally
                    (* SQUARE-SIDE 4)  ; Center vertically
                    scene-with-pieces)
        ; If game isn't over, continue with normal rendering
        (if selected-piece
            (let* ([valid-moves (get-valid-moves selected-piece selected-pos state)]
                   [check-path (if (and (not (equal? (piece-type selected-piece) "king"))
                                      (king-in-check? (piece-color selected-piece) state))
                                 (get-check-path state (piece-color selected-piece))
                                 '())])
              (foldl (lambda (move scene)
                      (place-image 
                       (cond
                         ; King moves that would still be in check
                         [(and (equal? (piece-type selected-piece) "king")
                               (would-be-in-check? selected-piece selected-pos move state))
                          (circle 8 "solid" "red")]
                         ; Moves that block the check
                         [(and (not (equal? (piece-type selected-piece) "king"))
                               (member move check-path)
                               (not (would-be-in-check? selected-piece selected-pos move state)))
                          (circle 8 "solid" "Green Yellow")]
                         ; All other valid moves
                         [else (circle 8 "solid" "gray")])
                       (+ (* (posn-x move) SQUARE-SIDE) (/ SQUARE-SIDE 2))
                       (+ (* (posn-y move) SQUARE-SIDE) (/ SQUARE-SIDE 2))
                       scene))
                    scene-with-pieces
                    valid-moves))
            scene-with-pieces))))

;;;;; would-be-in-check? ;;;;;

; checks if a move would put the king in check

;; Implementation
(define (would-be-in-check? piece orig-pos new-pos state)
  (let* ([test-state (vector-copy-deep state)]
         [orig-row (posn-y orig-pos)]
         [orig-col (posn-x orig-pos)]
         [new-row (posn-y new-pos)]
         [new-col (posn-x new-pos)])
    ; Make the move on the test board
    (vector-set! (vector-ref test-state orig-row) orig-col 0)
    (vector-set! (vector-ref test-state new-row) new-col piece)
    ; Check if the king would be in check after this move
    (king-in-check? (piece-color piece) test-state)))

;;;;; vector-copy-deep ;;;;;

; Helper function to deep copy a vector (needed for the test board)

;; Implementation
(define (vector-copy-deep v)
  (let* ([len (vector-length v)]
         [new-vec (make-vector len)])
    (define (copy-elements! i)
      (if (< i len)
          (begin
            (vector-set! new-vec i
                        (if (vector? (vector-ref v i))
                            (vector-copy-deep (vector-ref v i))
                            (vector-ref v i)))
            (copy-elements! (add1 i)))
          new-vec))
    (copy-elements! 0)))

;;;;; which-square? ;;;;;

;; Input/Output
; which-square? : Number Number -> Posn
; Converts mouse coordinates to board position
; header: (define (which-square? Piece) (make-posn 1 1))

;; Implementation
(define (which-square? x y)
  (make-posn (floor (/ x SQUARE-SIDE))
             (floor (/ y SQUARE-SIDE))))

;;;;; same-color? ;;;;;

;; Input/Output
; same-color? : Piece Piece -> Boolean
; says if two pieces have the same color
; header: (define (same-color? dragged-piece pieces) #true)

;; Implementation
(define (same-color? dragged-piece piece)
  (and (piece-present? dragged-piece)
       (piece-present? piece)
       (equal? (piece-color dragged-piece) (piece-color piece))))

;;;;; make-transparent ;;;;;

;; Input/Output
; make-transparent : Piece -> Piece
; makes a piece with 'present?' sets to #false transparent
; header: (define (make-trasnparent eaten-piece) B-PAWN1)

;; Implementation
(define (make-transparent piece)
  (if (false? (piece-present? piece))
      (make-piece (piece-type piece)
                  (piece-movement piece)
                  (piece-repeatable? piece)
                  (piece-player piece)
                  (piece-color piece)
                  (piece-dragged? piece)
                  (rectangle 0 0 "solid" "transparent")
                  (piece-width piece)
                  (piece-height piece)
                  (piece-present? piece))
      piece)) ; Return unchanged if present? is true

;; Implementation
(define (eaten-piece current-pos target-pos)
  (let ([target-piece (get-piece target-pos)])
    (when (and target-piece 
               (piece? target-piece)
               (not (equal? (piece-color (get-piece current-pos))
                          (piece-color target-piece))))
      (move-piece current-pos target-pos))))

;;;;; Handle mouse events ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define selected-piece #f)

(define selected-pos #f)

(define game-over #f)

;;;;; handle-move ;;;;;

;; Implementation
(define (handle-move state target-pos)
  (let* ([target-row (posn-y target-pos)]
         [target-col (posn-x target-pos)]
         [target-piece (vector-ref (vector-ref state target-row) target-col)]
         [orig-row (posn-y selected-pos)]
         [orig-col (posn-x selected-pos)]
         [valid-moves (get-valid-moves selected-piece selected-pos state)])
    (if (and (piece? selected-piece)
             (member target-pos valid-moves)
             (or (not (piece? target-piece))
                 (not (same-color? selected-piece target-piece))))
        (begin
          ; Check for castling
          (if (and (equal? (piece-type selected-piece) "king")
                   (not (piece-dragged? selected-piece))
                   (or (and (= target-col (+ orig-col 2))
                            (let ([rook (vector-ref (vector-ref state orig-row) 7)])
                              (and (piece? rook)
                                   (equal? (piece-type rook) "rook")
                                   (not (piece-dragged? rook)))))
                       (and (= target-col (- orig-col 3))
                            (let ([rook (vector-ref (vector-ref state orig-row) 0)])
                              (and (piece? rook)
                                   (equal? (piece-type rook) "rook")
                                   (not (piece-dragged? rook)))))))
              (begin
                ; Perform castling
                (let ([rook-col (if (= target-col (+ orig-col 2)) 7 0)]
                      [new-rook-col (if (= target-col (+ orig-col 2)) (- target-col 1) (+ target-col 1))])
                  ; Move king
                  (vector-set! (vector-ref state orig-row) orig-col 0)
                  (vector-set! (vector-ref state target-row) target-col
                               (make-piece (piece-type selected-piece)
                                           (piece-movement selected-piece)
                                           (piece-repeatable? selected-piece)
                                           (piece-player selected-piece)
                                           (piece-color selected-piece)
                                           #t
                                           (piece-img selected-piece)
                                           (piece-width selected-piece)
                                           (piece-height selected-piece)
                                           #t))
                  ; Move rook
                  (let ([rook (vector-ref (vector-ref state orig-row) rook-col)])
                    (vector-set! (vector-ref state orig-row) rook-col 0)
                    (vector-set! (vector-ref state target-row) new-rook-col
                                 (make-piece (piece-type rook)
                                             (piece-movement rook)
                                             (piece-repeatable? rook)
                                             (piece-player rook)
                                             (piece-color rook)
                                             #t
                                             (piece-img rook)
                                             (piece-width rook)
                                             (piece-height rook)
                                             #t)))))
              ; Normal move or promotion
              (begin
                ; Clear original position
                (vector-set! (vector-ref state orig-row) orig-col 0)
                ; Check for pawn promotion
                (let ([new-piece 
                      (if (and (equal? (piece-type selected-piece) "pawn")
                              (or (and (equal? (piece-color selected-piece) "white") (= target-row 7))
                                  (and (equal? (piece-color selected-piece) "black") (= target-row 0))))
                          ; Promote to queen
                          (make-piece "queen"
                                    KING-QUEEN-MOVES
                                    #t
                                    (piece-player selected-piece)
                                    (piece-color selected-piece)
                                    #t
                                    (if (equal? (piece-color selected-piece) "white")
                                        W-QUEEN-IMAGE
                                        B-QUEEN-IMAGE)
                                    queen-width
                                    queen-height
                                    #t)
                          ; Keep the original piece
                          (make-piece (piece-type selected-piece)
                                    (piece-movement selected-piece)
                                    (piece-repeatable? selected-piece)
                                    (piece-player selected-piece)
                                    (piece-color selected-piece)
                                    #t
                                    (piece-img selected-piece)
                                    (piece-width selected-piece)
                                    (piece-height selected-piece)
                                    #t))])
                  ; Move piece to new position
                  (vector-set! (vector-ref state target-row) target-col new-piece))))
          state)
        state)))

;;;;; get-valid-moves ;;;;;

(define (get-valid-moves piece pos state)
  (let ([moves
         (cond
            [(equal? (piece-type piece) "pawn")
            (let* ([row (posn-y pos)]
                   [col (posn-x pos)]
                   [direction (if (equal? (piece-color piece) "white") 1 -1)] ; Flipped direction
                   [one-square (make-posn col (+ row direction))]
                   [two-squares (make-posn col (+ row (* 2 direction)))]
                   [capture-left (make-posn (- col 1) (+ row direction))]
                   [capture-right (make-posn (+ col 1) (+ row direction))]
                   [starting-row? (or (and (equal? (piece-color piece) "white") (= row 1))  ; Flipped starting rows
                                    (and (equal? (piece-color piece) "black") (= row 6)))]
                   ; Check if one square ahead is empty
                   [can-move-one? (and (in-bounds? one-square)
                                     (not (piece? (vector-ref (vector-ref state (posn-y one-square)) 
                                                            (posn-x one-square)))))]
                   ; Check if two squares ahead is empty and path is clear
                   [can-move-two? (and starting-row?
                                     can-move-one? ; Must be able to move one square first
                                     (in-bounds? two-squares)
                                     (not (piece? (vector-ref (vector-ref state (posn-y two-squares))
                                                            (posn-x two-squares)))))]
                   ; Check diagonal captures
                   [can-capture-left? (and (in-bounds? capture-left)
                                         (let ([target-piece (vector-ref (vector-ref state (posn-y capture-left))
                                                                       (posn-x capture-left))])
                                           (and (piece? target-piece)
                                                (not (equal? (piece-color piece)
                                                           (piece-color target-piece))))))]
                   [can-capture-right? (and (in-bounds? capture-right)
                                          (let ([target-piece (vector-ref (vector-ref state (posn-y capture-right))
                                                                        (posn-x capture-right))])
                                            (and (piece? target-piece)
                                                 (not (equal? (piece-color piece)
                                                            (piece-color target-piece))))))]
                   [basic-moves (filter (lambda (m) (in-bounds? m))
                                     (append
                                      (if can-move-one? (list one-square) '())
                                      (if can-move-two? (list two-squares) '())
                                      (if can-capture-left? (list capture-left) '())
                                      (if can-capture-right? (list capture-right) '())))])
              basic-moves)]
           
           [(equal? (piece-type piece) "knight")
            (let ([basic-moves
                   (map (lambda (dir) 
                         (make-posn (+ (posn-x pos) (posn-x dir))
                                  (+ (posn-y pos) (posn-y dir))))
                        KNIGHT-MOVES)])
              (filter (lambda (move)
                        (and (in-bounds? move)
                             (let ([piece-at-pos (vector-ref (vector-ref state (posn-y move)) 
                                                           (posn-x move))])
                               (or (not (piece? piece-at-pos))
                                   (not (equal? (piece-color piece-at-pos)
                                              (piece-color piece)))))))
                      basic-moves))]

           [(equal? (piece-type piece) "king")
            (let* ([basic-moves
                   (map (lambda (dir) 
                         (make-posn (+ (posn-x pos) (posn-x dir))
                                  (+ (posn-y pos) (posn-y dir))))
                        KING-QUEEN-MOVES)]
                   [castling-moves
                    (if (not (piece-dragged? piece)) ; King hasn't moved
                        (let ([row (posn-y pos)])
                          (append
                           ; Kingside castling (right)
                           (if (and (= (posn-x pos) 4) ; King in initial position
                                  (let ([rook (vector-ref (vector-ref state row) 7)])
                                    (and (piece? rook)
                                         (equal? (piece-type rook) "rook")
                                         (not (piece-dragged? rook))))
                                  ; Check if squares between king and rook are empty
                                  (not (piece? (vector-ref (vector-ref state row) 5)))
                                  (not (piece? (vector-ref (vector-ref state row) 6))))
                               (list (make-posn 6 row))
                               '())
                           ; Queenside castling (left)
                           (if (and (= (posn-x pos) 4) ; King in initial position
                                  (let ([rook (vector-ref (vector-ref state row) 0)])
                                    (and (piece? rook)
                                         (equal? (piece-type rook) "rook")
                                         (not (piece-dragged? rook))))
                                  ; Check if squares between king and rook are empty
                                  (not (piece? (vector-ref (vector-ref state row) 3)))
                                  (not (piece? (vector-ref (vector-ref state row) 2)))
                                  (not (piece? (vector-ref (vector-ref state row) 1))))
                               (list (make-posn 1 row))
                               '())))
                        '())])
              (filter (lambda (move)
                       (and (in-bounds? move)
                            (let ([piece-at-pos (vector-ref (vector-ref state (posn-y move)) 
                                                          (posn-x move))])
                              (or (not (piece? piece-at-pos))
                                  (not (equal? (piece-color piece-at-pos)
                                             (piece-color piece)))))))
                     (append basic-moves castling-moves)))]
           
           [(equal? (piece-type piece) "queen")
            (calculate-blocked-moves pos KING-QUEEN-MOVES #t state)]
           
           [(equal? (piece-type piece) "bishop")
            (calculate-blocked-moves pos DIAGONAL-MOVES #t state)]
           
           [(equal? (piece-type piece) "rook")
            (calculate-blocked-moves pos ROOK-MOVES #t state)]
           
           [else '()])])  ; Default case returns empty list
    (filter in-bounds? moves)))

; calculate-blocked-moves : Posn List<Posn> Boolean State -> List<Posn>

; calculates moves for pieces that can be blocked by other pieces

;; Implementation
(define (calculate-blocked-moves pos directions repeatable? state)
  (apply append
         (map (lambda (dir)
                (let loop ([current-pos pos] 
                          [moves '()])
                  (let* ([next-x (+ (posn-x current-pos) (posn-x dir))]
                         [next-y (+ (posn-y current-pos) (posn-y dir))]
                         [next-pos (make-posn next-x next-y)])
                    (cond
                      ; Out of bounds
                      [(not (in-bounds? next-pos))
                       moves]
                      ; Hit our own piece
                      [(let ([piece-at-pos (vector-ref (vector-ref state next-y) next-x)])
                         (and (piece? piece-at-pos)
                              (equal? (piece-color piece-at-pos)
                                     (piece-color (vector-ref (vector-ref state (posn-y pos)) (posn-x pos))))))
                       moves]
                      ; Hit opponent's piece
                      [(piece? (vector-ref (vector-ref state next-y) next-x))
                       (cons next-pos moves)]
                      ; Empty square and can continue
                      [repeatable?
                       (loop next-pos (cons next-pos moves))]
                      ; Empty square but can't continue
                      [else
                       (cons next-pos moves)]))))
              directions)))

;;;;; handle-mouse ;;;;;

; handle-mouse : State Number Number String -> State

;; Implmentation
(define (handle-mouse state x y event)
  (if game-over
      state  ; If game is over, don't allow any more moves
      (cond
        [(equal? event "button-down")
         (let* ([clicked-pos (which-square? x y)]
                [row (posn-y clicked-pos)]
                [col (posn-x clicked-pos)]
                [clicked-piece (vector-ref (vector-ref state row) col)])
           (cond
             ; If we have a selected piece and clicked on a valid move position
             [(and selected-piece 
                   (member clicked-pos (get-valid-moves selected-piece selected-pos state)))
              (begin
                (let ([new-state (handle-move state clicked-pos)]
                      [moving-color (piece-color selected-piece)])
                  ; Check if after the move, the king of the moving player is still in check
                  (when (king-in-check? moving-color new-state)
                    (set! game-over #t))
                  (set! selected-piece #f)
                  (set! selected-pos #f)
                  new-state))]
             ; If we clicked on our own piece (only black pieces)
             [(and (piece? clicked-piece) 
                   (piece-present? clicked-piece)
                   (equal? (piece-color clicked-piece) "black")) ; Only allow black pieces
              (begin
                (set! selected-piece clicked-piece)
                (set! selected-pos clicked-pos)
                state)]
             ; If we clicked elsewhere, deselect
             [else
              (begin
                (set! selected-piece #f)
                (set! selected-pos #f)
                state)]))]
        [else state])))

; Run the program
(big-bang INITIAL-STATE
          (on-mouse handle-mouse)
          (to-draw render))
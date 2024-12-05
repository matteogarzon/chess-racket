;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname MAIN) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
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
; where
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
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN1-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN2 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN2-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN3 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN3-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN4 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN4-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN5 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN5-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN6 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN6-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN7 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-PAWN7-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define W-PAWN8 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
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
                           KING-QUEEN-MOVES  ; Use movement list instead of single Posn
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
                           KING-QUEEN-MOVES  ; Use movement list instead of single Posn
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
                           DIAGONAL-MOVES  ; Use movement list instead of single Posn
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-BISHOP1-IMAGE 
                           bishop-width 
                           bishop-height 
                           #t)) ; present?
(define W-BISHOP2 (make-piece "bishop" 
                           DIAGONAL-MOVES  ; Use movement list instead of single Posn
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
                           ROOK-MOVES  ; Use movement list instead of single Posn
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-ROOK1-IMAGE 
                           rook-width 
                           rook-height 
                           #t)) ; present?
(define W-ROOK2 (make-piece "rook" 
                           ROOK-MOVES  ; Use movement list instead of single Posn
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
                           KNIGHT-MOVES  ; Use movement list instead of single Posn
                           #t ; repeatable?
                           2  ; player (2 for white)
                           "white" 
                           #f ; dragged?
                           W-KNIGHT1-IMAGE 
                           knight-width 
                           knight-height 
                           #t)) ; present?
(define W-KNIGHT2 (make-piece "knight" 
                           KNIGHT-MOVES  ; Use movement list instead of single Posn
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
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN1-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN2 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN2-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN3 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN3-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN4 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN4-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN5 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN5-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN6 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN6-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN7 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
                           #f ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-PAWN7-IMAGE 
                           pawn-width 
                           pawn-height 
                           #t)) ; present?
(define B-PAWN8 (make-piece "pawn" 
                           VERTICAL-MOVES  ; Use movement list instead of single Posn
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
                           KING-QUEEN-MOVES  ; Use movement list instead of single Posn
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
                           KING-QUEEN-MOVES  ; Use movement list instead of single Posn
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
                           DIAGONAL-MOVES  ; Use movement list instead of single Posn
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-BISHOP1-IMAGE 
                           bishop-width 
                           bishop-height 
                           #t)) ; present?
(define B-BISHOP2 (make-piece "bishop" 
                           DIAGONAL-MOVES  ; Use movement list instead of single Posn
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
                           ROOK-MOVES  ; Use movement list instead of single Posn
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-ROOK1-IMAGE 
                           rook-width 
                           rook-height 
                           #t)) ; present?
(define B-ROOK2 (make-piece "rook" 
                           ROOK-MOVES  ; Use movement list instead of single Posn
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
                           KNIGHT-MOVES  ; Use movement list instead of single Posn
                           #t ; repeatable?
                           1  ; player (1 for black)
                           "black" 
                           #f ; dragged?
                           B-KNIGHT1-IMAGE 
                           knight-width 
                           knight-height 
                           #t)) ; present?
(define B-KNIGHT2 (make-piece "knight" 
                           KNIGHT-MOVES  ; Use movement list instead of single Posn
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
    ; Row 0 - Black back row
    (vector 
      (make-piece "rook" ROOK-MOVES #t 1 "black" #f B-ROOK1-IMAGE rook-width rook-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 1 "black" #f B-KNIGHT1-IMAGE knight-width knight-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 1 "black" #f B-BISHOP1-IMAGE bishop-width bishop-height #t)
      (make-piece "queen" KING-QUEEN-MOVES #t 1 "black" #f B-QUEEN-IMAGE queen-width queen-height #t)
      (make-piece "king" KING-QUEEN-MOVES #f 1 "black" #f B-KING-IMAGE king-width king-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 1 "black" #f B-BISHOP2-IMAGE bishop-width bishop-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 1 "black" #f B-KNIGHT2-IMAGE knight-width knight-height #t)
      (make-piece "rook" ROOK-MOVES #t 1 "black" #f B-ROOK2-IMAGE rook-width rook-height #t))
    
    ; Row 1 - Black pawns
    (vector 
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN1-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN2-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN3-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN4-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN5-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN6-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN7-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 1 "black" #f B-PAWN8-IMAGE pawn-width pawn-height #t))
    
    ; Rows 2-5 - Empty spaces
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    (vector 0 0 0 0 0 0 0 0)
    
    ; Row 6 - White pawns
    (vector 
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN1-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN2-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN3-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN4-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN5-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN6-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN7-IMAGE pawn-width pawn-height #t)
      (make-piece "pawn" VERTICAL-MOVES #t 2 "white" #f W-PAWN8-IMAGE pawn-width pawn-height #t))
    
    ; Row 7 - White back row
    (vector 
      (make-piece "rook" ROOK-MOVES #t 2 "white" #f W-ROOK1-IMAGE rook-width rook-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 2 "white" #f W-KNIGHT1-IMAGE knight-width knight-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 2 "white" #f W-BISHOP1-IMAGE bishop-width bishop-height #t)
      (make-piece "queen" KING-QUEEN-MOVES #t 2 "white" #f W-QUEEN-IMAGE queen-width queen-height #t)
      (make-piece "king" KING-QUEEN-MOVES #f 2 "white" #f W-KING-IMAGE king-width king-height #t)
      (make-piece "bishop" DIAGONAL-MOVES #t 2 "white" #f W-BISHOP2-IMAGE bishop-width bishop-height #t)
      (make-piece "knight" KNIGHT-MOVES #t 2 "white" #f W-KNIGHT2-IMAGE knight-width knight-height #t)
      (make-piece "rook" ROOK-MOVES #t 2 "white" #f W-ROOK2-IMAGE rook-width rook-height #t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Functions ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check if a click is inside the button
(define (inside-button? x y)
  (and (<= button-x x (+ button-x button-width))
       (<= button-y y (+ button-y button-height))))

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
  (let ([img (if (eq? piece selected-piece)  ; Changed from equal? to eq? and comparing whole pieces
                 (overlay 
                  (overlay  ; Multiple overlays to create thicker border
                   (rectangle SQUARE-SIDE SQUARE-SIDE "outline" "red")
                   (rectangle (- SQUARE-SIDE 1) (- SQUARE-SIDE 1) "outline" "red")
                   (rectangle (- SQUARE-SIDE 2) (- SQUARE-SIDE 2) "outline" "red"))
                  (piece-img piece))
                 (piece-img piece))])
    (place-image img
                (+ (* x SQUARE-SIDE) (/ SQUARE-SIDE 2))
                (+ (* y SQUARE-SIDE) (/ SQUARE-SIDE 2))
                scene)))

;;;;; render-images ;;;;;

;; Data type
; a List<Piece> is one of:
; '()                      ; base case
; (cons Piece List<Piece>) ; recursive case

;; Input/Output
; render : List<Piece> Scene -> Scene
; renders the scene with all pieces
; header: (define (render pieces EMPTY-CHESSBOARD) EMPTY-CHESSBOARD)

(define (vector-to-list-of-lists vector-board)
  (map vector->list (vector->list vector-board)))

; Helper function to find a piece's current position in the board
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
        (make-posn 0 0)))) ; fallback position if piece not found

; Implementation
(define (render state)
  (let ([scene EMPTY-CHESSBOARD])
    ; First, draw dots for valid moves if a piece is selected
    (let ([scene 
           (if selected-piece
               (let ([valid-moves (get-valid-moves selected-piece selected-pos state)])
                 (foldl (lambda (move scene)
                         (place-image (circle 8 "solid" "gray")
                                    (+ (* (posn-x move) SQUARE-SIDE) (/ SQUARE-SIDE 2))
                                    (+ (* (posn-y move) SQUARE-SIDE) (/ SQUARE-SIDE 2))
                                    scene))
                       scene
                       valid-moves))
               scene)])
      ; Then draw all pieces
      (foldl (lambda (row-idx scene)
               (foldl (lambda (col-idx scene)
                        (let ([piece (vector-ref (vector-ref state row-idx) col-idx)])
                          (if (and (piece? piece) (piece-present? piece))
                              (highlight-piece piece scene col-idx row-idx)
                              scene)))
                      scene
                      (build-list 8 values)))
             scene
             (build-list 8 values)))))

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

(define selected-pos #f)  ; Add this to track the original position

;;;;; handle-move ;;;;;
; Add a new function to handle moving the selected piece

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
          ; Clear original position
          (vector-set! (vector-ref state orig-row) orig-col 0)
          ; Move piece to new position, preserving all properties
          (vector-set! (vector-ref state target-row) target-col 
                      (make-piece (piece-type selected-piece)
                                (piece-movement selected-piece)
                                (piece-repeatable? selected-piece)
                                (piece-player selected-piece)
                                (piece-color selected-piece)
                                #f  ; reset dragged state
                                (piece-img selected-piece)
                                (piece-width selected-piece)
                                (piece-height selected-piece)
                                #t))  ; piece is present
          state)
        state)))

;;;;; get-valid-moves ;;;;;

(define (get-valid-moves piece pos state)
  (let ([moves
         (cond
           [(equal? (piece-type piece) "pawn")
            (let* ([row (posn-y pos)]
                   [col (posn-x pos)]
                   [direction (if (equal? (piece-color piece) "white") -1 1)]
                   [basic-moves 
                    (if (or (and (equal? (piece-color piece) "white") (= row 6))
                           (and (equal? (piece-color piece) "black") (= row 1)))
                        ; Starting position - can move one or two squares
                        (list (make-posn col (+ row direction))
                              (make-posn col (+ row (* 2 direction))))
                        ; Regular position - can move one square
                        (list (make-posn col (+ row direction))))])
              (filter (lambda (move)
                        (and (in-bounds? move)
                             (not (is-there-piece? move))))
                      basic-moves))]
           [(equal? (piece-type piece) "king")
            (let ([basic-moves
                   (map (lambda (dir) 
                         (make-posn (+ (posn-x pos) (posn-x dir))
                                  (+ (posn-y pos) (posn-y dir))))
                        KING-QUEEN-MOVES)])
              (filter (lambda (move)
                        (and (in-bounds? move)
                             (or (not (is-there-piece? move))
                                 (is-there-opponent-piece? move))))
                      basic-moves))]
           [(equal? (piece-type piece) "knight")
            (let ([basic-moves
                   (map (lambda (dir) 
                         (make-posn (+ (posn-x pos) (posn-x dir))
                                  (+ (posn-y pos) (posn-y dir))))
                        KNIGHT-MOVES)])
              (filter (lambda (move)
                        (and (in-bounds? move)
                             (or (not (is-there-piece? move))
                                 (is-there-opponent-piece? move))))
                      basic-moves))]
           [(equal? (piece-type piece) "bishop")
            (calculate-blocked-moves pos DIAGONAL-MOVES (piece-repeatable? piece) state)]
           [(equal? (piece-type piece) "rook")
            (calculate-blocked-moves pos ROOK-MOVES (piece-repeatable? piece) state)]
           [(equal? (piece-type piece) "queen")
            (calculate-blocked-moves pos KING-QUEEN-MOVES (piece-repeatable? piece) state)]
           [else '()])])
    (filter in-bounds? moves)))

; calculate-blocked-moves : Posn List<Posn> Boolean State -> List<Posn>
; calculates moves for pieces that can be blocked by other pieces

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
            (handle-move state clicked-pos)
            (set! selected-piece #f)
            (set! selected-pos #f)
            state)]
         ; If we clicked on our own piece, select it
         [(and (piece? clicked-piece) 
               (piece-present? clicked-piece)
               (or (not selected-piece)  ; Either no piece is selected
                   (equal? (piece-color clicked-piece) (piece-color selected-piece))))  ; Or it's our color
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
    [else state]))

;; INPUT/OUTPUT
; handle-key: KeyEvent -> AppState
; modify state 's' in response to 'key' being pressed
; header: (define (handle-key s key) s)

; Examples
(check-expect (handle-key INITIAL-STATE "q") (quit INITIAL-STATE))
(check-expect (handle-key DRAWING "y") (cancel-line DRAWING))

; Template
; (define (handle-key s key)
;   ... (quit s) ... (cancel-line s))

(define (handle-key s key)
  (cond
    [(string=? key "q")         (end-game s)]         ; select's app's state to quit
    [(string=? key "y")    (cancel-line s)]  ; cancel currently drawn line 
    [else s]))                                    ; no change

; Run the program
(big-bang INITIAL-STATE
  (name "Chess")
  (on-mouse handle-mouse)
  (on-key handle-key)
  (to-draw render))
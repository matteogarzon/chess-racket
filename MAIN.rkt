;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname TEST) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;%%%%%%%%%%%%%%%%%%%%;
;#### CHESS GAME ####;
;%%%%%%%%%%%%%%%%%%%%;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Libraries ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 2htdp/image)
(require 2htdp/universe)
(require racket/base)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Data type ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; a Piece is a structure:
; where
;   position       :    Posn
;   dragged?       :    Boolean
;   img            :    Image
;   width          :    Number
;   height         :    Number
;   present?       :    Boolean
;   color          :    String
; interpretation: a piece of the chessboard with his own position,
; width, height, color, dragged-state, present-state and image
(define-struct piece [position dragged? img width height present? color] #:transparent)

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

; Horses
(define B-HORSE1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-horse.png"))) ; Black horse 1
(define B-HORSE2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/Black Pieces/b-horse.png"))) ; Black horse 2

(define W-HORSE1-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-horse.png"))) ; White horse 1
(define W-HORSE2-IMAGE (scale/xy DIV-RATIO DIV-RATIO (bitmap "Images/White Pieces/w-horse.png"))) ; White horse 2

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

(define horse-width (image-width B-HORSE1-IMAGE))   ; Horse width
(define horse-height (image-height B-HORSE1-IMAGE)) ; Horse height

; Defining the chessboard pieces
; White pawns
(define W-PAWN1 (make-piece (make-posn (/ SQUARE-SIDE 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN1-IMAGE pawn-width pawn-height #t "white"))
(define W-PAWN2 (make-piece (make-posn (/ (* SQUARE-SIDE 3) 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN2-IMAGE pawn-width pawn-height #t "white"))
(define W-PAWN3 (make-piece (make-posn (/ (* SQUARE-SIDE 5) 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN3-IMAGE pawn-width pawn-height #t "white"))
(define W-PAWN4 (make-piece (make-posn (/ (* SQUARE-SIDE 7) 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN4-IMAGE pawn-width pawn-height #t "white"))
(define W-PAWN5 (make-piece (make-posn (/ (* SQUARE-SIDE 9) 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN5-IMAGE pawn-width pawn-height #t "white"))
(define W-PAWN6 (make-piece (make-posn (/ (* SQUARE-SIDE 11) 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN6-IMAGE pawn-width pawn-height #t "white"))
(define W-PAWN7 (make-piece (make-posn (/ (* SQUARE-SIDE 13) 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN7-IMAGE pawn-width pawn-height #t "white"))
(define W-PAWN8 (make-piece (make-posn (/ (* SQUARE-SIDE 15) 2) (/ (* SQUARE-SIDE 13) 2)) #f W-PAWN8-IMAGE pawn-width pawn-height #t "white"))

; White king
(define W-KING (make-piece (make-posn (/ (* SQUARE-SIDE 9) 2) (/ (* SQUARE-SIDE 15) 2)) #f W-KING-IMAGE king-width king-height #t "white"))

; White queen
(define W-QUEEN (make-piece (make-posn (/ (* SQUARE-SIDE 7) 2) (/ (* SQUARE-SIDE 15) 2)) #f W-QUEEN-IMAGE queen-width queen-height #t "white"))

; White bishops
(define W-BISHOP1 (make-piece (make-posn (/ (* SQUARE-SIDE 5) 2) (/ (* SQUARE-SIDE 15) 2)) #f W-BISHOP1-IMAGE bishop-width bishop-height #t "white"))
(define W-BISHOP2 (make-piece (make-posn (/ (* SQUARE-SIDE 11) 2) (/ (* SQUARE-SIDE 15) 2)) #f W-BISHOP1-IMAGE bishop-width bishop-height #t "white"))

; White rooks
(define W-ROOK1 (make-piece (make-posn (/ (* SQUARE-SIDE 15) 2) (/ (* SQUARE-SIDE 15) 2)) #f W-ROOK1-IMAGE rook-width rook-height #t "white"))
(define W-ROOK2 (make-piece (make-posn (/ SQUARE-SIDE 2) (/ (* SQUARE-SIDE 15) 2)) #f W-ROOK2-IMAGE rook-width rook-height #t "white"))

; White horses
(define W-HORSE1 (make-piece (make-posn (/ (* SQUARE-SIDE 3) 2) (/ (* SQUARE-SIDE 15) 2)) #f W-HORSE1-IMAGE horse-width horse-height #t "white"))
(define W-HORSE2 (make-piece (make-posn (/ (* SQUARE-SIDE 13) 2) (/ (* SQUARE-SIDE 15) 2)) #f W-HORSE2-IMAGE horse-width horse-height #t "white"))

; Black pawns
(define B-PAWN1 (make-piece (make-posn (/ SQUARE-SIDE 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN1-IMAGE pawn-width pawn-height #t "black"))
(define B-PAWN2 (make-piece (make-posn (/ (* SQUARE-SIDE 3) 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN2-IMAGE pawn-width pawn-height #t "black"))
(define B-PAWN3 (make-piece (make-posn (/ (* SQUARE-SIDE 5) 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN3-IMAGE pawn-width pawn-height #t "black"))
(define B-PAWN4 (make-piece (make-posn (/ (* SQUARE-SIDE 7) 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN4-IMAGE pawn-width pawn-height #t "black"))
(define B-PAWN5 (make-piece (make-posn (/ (* SQUARE-SIDE 9) 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN5-IMAGE pawn-width pawn-height #t "black"))
(define B-PAWN6 (make-piece (make-posn (/ (* SQUARE-SIDE 11) 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN6-IMAGE pawn-width pawn-height #t "black"))
(define B-PAWN7 (make-piece (make-posn (/ (* SQUARE-SIDE 13) 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN7-IMAGE pawn-width pawn-height #t "black"))
(define B-PAWN8 (make-piece (make-posn (/ (* SQUARE-SIDE 15) 2) (/ (* SQUARE-SIDE 3) 2)) #f B-PAWN8-IMAGE pawn-width pawn-height #t "black"))

; Black king
(define B-KING (make-piece (make-posn (/ (* SQUARE-SIDE 9) 2) (/ SQUARE-SIDE 2)) #f B-KING-IMAGE king-width king-height #t "black"))

; Black queen
(define B-QUEEN (make-piece (make-posn (/ (* SQUARE-SIDE 7) 2) (/ SQUARE-SIDE 2)) #f B-QUEEN-IMAGE queen-width queen-height #t "black"))

; Black bishops
(define B-BISHOP1 (make-piece (make-posn (/ (* SQUARE-SIDE 5) 2) (/ SQUARE-SIDE 2)) #f B-BISHOP1-IMAGE bishop-width bishop-height #t "black"))
(define B-BISHOP2 (make-piece (make-posn (/ (* SQUARE-SIDE 11) 2) (/ SQUARE-SIDE 2)) #f B-BISHOP1-IMAGE bishop-width bishop-height #t "black"))

; Black rooks
(define B-ROOK1 (make-piece (make-posn (/ SQUARE-SIDE 2) (/ SQUARE-SIDE 2)) #f B-ROOK1-IMAGE rook-width rook-height #t "black"))
(define B-ROOK2 (make-piece (make-posn (/ (* SQUARE-SIDE 15) 2) (/ SQUARE-SIDE 2)) #f B-ROOK2-IMAGE rook-width rook-height #t "black"))

; Black horses
(define B-HORSE1 (make-piece (make-posn (/ (* SQUARE-SIDE 3) 2) (/ SQUARE-SIDE 2)) #f B-HORSE1-IMAGE horse-width horse-height #t "black"))
(define B-HORSE2 (make-piece (make-posn (/ (* SQUARE-SIDE 13) 2) (/ SQUARE-SIDE 2)) #f B-HORSE2-IMAGE horse-width horse-height #t "black"))

; Defining the initial-state
(define INITIAL-STATE
  (list
   W-PAWN1
   W-PAWN2
   W-PAWN3
   W-PAWN4
   W-PAWN5
   W-PAWN6
   W-PAWN7
   W-PAWN8
   W-KING
   W-QUEEN
   W-BISHOP1
   W-BISHOP2
   W-ROOK1
   W-ROOK2
   W-HORSE1
   W-HORSE2
   B-PAWN1
   B-PAWN2
   B-PAWN3
   B-PAWN4
   B-PAWN5
   B-PAWN6
   B-PAWN7
   B-PAWN8
   B-KING
   B-QUEEN
   B-BISHOP1
   B-BISHOP2
   B-ROOK1
   B-ROOK2
   B-HORSE1
   B-HORSE2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Functions ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; inside-image? ;;;;;

;; Input/Output
; inside-image? : Number Number Piece -> Boolean
; checks if the mouse click is within the image's clickable area
; header: (define (inside-image? Number Number Piece) #true))

;; Examples
(check-expect (inside-image? 10 10 B-PAWN1) #f)
(check-expect (inside-image? 10 10 W-BISHOP2) #f)
(check-expect (inside-image? (/ (* SQUARE-SIDE 9) 2) (/ SQUARE-SIDE 2) B-KING) #t)

;; Implementation
(define (inside-image? mouse-x mouse-y piece)
  (and (>= mouse-x (- (posn-x (piece-position piece)) (/ (piece-width piece) 2)))
       (<= mouse-x (+ (posn-x (piece-position piece)) (/ (piece-width piece) 2)))
       (>= mouse-y (- (posn-y (piece-position piece)) (/ (piece-height piece) 2)))
       (<= mouse-y (+ (posn-y (piece-position piece)) (/ (piece-height piece) 2)))))

;;;;; render-images ;;;;;

;; Data type
; a List<Piece> is one of:
; '()                      ; base case
; (cons Piece List<Piece>) ; recursive case

;; Input/Output
; render : List<Piece> Scene -> Scene
; renders the scene with all pieces
; header: (define (render pieces EMPTY-CHESSBOARD) EMPTY-CHESSBOARD)

;; Constants for the Examples
; Defining a scene with two black pawns over the chessboard
(define B-PAWNS1-2-CHESSBOARD
  (place-image B-PAWN1-IMAGE (/ SQUARE-SIDE 2) (/ (* SQUARE-SIDE 3) 2)
    (place-image B-PAWN2-IMAGE (/ (* SQUARE-SIDE 3) 2) (/ (* SQUARE-SIDE 3) 2) 
      (overlay CHESSBOARD (empty-scene (* SQUARE-SIDE 8) (* SQUARE-SIDE 8))))))

; Defining a scene with a black rook over the chessboard
(define B-ROOK1-CHESSBOARD (place-image B-ROOK1-IMAGE (/ SQUARE-SIDE 2) (/ SQUARE-SIDE 2) (overlay CHESSBOARD (empty-scene (* SQUARE-SIDE 8) (* SQUARE-SIDE 8)))))

; Defining a list of the two pawns
(define B-PAWNS1-2-STATE
  (list
   B-PAWN1
   B-PAWN2))

; Defining a list of the rook
(define B-ROOK1-STATE
  (list
   B-ROOK1))

;; Examples
(check-expect (render-pieces '()  EMPTY-CHESSBOARD) EMPTY-CHESSBOARD)
(check-expect (render-pieces B-PAWNS1-2-STATE  EMPTY-CHESSBOARD) B-PAWNS1-2-CHESSBOARD)
(check-expect (render-pieces B-ROOK1-STATE  EMPTY-CHESSBOARD) B-ROOK1-CHESSBOARD)
                             
; Implementation
(define (render-pieces pieces scene)
  (cond
    [(empty? pieces) scene] ; Base case: no pieces left
    [else
     (let ([first-piece (first pieces)]
           [remaining (rest pieces)])
       (render-pieces remaining 
         (place-image (piece-img first-piece) 
                      (posn-x (piece-position first-piece)) 
                      (posn-y (piece-position first-piece)) 
                      scene)))])) ; Recursive step

;; Implementation
(define (render state)
  (render-pieces state (overlay CHESSBOARD (empty-scene (* SQUARE-SIDE 8) (* SQUARE-SIDE 8))))) ; Background size

;;;;; handle-drag ;;;;;

;; Input/Output
; handle-drag : List<Piece> Number Number -> List<Piece>
; updates the position of a piece that has been dragged
; header: (define (handle-drag List<Piece> mouse-x mouse-y) INITIAL-STATE)

;; Constant for Examples
; Defining the white pawn with the new position
(define NEW-W-PAWN1 (make-piece (make-posn 100 100) #t W-PAWN1-IMAGE pawn-width pawn-height #t "white"))

; Defining the state when W-PAWN1 has 'dragged?' set to true
(define NEW-W-PAWN1-STATE
  (list
   NEW-W-PAWN1
   W-PAWN2
   W-PAWN3
   W-PAWN4
   W-PAWN5
   W-PAWN6
   W-PAWN7
   W-PAWN8
   W-KING
   W-QUEEN
   W-BISHOP1
   W-BISHOP2
   W-ROOK1
   W-ROOK2
   W-HORSE1
   W-HORSE2
   B-PAWN1
   B-PAWN2
   B-PAWN3
   B-PAWN4
   B-PAWN5
   B-PAWN6
   B-PAWN7
   B-PAWN8
   B-KING
   B-QUEEN
   B-BISHOP1
   B-BISHOP2
   B-ROOK1
   B-ROOK2
   B-HORSE1
   B-HORSE2))

;; Examples
(check-expect (handle-drag W-PAWN1-D-STATE 100 100) NEW-W-PAWN1-STATE)

;; Implementation
(define (handle-drag pieces mouse-x mouse-y)
  (map
   (lambda (piece)
     (if (and (piece-dragged? piece) (piece-present? piece))
         ;; Update the position of the dragged piece
         (make-piece (make-posn mouse-x mouse-y)
                     (piece-dragged? piece)
                     (piece-img piece)
                     (piece-width piece)
                     (piece-height piece)
                     (piece-present? piece)
                     (piece-color piece))
         ;; Leave other pieces unchanged
         piece))
   pieces))

;;;;; which-square? ;;;;;

;; Input/Output
; which-square? : Piece -> Posn
; returns the row and the column as a posn
; header: (define (which-square? Piece) (make-posn 1 1))

;; Examples
(check-expect (which-square? B-PAWN1) (make-posn 0 1))
(check-expect (which-square? B-ROOK2) (make-posn 7 0))

(define (which-square? piece)
  (cond
   [(and (>= (posn-x (piece-position piece)) 0)
         (<= (posn-x (piece-position piece)) (* 8 SQUARE-SIDE))
         (>= (posn-y (piece-position piece)) 0)
         (<= (posn-y (piece-position piece)) (* 8 SQUARE-SIDE)))
    (let ([col (floor (/ (posn-x (piece-position piece)) SQUARE-SIDE))]
          [row (floor (/ (posn-y (piece-position piece)) SQUARE-SIDE))])
       (make-posn col row))] ; Return the row and column as a posn
   [else (error "The position isn't between 0 and the maximum value of the chessboard")]))

;;;;; put-piece ;;;;;

;; Input/Output
; put-piece : Piece List<Piece> -> List<Piece>
; places the dragged piece in the center of the square
; where it is located
; header: (define (put-piece Piece List<Piece>) INITIAL-STATE)

;; Constants for Examples
(define NEW-B-PAWN1 (make-piece (make-posn 190 234) #f B-PAWN1-IMAGE pawn-width pawn-height #t "black"))

;; Examples
(check-expect (put-piece B-PAWN1 INITIAL-STATE) INITIAL-STATE)
(check-expect (put-piece B-KING INITIAL-STATE) INITIAL-STATE)
(check-expect (put-piece NEW-B-PAWN1 INITIAL-STATE) INITIAL-STATE)

;; Implementation
(define (put-piece piece pieces)
  (let ([center-x (+ (* (posn-x (which-square? piece)) SQUARE-SIDE) (/ SQUARE-SIDE 2))]
        [center-y (+ (* (posn-y (which-square? piece)) SQUARE-SIDE) (/ SQUARE-SIDE 2))])
    (if (and (piece-dragged? piece) ; If this piece is being dragged
             (not (false? (piece-present? piece))))
        (cons (make-piece (make-posn center-x center-y) (piece-dragged? piece) (piece-img piece) (piece-width piece) (piece-height piece) (piece-present? piece) (piece-color piece))
                   pieces)
        pieces)))

;;;;; same-square? ;;;;;

;; Input/Output
; same-square? : Piece List<Piece> -> Boolean
; says if two pieces are in the same square
; header: (define (same-square? Piece List<Piece>) #false)

;; Constants for Examples
; Defining the white horse with the new position (100 100)
(define NEW-W-HORSE1 (make-piece (make-posn 100 100) #f W-HORSE1-IMAGE horse-width horse-height #t "white"))

; Defining the white horse with the new position (100 100)
(define NEW-W-HORSE2 (make-piece (make-posn 100 100) #f W-HORSE2-IMAGE horse-width horse-height #t "white"))

; Defining the state when W-HORSE1 and W-HORSE2 are in the same square
(define NEW-W-HORSE1-2-STATE
  (list
   W-PAWN1
   W-PAWN2
   W-PAWN3
   W-PAWN4
   W-PAWN5
   W-PAWN6
   W-PAWN7
   W-PAWN8
   W-KING
   W-QUEEN
   W-BISHOP1
   W-BISHOP2
   W-ROOK1
   W-ROOK2
   NEW-W-HORSE1
   NEW-W-HORSE2
   B-PAWN1
   B-PAWN2
   B-PAWN3
   B-PAWN4
   B-PAWN5
   B-PAWN6
   B-PAWN7
   B-PAWN8
   B-KING
   B-QUEEN
   B-BISHOP1
   B-BISHOP2
   B-ROOK1
   B-ROOK2
   B-HORSE1
   B-HORSE2))

;; Examples
(check-expect (same-square? B-PAWN1 INITIAL-STATE) #false)
(check-expect (same-square? NEW-W-HORSE1 NEW-W-HORSE1-2-STATE) #true)

;; Implementation
(define (same-square? dragged-piece pieces)
  (if (list? pieces) ; Ensure the input is a list
      (ormap
       (lambda (piece)
         (and (piece-present? piece)
              (not (equal? dragged-piece piece))
              (equal? (which-square? piece) (which-square? dragged-piece))))
       pieces)
      (error "same-square?: expected a list of pieces, got" pieces))) ; Raise an error for invalid input

;;;;; same-color? ;;;;;

;; Input/Output
; same-color? : Piece Piece -> Boolean
; says if two pieces have the same color
; header: (define (same-color? dragged-piece pieces) #true)

;; Examples
(check-expect (same-color? B-PAWN1 B-ROOK1) #true)
(check-expect (same-color? W-PAWN1 W-ROOK1) #true)
(check-expect (same-color? W-PAWN1 B-ROOK1) #false)

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

; Constants for Examples
(define TRANSPARENT-W-HORSE1 (make-piece (make-posn 100 100) #f (rectangle 0 0 "solid" "transparent") horse-width horse-height #f "white"))

;; Examples
(check-expect (make-transparent B-PAWN1) B-PAWN1)
(check-expect (make-transparent NOT-PRESENT-W-HORSE1) TRANSPARENT-W-HORSE1)

;; Implementation
(define (make-transparent piece)
  (if (false? (piece-present? piece))
      (make-piece (piece-position piece)
                  (piece-dragged? piece)
                  (rectangle 0 0 "solid" "transparent")
                  (piece-width piece)
                  (piece-height piece)
                  (piece-present? piece)
                  (piece-color piece))
      piece)) ; Return unchanged if present? is true

;;;;; eaten-piece ;;;;;

;; Input/Output
; eaten-piece : Piece List<Piece> -> List<Piece>
; checks if a piece has been eaten and creates a list with
; the piece that has present? sets to false
; header: (define (eaten-piece dragged-piece pieces) INITIAL-STATE)

;; Constants for Examples
; Defining the black horse with the new position (100 100)
(define NEW-B-HORSE1 (make-piece (make-posn 100 100) #f B-HORSE1-IMAGE horse-width horse-height #t "black"))

; Defining the white horse that has 'present?' set to #false
(define NOT-PRESENT-W-HORSE1 (make-piece (make-posn 100 100) #f W-HORSE1-IMAGE horse-width horse-height #f "white"))

; Defining the state when W-HORSE1 and W-HORSE2 are in the same square
(define NEW-W-HORSE1-STATE
  (list
   W-PAWN1
   W-PAWN2
   W-PAWN3
   W-PAWN4
   W-PAWN5
   W-PAWN6
   W-PAWN7
   W-PAWN8
   W-KING
   W-QUEEN
   W-BISHOP1
   W-BISHOP2
   W-ROOK1
   W-ROOK2
   NEW-W-HORSE1
   W-HORSE2
   B-PAWN1
   B-PAWN2
   B-PAWN3
   B-PAWN4
   B-PAWN5
   B-PAWN6
   B-PAWN7
   B-PAWN8
   B-KING
   B-QUEEN
   B-BISHOP1
   B-BISHOP2
   B-ROOK1
   B-ROOK2
   B-HORSE2))

; Defining the state when W-HORSE1 and W-HORSE2 are in the same square
(define W-HORSE1-EATEN-STATE
  (list
   NEW-B-HORSE1
   W-PAWN1
   W-PAWN2
   W-PAWN3
   W-PAWN4
   W-PAWN5
   W-PAWN6
   W-PAWN7
   W-PAWN8
   W-KING
   W-QUEEN
   W-BISHOP1
   W-BISHOP2
   W-ROOK1
   W-ROOK2
   (make-transparent NOT-PRESENT-W-HORSE1)
   W-HORSE2
   B-PAWN1
   B-PAWN2
   B-PAWN3
   B-PAWN4
   B-PAWN5
   B-PAWN6
   B-PAWN7
   B-PAWN8
   B-KING
   B-QUEEN
   B-BISHOP1
   B-BISHOP2
   B-ROOK1
   B-ROOK2
   B-HORSE2))

;; Examples
(check-expect (eaten-piece NEW-B-HORSE1 NEW-W-HORSE1-STATE) W-HORSE1-EATEN-STATE)

;; Implementation
(define (eaten-piece dragged-piece pieces)
  (cons
   ;; Include the dragged piece with its updated attributes
   (make-piece (piece-position dragged-piece)  ; Use the dragged piece's position
               (piece-dragged? dragged-piece)     ; Keep its dragged status
               (piece-img dragged-piece)          ; Keep its image
               (piece-width dragged-piece)        ; Keep its dimensions
               (piece-height dragged-piece)
               (piece-present? dragged-piece)     ; Keep its 'present?' status
               (piece-color dragged-piece))       ; Keep its color
   ;; Process the remaining pieces
   (map
    (lambda (piece)
      (if (and (piece-present? piece)               ; The piece is currently present
               (not (equal? dragged-piece piece))   ; It's not the dragged piece itself
               (same-square? dragged-piece (list piece)) ; Check against the current piece only
               (not (same-color? dragged-piece piece))) ; Ensure opposing colors
          (make-transparent (make-piece (piece-position piece)     ; Modify the piece to set 'present?' to #f
                            (piece-dragged? piece)
                            (piece-img piece)
                            (piece-width piece)
                            (piece-height piece)
                            #f                            ; Set 'present?' to #f
                            (piece-color piece)))
                            piece))                     ; Otherwise, return the unmodified piece
          pieces)))

;;;;; Handle mouse events ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; handle-button-down ;;;;;

;; Input/Output
; handle-button-down : List<Piece> Number Number -> List<Piece>
; determines whether a mouse click interacts with any of the pieces,
; and if so, modifies the drag-state to #t
; header: (define (handle-button-down List<Piece> mouse-x mouse-y) INITIAL-STATE)

;; Constants for Examples
; Defining the white pawn 1 with 'dragged?' set to true
(define W-PAWN1-D (make-piece (make-posn (/ SQUARE-SIDE 2) (/ (* SQUARE-SIDE 13) 2)) #t W-PAWN1-IMAGE pawn-width pawn-height #t "white"))

; Defining the state when W-PAWN1 has 'dragged?' set to true
(define W-PAWN1-D-STATE
  (list
   W-PAWN1-D ; D stands for dragged
   W-PAWN2
   W-PAWN3
   W-PAWN4
   W-PAWN5
   W-PAWN6
   W-PAWN7
   W-PAWN8
   W-KING
   W-QUEEN
   W-BISHOP1
   W-BISHOP2
   W-ROOK1
   W-ROOK2
   W-HORSE1
   W-HORSE2
   B-PAWN1
   B-PAWN2
   B-PAWN3
   B-PAWN4
   B-PAWN5
   B-PAWN6
   B-PAWN7
   B-PAWN8
   B-KING
   B-QUEEN
   B-BISHOP1
   B-BISHOP2
   B-ROOK1
   B-ROOK2
   B-HORSE1
   B-HORSE2))

;; Examples
(check-expect (handle-button-down INITIAL-STATE (/ SQUARE-SIDE 2) (/ (* SQUARE-SIDE 13) 2)) W-PAWN1-D-STATE) 

;; Implementation
(define (handle-button-down pieces mouse-x mouse-y)
  (map
   (lambda (piece)
     (if (and (inside-image? mouse-x mouse-y piece) (piece-present? piece))
         ;; Marks this piece as draggable
         (make-piece (piece-position piece)
                     #t  ; Sets 'dragged?' to true
                     (piece-img piece)
                     (piece-width piece)
                     (piece-height piece)
                     (piece-present? piece)
                     (piece-color piece))
         ;; Leaves other pieces unchanged
         piece))
   pieces))

;;;;; handle-button-up ;;;;;

;; Input/Output
; handle-button-up: List<Piece> : List<Piece>
; snaps a dragged piece to the center of the nearest square
; upon releasing the mouse button, updates the board, and
; handles any pieces eaten by the dragged piece
; header: (define (handle-button-up pieces) INITIAL-STATE)

;; Implementation
(define (handle-button-up pieces)
  (let* ([dragged-pieces (filter (lambda (piece) (piece-dragged? piece)) pieces)]
         [dragged-piece (if (empty? dragged-pieces) 
                            #f 
                            (first dragged-pieces))])
    (if (false? dragged-piece)
        pieces ; No dragged piece, return unchanged pieces
        (map (lambda (piece)
               (if (piece-dragged? piece) ; If this is the dragged piece
                   (let* ([square (which-square? piece)]
                          [col (posn-x square)]
                          [row (posn-y square)]
                          [center-x (+ (* col SQUARE-SIDE) (/ SQUARE-SIDE 2))]
                          [center-y (+ (* row SQUARE-SIDE) (/ SQUARE-SIDE 2))])
                     (make-piece (make-posn center-x center-y) #f (piece-img piece) (piece-width piece) (piece-height piece) #t (piece-color piece))) ; Snap to square center
                   piece)) ; Keeps other pieces unchanged
             (eaten-piece dragged-piece pieces)))))

;;;;; handle-mouse ;;;;;

;; Implmentation
(define (handle-mouse state x y event)
  (cond
    [(equal? event "button-down") (handle-button-down state x y)]
    [(equal? event "drag") (handle-drag state x y)]
    [(equal? event "button-up") (handle-button-up state)]
    [else state]))

; Run the program
(big-bang INITIAL-STATE
          (on-mouse handle-mouse)
          (to-draw render))
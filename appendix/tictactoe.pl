;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Tictactoe - GDL Description
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Roles - Each player is assigned one of these roles at the beginning of the match
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (role xplayer)
  (role oplayer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initial State - With the init keyword one can define initial states  of the game.
;; the control keyword defines which player or players have the first move
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (init (cell 1 1 b)) ;; Initialization of the cells with the value 'b'
  (init (cell 1 2 b))
  (init (cell 1 3 b))
  (init (cell 2 1 b))
  (init (cell 2 2 b))
  (init (cell 2 3 b))
  (init (cell 3 1 b))
  (init (cell 3 2 b))
  (init (cell 3 3 b))
  (init (control xplayer)) ;; xplayer has the first move

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dynamic Components - Components that change throughout the game, like the cells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Cell

;; variables are written with '?' in front of them

  (<= (next (cell ?m ?n x)) ;; the cell with coordinates m,n changes to 'x' if...
      (does xplayer (mark ?m ?n)) ;; xplayer chooses to mark it...
      (true (cell ?m ?n b))) ;; and it's still in state 'b' (blank)

  (<= (next (cell ?m ?n o)) ;; same thing for oplayer
      (does oplayer (mark ?m ?n))
      (true (cell ?m ?n b)))

  (<= (next (cell ?m ?n ?w)) ;; the cell changes to state ?w if...
      (true (cell ?m ?n ?w)) ;; it's already in state ?w
      (distinct ?w b)) ;; and ?w isn't blank

  (<= (next (cell ?m ?n b)) ;; the cell ?m ?n changes to 'b' if...
      (does ?w (mark ?j ?k)) ;; player ?w marks ?j ?k...
      (true (cell ?m ?n b)) ;; the cell is already state 'b' or...
      (or (distinct ?m ?j) (distinct ?n ?k))) ;; ?w marked another cell (?m,?n != ?j,?k)

  (<= (next (control xplayer)) ;; if oplayer is in control, xplayer takes control
      (true (control oplayer)))

  (<= (next (control oplayer)) ;; and vice-versa
      (true (control xplayer)))


  (<= (row ?m ?x) ;; a row means 3 cells in the same line with the same state ?x
      (true (cell ?m 1 ?x))
      (true (cell ?m 2 ?x))
      (true (cell ?m 3 ?x)))

  (<= (column ?n ?x) ;; a column means 3 cells in the same column with the same state ?x
      (true (cell 1 ?n ?x))
      (true (cell 2 ?n ?x))
      (true (cell 3 ?n ?x)))

  (<= (diagonal ?x) ;; same idea for each diagonal
      (true (cell 1 1 ?x))
      (true (cell 2 2 ?x))
      (true (cell 3 3 ?x)))

  (<= (diagonal ?x)
      (true (cell 1 3 ?x))
      (true (cell 2 2 ?x))
      (true (cell 3 1 ?x)))


  (<= (line ?x) (row ?m ?x)) ;; a line of ?x exists if there is a row of ?x
  (<= (line ?x) (column ?m ?x)) ;; ...or a column of ?x
  (<= (line ?x) (diagonal ?x)) ;; ...or a diagonal of ?x


  (<= open ;; the game is open if there's at least one cell with the state 'b'
      (true (cell ?m ?n b)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (<= (legal ?w (mark ?x ?y)) ;; player ?w can mark ?x ?y if...
      (true (cell ?x ?y b)) ;; the cell is blank
      (true (control ?w))) ;; player ?w is in control

  (<= (legal xplayer noop) ;; player xplayer can do a 'noop' move (do nothing) if...
      (true (control oplayer))) ;; the oplayer is in control

  (<= (legal oplayer noop) ;; and vice-versa
      (true (control xplayer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (<= (goal xplayer 100) ;; xplayes gets 100 points if there is a line of 'x'
      (line x))

  ;; xplayer gets 50 points if there are no open cells and no lines of 'x' or 'o'
  (<= (goal xplayer 50) 
      (not (line x))
      (not (line o))
      (not open))

  (<= (goal xplayer 0) ;; xplayer gets 0 points if oplayes gets a line
      (line o))

  (<= (goal oplayer 100) ;; same thing for oplayer
      (line o))

  (<= (goal oplayer 50)
      (not (line x))
      (not (line o))
      (not open))

  (<= (goal oplayer 0)
      (line x))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (<= terminal ;; the game ends if there is a line of 'x'
      (line x))

  (<= terminal ;; ...or a line of 'o'
      (line o))

  (<= terminal ;; ...or if the game is no longer open
      (not open))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
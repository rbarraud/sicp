; 2.17
(define (last-pair l)
  (if (null? (cdr l))
      l
      (last-pair (cdr l))))

; 2.18
(define (reverse l)
  (if (= 1 (length l))
      l
      (append (reverse (cdr l))
              (list (car l)))))

; or better still, handle length 0 lists
; (needed for count-change):
(define (reverse l)
  (if (= 0 (length l))
      '()
      (append (reverse (cdr l))
              (list (car l)))))

; 2.19
(define (first-denomination coin-values)
  (car (last-pair coin-values)))

(define (except-first-denomination coin-values)
  (reverse (cdr (reverse coin-values))))

(define (no-more? coin-values)
  (= 0 (length coin-values)))

; Order shouldn't affect it, no
; though might affect efficiency

; 2.20
(define (same-parity x . y)
  (define (same-parity-helper x . y)
  (if (= 0 (length y))
      null
  (if (= (modulo x 2)
         (modulo (car y) 2))
      (cons (car y)
            (apply same-parity-helper x (cdr y)))
      (apply same-parity-helper x (cdr y)))))
  (cons x (apply same-parity-helper x y)))

; will's suggestion: signature of same-parity-helper
; can just be (x y), so you don't have to use apply

; 2.21
(define (square-list items)
  (if (null? items)
      null
      (cons (* (car items) (car items))
            (square-list (cdr items)))))

(define (square-list2 items)
  (map (lambda (x) (* x x)) items))

; 2.22
; It takes things off the head of items list
; and attaches them to the head of answer list
; [1 2 3,] -> [2 3, 1] -> [3, 2 1] -> [,3 2 1]
; The other way
; produces a left-folded rather than a right-folded
; list.
; i.e. ((((), 1), 2), 3), 4) rather than (1, (2, (3, (4, ()))))

; 2.23
(define (for-each proc l)
  (if (null? l)
      null
      (begin
        (proc (car l))
        (for-each proc (cdr l)))))

; 2.24
;   /\
;  1 /\
;   /\ o
;  2 /\
;   /\ o
;  3 /\
;   4  o

; 2.25
; d d a d a
; a a
; d a d a d a d a d a d a

; 2.26
(append x y) ;=>
'(1 2 3 4 5 6)
(cons x y) ;=>
'((1 2 3) 4 5 6)
(list x y) ;=>
'((1 2 3) (4 5 6))

; 2.27
(define (deep-reverse l)
  (if (pair? l)
      (append (deep-reverse (cdr l))
              (list (deep-reverse (car l))))
      l))

; 2.28
; :'(
; this just returns the thing you put it!
(define (fringewrong l)
  (define (fringe-iter l result)
    (cond ((null? l) result)
           ((pair? l) (fringe-iter (cdr l) (cons (fringe-iter (car l) result) result))
          (fringe-iter null (cons l result)))))
  (fringe-iter l null))

; Note: stop trying to do clever thigns and just use append....
; see enumerate-tree

; 2.29
(define (make-mobile left right)
  (list left right))

(define (make-branch length structure)
  (list length structure))

(define left-branch car)
(define right-branch cadr)
(define branch-length car)
(define branch-structure cadr)
(define has-submobiles? list?)

(define example-mobile
  (make-mobile (make-branch 5 2)
               (make-branch 3 (make-mobile (make-branch 2 6)
                                           (make-branch 1 (make-mobile (make-branch 2 1)
                                                                       (make-branch 4 3)))))))

(define (total-branch-weight branch)
  (let ((structure (branch-structure branch)))
    (if (has-submobiles? structure)
        (total-weight structure)
        structure)
    ))

(define (total-weight mobile)
  (+  (total-branch-weight (left-branch mobile))
      (total-branch-weight (right-branch mobile))))

(define (torque branch)
  (* (branch-length branch)
     (total-branch-weight branch)))

(define (balanced? mobile)
  (and (equal? (torque (left-branch mobile))
               (torque (right-branch mobile)))
       (balanced-submobiles? mobile)))

(define (balanced-submobiles? mobile)
  (and (balanced-branch? (left-branch mobile))
       (balanced-branch? (right-branch mobile))))

(define (balanced-branch? branch)
  (let ((structure (branch-structure branch)))
    (if (has-submobiles? structure)
       (balanced? structure)
       true)))

; part 4: need to change little, only s/cadr/cdr in
(define right-branch cadr)
(define branch-structure cadr)

; 2.30
(define (square-tree tree)
  (cond ((null? tree) null)
        ((list? tree)
         (cons (square-tree (car tree))
               (square-tree (cdr tree))))
        (else (* tree tree))))

(define (square-tree tree)
  (map (lambda (sub-tree)
         (if (list? sub-tree)
             (square-tree sub-tree)
             (* sub-tree sub-tree)))
       tree))

; 2.31
; Note: map takes a function of 1 argument
; but that's ok as the lambda closes over the
; definition of proc
(define (tree-map proc tree)
  (map (lambda (sub-tree)
         (if (list? sub-tree)
             (tree-map proc sub-tree)
             (proc sub-tree)))
       tree))

(define (square-tree tree)
  (tree-map square tree))

(define (square x) (* x x))

; 2.32
(define (subsets s)
  (if (null? s)
      (list nil)
      (let ((rest (subsets (cdr s))))
        (append rest (map (lambda (subset) (cons (car s) subset))
                          rest)))))
; subsets of (x U S) = {{} U {x} U_{T subset S} {x U T}}
; the {x} comes out of the null element of rest

; 2.33
(define (map p sequence)
  (accumulate (lambda (item acc) (cons (p item) acc))
              null sequence))

; note the order swapped! accumulate is cons-ing things
; car'd from seq1 onto the accumulator
(define (append seq1 seq2)
  (accumulate cons seq2 seq1))

(define (length sequence)
  (accumulate (lambda (item acc) (+ 1 acc)) 0 sequence))

; 2.34
; This always returns x * the answer!
; could divide by x, but that'd not be in the q template
; need to not * by x in the leftmost iteration, but the
; lambda doesn't know what iteration it's in...
(define
  (horner-eval x coefficient-sequence)
  (accumulate
   (lambda (this-coeff higher-terms)
     (* x (+ this-coeff higher-terms)))
   0
   coefficient-sequence))

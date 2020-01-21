;r5rs
(define (bf program)
 (define char-add1 (lambda (x) (if (= x 255) 0 (+ x 1))))
 (define char-sub1 (lambda (x) (if (= x 0) 255 (- x 1))))
 ;Too slowly
 ;(define make-func (lambda s (lambda arg (apply (car s) (append (cdr s) arg)))))
 ;(define add1 (make-func + 1))
 ;(define sub1 (make-func + -1))
 (define add1 (lambda (x) (+ x 1)))
 (define sub1  (lambda (x) (- x 1)))
 (define (bf-real mem mem-pointer program-pointer)
  (define (find-bracket count x-bracket y-bracket move pointer)
   (let ((c (string-ref program pointer)))
    (if (char=? c x-bracket)
     (find-bracket (add1 count) x-bracket y-bracket move (move pointer))
     (if (char=? c y-bracket)
      (if (= count 1) pointer
       (find-bracket (sub1 count) x-bracket y-bracket move (move pointer)))
      (find-bracket count x-bracket y-bracket move (move pointer))))))
  ;(define find-open-square-bracket (make-func find-bracket 0 #\] #\[ sub1))
  ;(define find-close-square-bracket (make-func find-bracket 0 #\[ #\] add1))
  (define (find-open-square-bracket x) (find-bracket 0 #\] #\[ sub1 x))
  (define (find-close-square-bracket x) (find-bracket 0 #\[ #\] add1 x))
  (define (change-mem f)
   (define (change lst pos)
    (if (zero? pos) (cons (f (car lst)) (cdr lst))
     (cons (car lst) (change (cdr lst) (sub1 pos)))))
   (change mem mem-pointer))

  (if (>= program-pointer (string-length program)) (void)
   (case (string-ref program program-pointer)
    ((#\+) (bf-real (change-mem char-add1) mem-pointer (add1 program-pointer)))
    ((#\-) (bf-real (change-mem char-sub1) mem-pointer (add1 program-pointer)))
    ((#\>) (bf-real (if (zero? mem-pointer) (cons 0 mem) mem) (max 0 (- mem-pointer 1)) (add1 program-pointer)))
    ((#\<) (bf-real mem (add1 mem-pointer) (add1 program-pointer)))
    ((#\.) (begin (display (integer->char (list-ref mem mem-pointer))) (bf-real mem mem-pointer (add1 program-pointer))))
    ((#\,) (bf-real (change-mem (lambda (x) (char->integer (read-char)))) mem-pointer (add1 program-pointer)))
    ((#\[) (bf-real mem mem-pointer (add1 (if (zero? (list-ref mem mem-pointer)) (find-close-square-bracket program-pointer) program-pointer))))
    ((#\]) (bf-real mem mem-pointer (find-open-square-bracket program-pointer)))
    (else (bf-real mem mem-pointer (add1 program-pointer))))))
 (bf-real '(0) 0 0))

(define (get-line)
 (define (get-line-it s)
  (let ((c (read-char)))
   (if (or (eof-object? c) (member c '(#\return #\newline))) s
    (get-line-it (string-append s (make-string 1 c))))))
 (get-line-it ""))

(define (read-all file)
 (define (read-all-it port s)
  (let ((c (read-char port)))
   (if (eof-object? c) s
    (read-all-it
     port
     (string-append s (make-string 1 c))))))
 (read-all-it (open-input-file file) ""))

(define (filt-program program)
 (list->string
  (filter
   (lambda (x) (member x (string->list "+-><.,[]:!")))
    (string->list program))))

(display "Input the bf file")
(newline)
(bf (filt-program (read-all (get-line))))

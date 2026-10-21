(use-modules (srfi srfi-1))

(define args
  (cdr (command-line)))

(define (has? options)
  (any (lambda (option)
         (member option args))
       options))

(define final-args
  (if (or (null? args)
          (has? '("-a" "--armor"
                  "-d" "--decrypt"
                  "-h" "--help"
                  "-V" "--version")))
      args
      (cons "--armor" args)))

(apply execl
       %rage-unwrapped
       "rage"
       final-args)

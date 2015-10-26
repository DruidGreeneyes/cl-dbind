(defpackage #:dbind
  (:use #:cl))

(in-package #:dbind)

(defmacro dbind (vars list &body body)
  (let* ((gensyms ())
         (realvars (copy-list vars)))
    (flet ((handle (sym)
             (if (eql sym '_)
                 (let ((s (gensym))) (push s gensyms) s)
                 sym)))
      (loop for cons on realvars
         for sym = (car cons)
         do (setf (car cons) (handle sym))
           (unless (consp (cdr cons))
             (setf (cdr cons) (handle (cdr cons)))
             (return))))
    `(destructuring-bind ,realvars ,list
       (declare (ignore ,@gensyms))
       ,@body)))

(defun test-dbind ()
  (dbind ((_ . foo) _ . bar) '(1 2 3 4 5 6) (values foo bar)))

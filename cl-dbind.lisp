;;;; cl-dbind.lisp

(in-package #:cl-dbind)

;;; "cl-dbind" goes here. Hacks and glory await!

(defun interned-p (sym)
  (find-symbol (symbol-name sym)))

(defmacro dbind (vars list &body body)
  (let ((gensyms ()))
    (labels
        ((process-symbol (sym)
           (case sym
             (_ (let ((s (gensym)))
                  (push s gensyms)
                  s))
             (t sym))
           (process-list sym)))
      
      (process-list (ls)
                    (if (atom ls)
                        (process-symbol ls)
                        (cons (process-symbol (car ls))
                              (process-list (cdr ls))))))

    (let ((new-vars (process-list vars)))
      `(destructuring-bind ,new-vars
           ,list
         (declare (ignore ,@gensyms))
         ,@body)))))

(defmacro d-binding (def name vars &rest body)
  (let ((list-vars ()))
    (labels
        ((gensym-list-var (var)
           (if (consp var)
               (let ((s (gensym)))
                 (push var list-vars)
                 (push s list-vars)
                 s)
               var)))
      
      (let ((new-vars (mapcar #'gensym-list-var vars)))
        (labels
            ((dbind-list-vars (lis)
               (let ((item (car lis))
                     (nxt (member-if-not #'interned-p (cdr lis))))
                 (if (null nxt)
                     `(dbind ,(getf list-vars item) ,item
                        ,@body)
                     `(dbind ,(getf list-vars item) ,item
                        ,(dbind-list-vars nxt))))))
          
          `(,def ,name ,new-vars
             ,(dbind-list-vars (member-if-not #'interned-p new-vars))))))))

(defmacro with-dbind-vars (vars-place body-place statement)
  (let* ((vars (nth vars-place statement))
         (body (nthcdr body-place statement))
         (st (butlast statement (length body)))
         (list-vars ()))
    (labels
        ((gensym-list-var (var)
           (if (consp var)
               (let ((s (gensym)))
                 (push var list-vars)
                 (push s list-vars)
                 s)
               var))
         
         (dbind-list-vars (lis)
           (let ((item (car lis))
                 (nxt (member-if-not #'interned-p (cdr lis))))
             (if (null nxt)
                 `(dbind ,(getf list-vars item) ,item
                    ,@body)
                 `(dbind ,(getf list-vars item) ,item
                    ,(dbind-list-vars nxt)))))
         
         (generate-dbinds (lis)
           `(,(dbind-list-vars (member-if-not #'interned-p lis)))))
      
      (let ((new-vars (mapcar #'gensym-list-var vars)))
        (setf (nth vars-place st) new-vars)
        `,(nconc st (generate-dbinds new-vars))))))

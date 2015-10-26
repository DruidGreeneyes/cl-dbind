TODO
- [ ] de-duplicate the tail end of d-binding
- [ ] extract the functions so they can stand on their own
- [ ] reader macro?
- [ ] add option to use `cl-pattern:match` instead?

# cl-dbind
(is not dynamic bind)

dbind is a wrapper around [`destructuring-bind`](http://www.lispworks.com/documentation/HyperSpec/Body/m_destru.htm). It does two things:

###FIRST

`d-bind` lets you call `destructuring-bind` with blanks:

```common-lisp
(defun my-fun (lis)
  (d-bind (_ . tail)
      lis
    (format t "~{~A ~}" tail)))
```
`d-bind` can take apart arbitrarily nested structures, just like `destructuring-bind`:
```common-lisp
(defun my-more-complicated-fun (lis)
  (d-bind ((((_ f) o (ob . _) _ ) ar) . baz)
      lis
    (format t "~{~A ~}" (list f o ob ar baz))))
```

###SECOND

`d-binding` lets you build `d-bind` into the parameter list of a definition:

```common-lisp
(d-binding defun my-fun ((head . tail) something-else)
  (format t "~A" head)
  (format t "~{~A ~}" tail)
  (format t "~A" something-else))
```

`d-binding` works for anything that uses the same block as `defun` to declare parameters. `defmacro` will work. `defmethod` hasn't been tested, but if you use a qualifier (`defmethod foo :after`) it will definitely fail, and you will cry.

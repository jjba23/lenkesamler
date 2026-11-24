;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (lenkesamler renderer markdown)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (lenkesamler prelude)
  #:export (markdown-bookmark-renderer))

(define* (markdown-bookmark-renderer xs
                                #:key (indent 1))
  (string-join (map (lambda (x)
                      (cond
                        ((dir-record? x)
                         (format #f "\n\n~a ~a\n~a"
                                 (make-string indent #\#)
                                 (dir-name x)
                                 (markdown-bookmark-renderer (dir-items x)
                                                        #:indent (+ 1 indent))))
                        ((url-record? x)
                         (format #f "\n- [~a](~a)"
                                 (url-name x)
                                 (url-string-with-protocol (url-link x))))
                        (else (throw "unknown data type for bookmark" x))))
                    ;; A bookmarks file is a program: the README builds folders
                    ;; with `map', so a list can hold lists.  Flattened here, at
                    ;; the one place every item passes through.
                    (flatten xs))
               ""))

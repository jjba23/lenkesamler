;;; Lenkesamler

;; Copyright © Josep Jesus Bigorra Algaba

;; lenkesamler is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; lenkesamler is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.

;; You should have received a copy of the GNU Affero General Public License
;; along with lenkesamler. If not, see <https://www.gnu.org/licenses/>.

(define-module (lenkesamler renderer scheme)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 format)
  #:use-module (lenkesamler prelude)
  #:export (scheme-bookmark-renderer))

;;; A bookmarks file written back as a bookmarks file.
;;;
;;; Every other mode of this program is a way out of the DSL; this one is the
;;; way back in.  It is what makes a bookmarks file that came from somewhere
;;; else -- a browser's export, another tool's dump, a file of a format this
;;; project stops rendering tomorrow -- into a file a person can edit, and it is
;;; what makes a bookmarks file that is already one round-trip through the
;;; program unchanged.
;;;
;;; What is written is a module of the shape the README documents: a
;;; `define-module' that imports the prelude, and `lenkesamler-bookmarks' as a
;;; list of `dir' and `url' forms.  A value is written with `write', not with
;;; `display': a name holding a quote, a backslash or a character outside ASCII
;;; is then a string that reads back as the string it was, which is the whole
;;; point of writing a file that is to be read again.
;;;
;;; A `#:name' equal to the link is left out, because `(url "x")' already names
;;; a link `x' -- a file read and written again then says what it said, and not
;;; what this renderer found it convenient to write.  A day and a set of tags are
;;; written only when the link was given them.

(define (quoted value)
  "VALUE as the Scheme source that reads back as VALUE."
  (call-with-output-string (lambda (port) (write value port))))

(define (url-source url)
  "URL as the `url' form that makes it."
  (string-append "(url "
                 (quoted (url-link url))
                 (if (equal? (url-name url) (url-link url))
                     ""
                     (format #f " #:name ~a" (quoted (url-name url))))
                 (if (url-added url)
                     (format #f " #:added ~a" (quoted (url-added url)))
                     "")
                 (if (list? (url-tags url))
                     (format #f " #:tags '~a" (quoted (url-tags url)))
                     "")
                 ")"))

(define* (source-of item #:key (indent 0))
  "ITEM as the form that makes it, its children below it and INDENT spaces in."
  (cond
    ((url-record? item) (url-source item))
    ((dir-record? item)
     (let* ((children (flatten (dir-items item)))
            (child-indent (+ indent 5)))
       (string-append "(dir "
                      (quoted (dir-name item))
                      (if (null? children)
                          ""
                          (string-append
                           "\n"
                           (string-join
                            (map (lambda (child)
                                   (string-append
                                    (make-string child-indent #\space)
                                    (source-of child
                                               #:indent child-indent)))
                                 children)
                            "\n")))
                      ")")))
    (else (throw "unknown data type for bookmark" item))))

(define (scheme-bookmark-renderer xs)
  "XS as the source of a bookmarks file: the module the README documents.

An empty file is still a file: it is written with an empty list, so reading it
gives no bookmarks rather than an error."
  (let ((items (flatten xs)))
    (string-append
     ";;; Lenkesamler bookmarks.\n"
     "\n"
     ";; Written by lenkesamler: a bookmarks file, to be edited by hand.\n"
     "\n"
     "(define-module (lenkesamler bookmarks)\n"
     "  #:declarative? #t\n"
     "  #:use-module (lenkesamler prelude))\n"
     "\n"
     "(define lenkesamler-bookmarks\n"
     "  (list"
     (string-join (map (lambda (item)
                         (string-append "\n   "
                                        (source-of item #:indent 3)))
                       items)
                  "")
     "))\n")))

;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (lenkesamler importer json)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 format)
  #:use-module (json)
  #:use-module (lenkesamler prelude)
  #:export (parse-json-bookmarks))

;;; Reading back the JSON this project writes.
;;;
;;; The document is `{"bookmarks": [...]}', an entry holding `items' being a
;;; folder and an entry holding `link' being a bookmark -- the shape
;;; `(lenkesamler renderer json)' writes, and the shape a reader who pipes this
;;; program into `jq' already knows.  A bare `[...]' of the same entries is read
;;; as well: a list of bookmarks is what the document holds, whether or not it
;;; was written inside an object.
;;;
;;; Two values need care on the way back.  A link with no day is written as
;;; `false', which is what a reader of the file finds in the column and not what
;;; a link with no day holds: it comes back as no day.  And tags, which the JSON
;;; holds as strings because JSON has no symbols, come back as the symbols a
;;; bookmarks file names them with -- which is what every other renderer of this
;;; project reads them as.

(define (field document name)
  "The NAME of the parsed DOCUMENT, or #f when it does not hold one."
  (let ((found (and (list? document) (assoc name document))))
    (and found (cdr found))))

(define (tags-of written)
  "The tags WRITTEN holds, as the symbols a bookmarks file names them with."
  (and (vector? written)
       (let ((tags (filter-map (lambda (tag)
                                 (let ((name (format #f "~a" tag)))
                                   (and (not (string-null? name))
                                        (string->symbol name))))
                               (vector->list written))))
         (and (pair? tags) tags))))

(define (item-of item)
  "ITEM, one entry of the document, as the folder or the link it describes."
  (let ((items (field item "items")))
    (if (vector? items)
        (apply dir (or (field item "name") "")
               (map item-of (vector->list items)))
        (let ((link (or (field item "link") "")))
          (url link
               #:name (or (field item "name") link)
               ;; `false' is what a link with no day is written as, and no day
               ;; is what it says.
               #:added (let ((added (field item "added")))
                         (and (string? added) added))
               #:tags (tags-of (field item "tags")))))))

(define (bookmarks-of-document parsed)
  "The list of entries the parsed JSON DOCUMENT holds."
  (cond
    ((vector? parsed) parsed)
    ((vector? (field parsed "bookmarks")) (field parsed "bookmarks"))
    (else (error "lenkesamler: this JSON is not a list of bookmarks"
                 "-- expected an object holding `bookmarks', or a list of them"))))

(define (parse-json-bookmarks text)
  "TEXT, a bookmarks document of this project's JSON, as the bookmarks it holds."
  (map item-of (vector->list (bookmarks-of-document (json-string->scm text)))))

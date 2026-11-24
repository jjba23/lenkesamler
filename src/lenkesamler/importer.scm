;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (lenkesamler importer)
  #:declarative? #t
  #:use-module (srfi srfi-14)
  #:use-module (srfi srfi-13)
  #:use-module (lenkesamler importer json)
  #:use-module (lenkesamler importer netscape)
  #:export (bookmarks-of-import-text))

;;; Reading a bookmarks file that came from somewhere else.
;;;
;;; Two readers, one door.  What a browser exports is HTML -- it begins with a
;;; declaration or a tag, or with the comment browsers put in front of the file
;;; -- and what this project writes as `json' is a document that begins with an
;;; object or a list.  So the reader is chosen by the first character of the
;;; file that is not white space, and nothing has to be declared: a file that
;;; holds bookmarks is read as the bookmarks it holds.
;;;
;;; The choice is made by content and not by name for the reason a file of
;;; bookmarks is worth reading at all: it is a file a person saved or copied, and
;;; `bookmarks.html' holding a JSON document, or `bookmarks.json' holding what a
;;; browser exported, is a mistake nobody should have to fix before migrating.

(define (first-content-character text)
  "The first character of TEXT that is not white space, or #f for no text."
  (let loop ((index 0))
    (if (>= index (string-length text))
        #f
        (let ((character (string-ref text index)))
          (if (char-set-contains? char-set:whitespace character)
              (loop (+ index 1))
              character)))))

(define (json-document? text)
  "Whether TEXT begins an object or a list, which is how a JSON document begins."
  (memv (first-content-character text) '(#\{ #\[)))

(define (bookmarks-of-import-text text)
  "TEXT, a bookmarks file that came from somewhere else, as the bookmarks it holds.

A JSON document of this project's own is read as JSON, and anything else is read
as the file a browser exports."
  (if (json-document? text)
      (parse-json-bookmarks text)
      (parse-netscape-bookmarks text)))

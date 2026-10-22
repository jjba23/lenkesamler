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

(define-module (lenkesamler renderer csv)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (lenkesamler prelude)
  #:export (csv-bookmark-renderer))

;;; A bookmarks file as a spreadsheet: one row per link.
;;;
;;; The CSV format has no way to say that a row is a folder, so a folder is
;;; carried in a column: `folder' holds the path of the folders a link was
;;; written in, outermost first, and is empty for a link of the top level.  A
;;; reader sorting the sheet by that column gets the bookmarks of a folder
;;; together, and a reader who only wants the addresses gets a column of them.
;;;
;;; A field is written as RFC 4180 says to write one: quoted when it holds a
;;; comma, a quote or a line break, with the quotes in it doubled.  A name is a
;;; name somebody typed -- `R&D, notes', `a "quoted" read' -- so this is not an
;;; edge case to be tidied away: an unquoted comma moves every column of the row
;;; after it.

(define header
  '("folder" "name" "url" "added" "tags"))

(define (field value)
  "VALUE as one field of a line of the sheet.

Empty for `#f', which is what a link that was given no day holds: a column that
says nothing rather than the word `false'."
  (let ((text (if value (format #f "~a" value) "")))
    (if (string-any (lambda (character)
                      (memv character '(#\" #\, #\newline #\return)))
                    text)
        (string-append "\""
                       (string-replace-substring text "\"" "\"\"")
                       "\"")
        text)))

(define (line fields)
  "FIELDS as one line of the sheet."
  (string-join (map field fields) ","))

(define (tags-field tags)
  "TAGS as the one field they share."
  (if (list? tags)
      (string-join (map (lambda (tag)
                          (format #f "~a" tag)) tags)
                   ", ")
      ""))

(define* (rows-of items #:key (folder ""))
  "The rows ITEMS makes, each link under the path FOLDER the folders give it."
  (append-map (lambda (item)
                (cond
                  ((dir-record? item)
                   (rows-of (dir-items item)
                            #:folder (if (string-null? folder)
                                         (dir-name item)
                                         (format #f "~a/~a"
                                                 folder (dir-name item)))))
                  ((url-record? item)
                   (list (list folder
                               (url-name item)
                               (url-string-with-protocol (url-link item))
                               (url-added item)
                               (tags-field (url-tags item)))))
                  (else (throw "unknown data type for bookmark" item))))
              ;; A bookmarks file is a program, so a list can be inside the list
              ;; of bookmarks, the way the README builds folders with `map'.
              (flatten items)))

(define (csv-bookmark-renderer xs)
  "XS as a comma-separated document, one row per link, with a header row."
  (string-join (cons (line header)
                     (map line (rows-of xs)))
               "\n"))

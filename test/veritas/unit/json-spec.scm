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

;;; The JSON reading of a bookmarks file, read back as data.
;;;
;;; The document is parsed again rather than compared as text: what a reader of
;;; the JSON depends on is the shape of it -- a list of bookmarks under
;;; `bookmarks', folders with their `items', links with their `link', `name' and
;;; the `added' and `tags' they were given -- and not the spaces the writer
;;; happens to put between them.
;;;
;;; The readings worth taking here are of a value a link may not carry: a link
;;; with no day is `added: false' rather than a missing key, so a reader of the
;;; file always finds the key, and one with no tags carries no `tags' key at
;;; all, because an empty list of tags is not a list of tags.
;;;
;;; A bookmarks file is a program, so a list can be inside the list of
;;; bookmarks; the README builds folders that way.  That list is read as the
;;; bookmarks it holds, which makes the JSON one list either way.

(define-module (veritas unit json-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler renderer json)
  #:use-module (json)
  #:export (spec))

;;; ====== A bookmarks file, read as data ======

(define bookmarks
  (list (dir "Work"
             (url "codeberg.org/jjba23"
                  #:name "Codeberg"
                  #:added "2025-01-22"
                  #:tags '(dev))
             (dir "Ops"
                  (url "grafana.test-backend.nl"
                       #:name "Grafana")))
        (url "mastodon.social"
             #:name "Mastodon")))

(define (document-of bookmarks)
  "BOOKMARKS as the data of a JSON document."
  (json-string->scm (json-bookmark-renderer bookmarks)))

(define (bookmarks-of document)
  "The list of bookmarks the parsed DOCUMENT holds."
  (cdr (assoc "bookmarks" document)))

(define (items-of folder)
  "The items of the parsed FOLDER."
  (cdr (assoc "items" folder)))

(define (field-of bookmark key)
  "The KEY of the parsed BOOKMARK."
  (cdr (assoc key bookmark)))

;;; ====== The suite ======

(define json-suite
  (suite "the JSON reading"
         #:shuffle? #f
         (test "a folder is a list of its items"
               #:shuffle? #f
               (let ((folder (vector-ref (bookmarks-of (document-of bookmarks))
                                         0)))
                 (assert-equal #:name "the name of the folder"
                               #:expect "Work"
                               #:got (field-of folder "name"))
                 (assert-equal #:name "and the bookmarks written in it"
                               #:expect 2
                               #:got (vector-length (items-of folder)))
                 (assert-equal #:name "and a folder of it is a folder of the JSON"
                               #:expect "Ops"
                               #:got (field-of (vector-ref (items-of folder) 1)
                                               "name"))))
         (test "a link is its address, its name and what it was given"
               #:shuffle? #f
               (let ((link (vector-ref (items-of (vector-ref (bookmarks-of (document-of bookmarks))
                                                             0))
                                       0)))
                 (assert-equal #:name "the address it is reached by"
                               #:expect "https://codeberg.org/jjba23"
                               #:got (field-of link "link"))
                 (assert-equal #:name "the name it was given"
                               #:expect "Codeberg"
                               #:got (field-of link "name"))
                 (assert-equal #:name "the day it was added"
                               #:expect "2025-01-22"
                               #:got (field-of link "added"))
                 (assert-equal #:name "and its tags, as strings"
                               #:expect #("dev")
                               #:got (field-of link "tags"))))
         (test "a link that was given no day and no tags"
               #:shuffle? #f
               (let ((link (vector-ref (bookmarks-of (document-of bookmarks))
                                       1)))
                 (assert-equal #:name "is written with a day of false"
                               #:expect #f
                               #:got (field-of link "added"))
                 (assert-equal #:name "and with no tags at all"
                               #:expect #f
                               #:got (assoc "tags" link))
                 (assert-equal #:name "and it is still reached over https"
                               #:expect "https://mastodon.social"
                               #:got (field-of link "link"))))
         (test "a folder built by map is the bookmarks it holds"
               #:shuffle? #f
               (assert-equal #:name
                "a list inside the list of bookmarks is read as its links, in order"
                #:expect '("A" "B")
                #:got (map (lambda (link)
                             (field-of link "name"))
                           (vector->list (bookmarks-of (document-of (list (list (url "a.example"
                                                                                  #:name "A")
                                                                             (url "b.example"
                                                                                  #:name "B")))))))))))

(define (spec)
  (veritas-run json-suite))

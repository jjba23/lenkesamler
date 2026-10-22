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

;;; The Org mode reading of a bookmarks file.
;;;
;;; A folder is a heading, one `*' deeper for a folder inside it, and a link is
;;; a list item of `[[address][name]]` -- the address first, which is the order
;;; Org reads a link in.  The address is the one a browser follows, so a link
;;; written without a scheme is written with one.
;;;
;;; A bookmarks file is a program, so a list can be inside the list of
;;; bookmarks; the README builds folders that way.  That list is read as the
;;; bookmarks it holds rather than handed to the join that writes the document,
;;; which is what used to take the whole run down: a list is not a string.

(define-module (veritas unit org-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler renderer org)
  #:export (spec))

;;; ====== A bookmarks file, read as a document ======

(define bookmarks
  (list (dir "Work"
             (url "codeberg.org/jjba23"
                  #:name "Codeberg")
             (dir "Ops"
                  (url "grafana.test-backend.nl"
                       #:name "Grafana")))
        (url "mastodon.social"
             #:name "Mastodon")))

(define (document-of bookmarks)
  "BOOKMARKS as an Org mode document."
  (org-bookmark-renderer bookmarks))

;;; ====== The suite ======

(define org-suite
  (suite "the Org mode reading"
         #:shuffle? #f
         (test "a folder is a heading"
               #:shuffle? #f
               (assert-contains #:name "a folder of the top level is a first-level heading"
                #:expect (document-of bookmarks)
                #:got "* Work")
               (assert-contains #:name "and a folder inside it is the heading under it"
                #:expect (document-of bookmarks)
                #:got "** Ops"))
         (test "a link is an item of the list"
               #:shuffle? #f
               (assert-contains #:name
                "a link is the address it is reached by, then its name"
                #:expect (document-of bookmarks)
                #:got "- [[https://codeberg.org/jjba23][Codeberg]]")
               (assert-contains #:name "and a link of the top level is an item as well"
                #:expect (document-of bookmarks)
                #:got "- [[https://mastodon.social][Mastodon]]"))
         (test "a folder built by map is the bookmarks it holds"
               #:shuffle? #f
               (assert-equal #:name
                "a list inside the list of bookmarks is read as its links, in order"
                #:expect "\n- [[https://a.example][A]]\n- [[https://b.example][B]]"
                #:got (document-of (list (list (url "a.example" #:name "A")
                                              (url "b.example" #:name "B"))))))))

(define (spec)
  (veritas-run org-suite))

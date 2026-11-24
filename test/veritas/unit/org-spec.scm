;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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

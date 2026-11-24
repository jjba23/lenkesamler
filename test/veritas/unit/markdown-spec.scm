;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; The Markdown reading of a bookmarks file.
;;;
;;; A folder is a heading, one `#' deeper for a folder inside it, and a link is
;;; a list item of `[name](address)`.  The address is the one a browser follows,
;;; so a link written without a scheme is written with one.
;;;
;;; A bookmarks file is a program, so a list can be inside the list of
;;; bookmarks; the README builds folders that way.  That list is read as the
;;; bookmarks it holds rather than handed to the join that writes the document,
;;; which is what used to take the whole run down: a list is not a string.

(define-module (veritas unit markdown-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler renderer markdown)
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
  "BOOKMARKS as a Markdown document."
  (markdown-bookmark-renderer bookmarks))

;;; ====== The suite ======

(define markdown-suite
  (suite "the Markdown reading"
         #:shuffle? #f
         (test "a folder is a heading"
               #:shuffle? #f
               (assert-contains #:name "a folder of the top level is a first-level heading"
                #:expect (document-of bookmarks)
                #:got "# Work")
               (assert-contains #:name "and a folder inside it is the heading under it"
                #:expect (document-of bookmarks)
                #:got "## Ops"))
         (test "a link is an item of the list"
               #:shuffle? #f
               (assert-contains #:name "a link is its name, over the address it is reached by"
                #:expect (document-of bookmarks)
                #:got "- [Codeberg](https://codeberg.org/jjba23)")
               (assert-contains #:name "and a link of the top level is an item as well"
                #:expect (document-of bookmarks)
                #:got "- [Mastodon](https://mastodon.social)"))
         (test "a folder built by map is the bookmarks it holds"
               #:shuffle? #f
               (assert-equal #:name
                "a list inside the list of bookmarks is read as its links, in order"
                #:expect "\n- [A](https://a.example)\n- [B](https://b.example)"
                #:got (document-of (list (list (url "a.example" #:name "A")
                                              (url "b.example" #:name "B"))))))))

(define (spec)
  (veritas-run markdown-suite))

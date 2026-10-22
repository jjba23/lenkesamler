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

;;; The terminal reading of a bookmarks file: what a person sees when they run
;;; lenkesamler to look at what they have collected.
;;;
;;; A folder is a name in brackets, its bookmarks four spaces in, and a folder
;;; inside it four spaces further.  A link is its name, the day it was added
;;; when it was given one, its tags, and the address it is reached by -- the tags
;;; written the way a person says them, `dev, calc', rather than the list an
;;; S-expression would show, `(dev calc)'.
;;;
;;; A bookmarks file is a program, so a list can be inside the list of
;;; bookmarks; the README builds folders that way.  That list is read as the
;;; bookmarks it holds.  The last reading is of a value that is neither a link
;;; nor a folder: a spec that says it raises, because a renderer that quietly
;;; skipped it would lose a bookmark in silence.

(define-module (veritas unit cli-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler renderer cli)
  #:export (spec))

;;; ====== A bookmarks file, read in the terminal ======

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

(define (reading-of bookmarks)
  "BOOKMARKS as the terminal a person reads them in."
  (cli-bookmark-renderer bookmarks))

;;; ====== The suite ======

(define cli-suite
  (suite "the terminal reading"
         #:shuffle? #f
         (test "a folder is a name in brackets"
               #:shuffle? #f
               (assert-contains #:name "the name of the folder is written in brackets"
                #:expect (reading-of bookmarks)
                #:got "[Work]")
               (assert-contains #:name "and its bookmarks are indented under it"
                #:expect (reading-of bookmarks)
                #:got "\n    Codeberg")
               (assert-contains #:name "and a folder inside it is indented further"
                #:expect (reading-of bookmarks)
                #:got "\n    [Ops]\n        Grafana"))
         (test "a link is its name, its day, its tags and its address"
               #:shuffle? #f
               (assert-contains #:name
                "a link is a line of its own, with the day it was added"
                #:expect (reading-of bookmarks)
                #:got "    Codeberg added: 2025-01-22  dev  | https://codeberg.org/jjba23\n")
               (assert-contains #:name
                "a link with no day and no tags is only its name and its address"
                #:expect (reading-of bookmarks)
                #:got "Mastodon | https://mastodon.social\n"))
         (test "the tags of a link are said, not listed"
               #:shuffle? #f
               (assert-contains #:name "two tags are written one after the other"
                #:expect (reading-of (list (url "x.example"
                                               #:name "N"
                                               #:tags '(dev calc))))
                #:got "dev, calc")
               (assert-not-contains #:name "and never as the list they are held in"
                #:expect (reading-of (list (url "x.example"
                                               #:name "N"
                                               #:tags '(dev calc))))
                #:got "(dev calc)"))
         (test "a list inside the list of bookmarks is read as its bookmarks"
               #:shuffle? #f
               (assert-equal #:name
                "a folder built by map is written as the links it holds"
                #:expect "A | https://a.example\nB | https://b.example\n"
                #:got (reading-of (list (list (url "a.example" #:name "A")
                                             (url "b.example" #:name "B"))))))
         (test "a value that is not a bookmark is refused"
               #:shuffle? #f
               (assert-error (lambda ()
                               (reading-of (list 42)))
                             #:name "a number in a bookmarks file is an error, not a line"))))

(define (spec)
  (veritas-run cli-suite))

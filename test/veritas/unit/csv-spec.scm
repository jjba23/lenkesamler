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

;;; The spreadsheet reading of a bookmarks file.
;;;
;;; A sheet has one shape, so a bookmarks file's shape is carried in its
;;; columns: a link is a row, and the folders it was written in are the `folder'
;;; column, outermost first, empty for a link of the top level.  A reader who
;;; sorts by that column reads a folder's bookmarks together, and a reader who
;;; only wants addresses has a column of them.
;;;
;;; The readings that matter here are of a name somebody typed.  A name is not
;;; written for a field: `R&D, notes' holds the separator and `a "quoted" read'
;;; holds the quote character -- and a comma written as it stands moves every
;;; column of the row behind it.  The last reading is of a value a link may not
;;; carry: the column for the day of a link that has no day says nothing, which
;;; is what a spreadsheet is asked for, rather than the word `false'.

(define-module (veritas unit csv-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-13)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler renderer csv)
  #:export (spec))

;;; ====== A bookmarks file, read as a sheet ======

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
  "BOOKMARKS as a CSV document."
  (csv-bookmark-renderer bookmarks))

(define (lines-of bookmarks)
  "The lines BOOKMARKS is read as."
  (string-split (document-of bookmarks) #\newline))

;;; ====== The suite ======

(define csv-suite
  (suite "the spreadsheet reading"
         #:shuffle? #f
         (test "a sheet says what its columns are"
               #:shuffle? #f
               (assert-equal #:name "the first line names the columns"
                             #:expect "folder,name,url,added,tags"
                             #:got (car (lines-of bookmarks)))
               (assert-equal #:name "a sheet of no bookmarks is still a sheet"
                             #:expect '("folder,name,url,added,tags")
                             #:got (lines-of '())))
         (test "a link is a row of the sheet"
               #:shuffle? #f
               (assert-equal #:name "a folder is not a row of its own"
                             #:expect 4
                             #:got (length (lines-of bookmarks)))
               (assert-equal #:name
                "a link of a folder says which folder it is in"
                #:expect "Work,Codeberg,https://codeberg.org/jjba23,2025-01-22,dev"
                #:got (list-ref (lines-of bookmarks) 1))
               (assert-equal #:name
                "a folder inside it is a path of two names"
                #:expect "Work/Ops,Grafana,https://grafana.test-backend.nl,,"
                #:got (list-ref (lines-of bookmarks) 2))
               (assert-equal #:name "and a link of the top level is in no folder"
                             #:expect ",Mastodon,https://mastodon.social,,"
                             #:got (list-ref (lines-of bookmarks) 3)))
         (test "a name is written as a field, not as it was typed"
               #:shuffle? #f
               (assert-equal #:name "a name holding the separator is quoted"
                             #:expect ",\"R&D, notes\",https://example.org,,"
                             #:got (cadr (lines-of (list (url "example.org"
                                                             #:name "R&D, notes")))))
               (assert-equal #:name
                "and the quote characters in a name are doubled"
                #:expect "\"a \"\"quoted\"\" read\",example.org,https://example.org,,"
                #:got (cadr (lines-of (list (dir "a \"quoted\" read"
                                                (url "example.org"))))))
               (assert-equal #:name "while a name with nothing to quote is as typed"
                             #:expect ",Mastodon,https://mastodon.social,,"
                             #:got (list-ref (lines-of bookmarks) 3)))
         (test "the tags of a link are one field of the row"
               #:shuffle? #f
               (assert-equal #:name
                "two tags are said one after the other, in the field they share"
                #:expect ",N,https://x.example,,\"dev, calc\""
                #:got (cadr (lines-of (list (url "x.example"
                                                #:name "N"
                                                #:tags '(dev calc)))))))
         (test "a folder built by map is read as the links it holds"
               #:shuffle? #f
               (assert-equal #:name
                "a list inside the list of bookmarks is read as its rows, in order"
                #:expect '("folder,name,url,added,tags"
                           ",A,https://a.example,,"
                           ",B,https://b.example,,")
                #:got (lines-of (list (list (url "a.example" #:name "A")
                                           (url "b.example" #:name "B"))))))))

(define (spec)
  (veritas-run csv-suite))

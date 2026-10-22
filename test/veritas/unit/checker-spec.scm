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

;;; Whether the links of a bookmarks file are still there.
;;;
;;; The reading is not of the internet.  A spec that asked the internet whether
;;; a page is up would fail on the day the page is not, and would say nothing
;;; about this program on that day: what a check is, is what it makes of the
;;; answer it is given.  So the answers are given -- one `probe' standing in for
;;; the server, answering in the shape `http-probe' answers in -- and what is
;;; read is the report a file of broken links makes.
;;;
;;; The readings of that report are what a run can find.  A page that answers is
;;; there; one that answers elsewhere has moved, which is worth a line and is not
;;; a failure, because the bookmark still leads somewhere; one that answers with
;;; a refusal, and one that does not answer at all, are the two ways a link is
;;; gone, and those are what make a run exit non-zero.
;;;
;;; Two more readings are of what a check must not do.  A folder is walked, not
;;; only the top level, because most of a bookmarks file is in folders -- a
;;; checker that read the top level and nothing else would call an untouched
;;; file healthy.  And an address written twice is asked once: two folders
;;; holding the same page are a person's bookmarks, not two pages.
;;;
;;; The last reading is of a link that is not a page.  A `mailto:' address is a
;;; bookmark and has no server to ask, so it is skipped and the run is not a
;;; failure: a file holding one would otherwise fail every time it was checked.

(define-module (veritas unit checker-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler checker)
  #:export (spec))

;;; ====== A server, answering what it is told to answer ======

(define (probe-answering answers)
  "A probe that answers each address with its entry in ANSWERS.

An address with no entry answers 200, so that a reading only says what it means
to say about the answers it names.  An entry is `(CODE . LOCATION)' or
`(CODE . #f)', which is what `http-probe' answers."
  (lambda (address)
    (let ((answer (assoc address answers)))
      (if answer
          (cdr answer)
          (cons 200 #f)))))

(define (probe-that-says-nothing address)
  "A probe that cannot reach anything: a server that is not there."
  (throw 'getaddrinfo-error "Name or service not known"))

;;; ====== A bookmarks file ======

(define bookmarks
  (list (dir "Work"
             (url "a.example" #:name "A"))
        (url "b.example" #:name "B")
        (url "c.example" #:name "C")))

;; The answers that file gets: a link that is there -- the first, which is the
;; one inside a folder, so this is also the answer that says whether the walk
;; descends into folders at all -- one that has moved, and one that is gone.
(define answers
  '(("https://b.example" . (301 . "https://d.example"))
    ("https://c.example" . (404 . #f))))

(define (check-of address)
  "The reading of ADDRESS, as the answers above make of it."
  (check-link address #:probe (probe-answering answers)))

(define (checks-of bookmarks)
  "The reading of every link BOOKMARKS holds, as the answers above make of it."
  (check-bookmarks bookmarks #:probe (probe-answering answers)))

;;; ====== The suite ======

(define checker-suite
  (suite "checking the links of a file"
         #:shuffle? #f
         (test "a link that answers is a link that is there"
               #:shuffle? #f
               (let ((check (check-link "https://a.example"
                                        #:probe (probe-answering
                                                 '(("https://a.example"
                                                    . (200 . #f)))))))
                 (assert-equal #:name "a 200 is ok"
                               #:expect 'ok
                               #:got (check-status check))
                 (assert-equal #:name "and what it answered is said"
                               #:expect "200"
                               #:got (check-detail check)))
               (assert-equal #:name "anything a server calls fine is ok"
                             #:expect 'ok
                             #:got (check-status
                                    (check-link "https://a.example"
                                                #:probe (probe-answering
                                                         '(("https://a.example"
                                                            . (204 . #f))))))))
         (test "a link that answers elsewhere has moved"
               #:shuffle? #f
               (let ((check (check-of "https://b.example")))
                 (assert-equal #:name "a redirect is not a failure"
                               #:expect 'moved
                               #:got (check-status check))
                 (assert-equal #:name "and where it leads now is said"
                               #:expect "301 -> https://d.example"
                               #:got (check-detail check))))
         (test "a refusal is the answer"
               #:shuffle? #f
               (let ((check (check-of "https://c.example")))
                 (assert-equal #:name "a 404 is a link that is gone"
                               #:expect 'broken
                               #:got (check-status check))
                 (assert-equal #:name "and the code is said"
                               #:expect "404"
                               #:got (check-detail check)))
               (assert-equal #:name "a server that fails is a link gone as well"
                             #:expect 'broken
                             #:got (check-status
                                    (check-link "https://e.example"
                                                #:probe (probe-answering
                                                         '(("https://e.example"
                                                            . (500 . #f)))))))
               (assert-true (checks-failed? (checks-of (list (url "c.example"))))
                            #:name "and a file holding one is a failure"))
         (test "a silence is no answer"
               #:shuffle? #f
               (let ((check (check-link "https://x.example"
                                        #:probe probe-that-says-nothing)))
                 (assert-equal #:name "a server that cannot be reached is an error"
                               #:expect 'error
                               #:got (check-status check))
                 (assert-equal #:name "and why it could not be reached is said"
                               #:expect "getaddrinfo-error: Name or service not known"
                               #:got (check-detail check)))
               (assert-true (checks-failed?
                             (check-bookmarks (list (url "x.example"))
                                              #:probe probe-that-says-nothing))
                            #:name "which is a failure, as a refusal is"))
         (test "the report says what it found"
               #:shuffle? #f
               (assert-equal #:name
                             "one line per link, in the order the file holds them, and a count"
                             #:expect
                             (string-append
                              "checked 3 links\n"
                              "ok       https://a.example (200)\n"
                              "moved    https://b.example (301 -> https://d.example)\n"
                              "broken   https://c.example (404)\n"
                              "1 ok, 1 moved, 1 broken, 0 error, 0 skipped\n")
                             #:got (check-report (checks-of bookmarks))))
         (test "a file of no links is checked, and finds nothing"
               #:shuffle? #f
               (assert-equal #:name "the report says it checked nothing"
                             #:expect
                             (string-append
                              "checked 0 links\n"
                              "0 ok, 0 moved, 0 broken, 0 error, 0 skipped\n")
                             #:got (check-report '())))
         (test "a file of live links is not a failure"
               #:shuffle? #f
               (assert-equal #:name "a moved link is not a failure either"
                             #:expect #f
                             #:got (checks-failed?
                                    (checks-of (list (url "a.example")
                                                     (url "b.example"))))))
         (test "a folder is walked, and an address is asked once"
               #:shuffle? #f
               (let ((asked '()))
                 (check-bookmarks
                  (list (url "dup.example")
                        (dir "Work"
                             (url "dup.example")
                             (dir "Ops" (url "nested.example"))))
                  #:probe (lambda (address)
                            (set! asked (cons address asked))
                            (cons 200 #f)))
                 (assert-equal #:name
                               "a link inside a folder is checked, and a repeated address once"
                               #:expect '("https://dup.example"
                                          "https://nested.example")
                               #:got (reverse asked))))
         (test "a link that is not a page is skipped"
               #:shuffle? #f
               (let ((check (check-of "mailto:post@example.org")))
                 (assert-equal #:name "an address no web server answers is skipped"
                               #:expect 'skipped
                               #:got (check-status check))
                 (assert-equal #:name "and the report says why"
                               #:expect "not a web address"
                               #:got (check-detail check)))
               (assert-equal #:name
                             "it is not a failure, so a file holding one is fine"
                             #:expect #f
                             #:got (checks-failed?
                                    (checks-of (list (url "mailto:post@example.org")))))
               (assert-equal #:name "and it is said in the report like any other link"
                             #:expect
                             (string-append
                              "checked 1 link\n"
                              "skipped  mailto:post@example.org (not a web address)\n"
                              "0 ok, 0 moved, 0 broken, 0 error, 1 skipped\n")
                             #:got (check-report
                                    (checks-of (list (url "mailto:post@example.org"))))))))

(define (spec)
  (veritas-run checker-suite))

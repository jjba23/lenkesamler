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

;;; A JSON bookmarks document, read back.
;;;
;;; The point of the JSON mode is that a program reads it, and the point of a
;;; file a program can read is that the program can read it back.  So the first
;;; reading is a file written by this project and read again: folders keep their
;;; nesting, links keep their names, their days and their tags, and the tags
;;; come back as the symbols a bookmarks file names them with rather than as the
;;; strings JSON holds them as.
;;;
;;; The addresses of that file come back as the file wrote them -- `https://' and
;;; all -- because the JSON says the address the bookmark leads to, and a
;;; bookmarks file may write either.  What is read here is that nothing else
;;; changed on the way.
;;;
;;; The second reading is of the door itself: `--import' is not told what kind
;;; of file it was given, so a JSON document is recognised by beginning with an
;;; object or a list, and a browser's file by being the rest.  Both are read
;;; through the same door, and each is read by the reader that knows it.  What
;;; is read last is a JSON document that holds neither -- an object naming
;;; something other than bookmarks -- which is named as a mistake instead of
;;; being read as an empty file.

(define-module (veritas unit import-json-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler importer)
  #:use-module (lenkesamler renderer json)
  #:use-module (ice-9 textual-ports)
  #:export (spec))

;;; ====== A bookmarks file, written as JSON ======

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

(define (as-json bookmarks)
  "BOOKMARKS as the JSON document this project writes."
  (json-bookmark-renderer bookmarks))

(define (read-back text)
  "TEXT, a bookmarks file from somewhere else, as the bookmarks it holds."
  (bookmarks-of-import-text text))

;; The file a browser wrote, for the reading of which reader a file gets.  It is
;; read from the directory the suite is run in, the root of this project.
(define browser-file
  "test/fixtures/browser-bookmarks.html")

(define (contents-of path)
  "What the file at PATH holds."
  (call-with-input-file path (lambda (port) (get-string-all port))))

;;; ====== The suite ======

(define import-json-suite
  (suite "reading a JSON bookmarks document"
         #:shuffle? #f
         (test "the document this project writes is the document it reads"
               #:shuffle? #f
               (assert-equal #:name
                "every folder, link, name, day and tag comes back"
                #:expect
                (list (dir "Work"
                           (url "https://codeberg.org/jjba23"
                                #:name "Codeberg"
                                #:added "2025-01-22"
                                #:tags '(dev))
                           (dir "Ops"
                                (url "https://grafana.test-backend.nl"
                                     #:name "Grafana")))
                      (url "https://mastodon.social"
                           #:name "Mastodon"))
                #:got (read-back (as-json bookmarks))))
         (test "a bare list of bookmarks is a document too"
               #:shuffle? #f
               (assert-equal #:name
                "a list, with no object around it, is read as the bookmarks it holds"
                #:expect (list (url "a.example" #:name "A"))
                #:got (read-back "[{\"link\": \"a.example\", \"name\": \"A\"}]")))
         (test "a link with no day is a link with no day"
               #:shuffle? #f
               (assert-equal #:name
                "the `false' a document writes says nothing, and that is what is read"
                #:expect (list (url "x.example" #:name "X"))
                #:got (read-back "{\"bookmarks\": [{\"link\": \"x.example\",
                                                   \"name\": \"X\",
                                                   \"added\": false}]}")))
         (test "a tag written as a string is a tag as a bookmarks file writes it"
               #:shuffle? #f
               (assert-equal #:name "the tags come back as symbols"
                             #:expect '(dev calc)
                             #:got (url-tags
                                    (car (read-back
                                          "{\"bookmarks\": [{\"link\": \"x.example\",
                                                             \"name\": \"X\",
                                                             \"tags\": [\"dev\", \"calc\"]}]}")))))
         (test "a document of no bookmarks is a file of no bookmarks"
               #:shuffle? #f
               (assert-equal #:name "an empty list of entries is read as none"
                             #:expect '()
                             #:got (read-back "{\"bookmarks\": []}")))
         (test "the reader is chosen by what the file holds"
               #:shuffle? #f
               (assert-equal #:name
                "a JSON document is read as JSON, whatever white space comes first"
                #:expect (list (url "a.example" #:name "A"))
                #:got (read-back "\n  {\"bookmarks\": [{\"link\": \"a.example\",
                                                        \"name\": \"A\"}]}"))
               (let ((from-browser (read-back (contents-of browser-file))))
                 (assert-equal #:name
                  "and a browser's file is read as the file a browser wrote"
                  #:expect "Work"
                  #:got (dir-name (car from-browser)))
                 (assert-equal #:name "with the folders a browser kept"
                               #:expect "Ops & friends"
                               #:got (dir-name (cadr (dir-items (car from-browser)))))))
         (test "a JSON document that holds no bookmarks is named as a mistake"
               #:shuffle? #f
               (assert-error (lambda () (read-back "{\"foo\": 1}"))
                             #:name
                             "an object naming something other than bookmarks"))))

(define (spec)
  (veritas-run import-json-suite))

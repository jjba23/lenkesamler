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

;;; A run of lenkesamler: the file it reads, the document it makes and where
;;; that document goes.
;;;
;;; The readings here are of the program as a person runs it.  A bookmarks file
;;; is named the way a person names one -- `test/fixtures/bookmarks.scm', which
;;; is a path relative to where they stand -- and the file is loaded from there:
;;; a path resolved against the load path, which is where Guile looks for a
;;; module, is not where a user's bookmarks are.
;;;
;;; `--destination' is a file the run writes the document to, so a run that
;;; names one is read both for the file it wrote and for the standard output it
;;; did not use.  The document it wrote is read against the document the same
;;; run prints without a destination, which is how the two ways of getting the
;;; same bytes are held to each other.  A run that names no destination writes
;;; the document to the standard output, and nothing else: what the run says
;;; about itself goes to the error port, so `lenkesamler ... > out' is a run of
;;; lenkesamler and not a run with a report in the middle of the file.
;;;
;;; The rest is the reading of what a mode is: the spellings the README gives of
;;; a mode are the same document, and a mode nobody knows -- CSV is a TODO of
;;; the README, not a mode -- is a mistake to be named rather than a document to
;;; be guessed at.  A file that is not there, and a file with no bookmarks in
;;; it, are named the same way.
;;;
;;; The suite runs its readings one after another, because they share the file
;;; they load: a bookmarks file becomes the module `(lenkesamler bookmarks)',
;;; and two readings of it at once would be two readings of one module.

(define-module (veritas unit main-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler main)
  #:use-module (ice-9 textual-ports)
  #:export (spec))

;;; ====== A bookmarks file, and where a run writes ======

;; The file the specs run against.  It is read from the directory the suite is
;; run in, which is the root of this project (see the `test' task of maak.scm).
(define bookmarks-file
  "test/fixtures/bookmarks.scm")

;; Where a run that names a destination writes.  The path names a directory that
;; need not be there, so the run is also read for the directory it made.
(define destination
  "reports/spec/links.html")

(define (run . arguments)
  "A run of lenkesamler over the ARGUMENTS, as its document is written.

The document is what the run wrote to the standard output, which is the whole of
what printing a document means."
  (with-output-to-string (lambda ()
                           (main #:args (cons "lenkesamler" arguments)))))

(define (contents-of path)
  "What the file at PATH holds."
  (call-with-input-file path (lambda (port) (get-string-all port))))

(define (ignoring-errors thunk)
  "THUNK, whatever it does: a file that is not there is already what was wanted."
  (catch #t thunk (lambda (key . args) #f)))

;;; ====== The suite ======

(define main-suite
  (suite "a run of lenkesamler"
         #:shuffle? #f
         #:concurrent? #f
         (test "a bookmarks file is read from where the run stands"
               #:shuffle? #f
               (let ((document (run "--file" bookmarks-file "--mode" "cli")))
                 (assert-contains #:name "the bookmarks of the file are the document"
                  #:expect document
                  #:got "Codeberg")
                 (assert-contains #:name "and so are the folders of the file"
                  #:expect document
                  #:got "[Work]")))
         (test "the report of a run is not the document"
               #:shuffle? #f
               (assert-not-contains #:name
                "what the run says about itself is not written to the document"
                #:expect (run "--file" bookmarks-file "--mode" "cli")
                #:got "Lenkesamler: Your bookmark manager"))
         (test "a destination is the file the document is written to"
               #:shuffle? #f
               ;; A run that finds its directory already there proves nothing
               ;; about making one, so the file and its directory are removed
               ;; first.
               (ignoring-errors (lambda () (delete-file destination)))
               (ignoring-errors (lambda () (rmdir (dirname destination))))
               (let ((printed (run "--file" bookmarks-file
                                   "--mode" "netscape"
                                   "--destination" destination))
                     (document (run "--file" bookmarks-file
                                    "--mode" "netscape")))
                 (assert-equal #:name "nothing is written to the standard output"
                               #:expect ""
                               #:got printed)
                 (assert-true (file-exists? destination)
                              #:name
                              "the document is written to the file, in the directory it names")
                 (assert-equal #:name
                  "and the file holds the document the run prints without one"
                  #:expect document
                  #:got (contents-of destination))
                 (assert-contains #:name
                  "a name that is markup is escaped in the file a browser imports"
                  #:expect document
                  #:got "R&amp;D &lt;notes&gt;")
                 (ignoring-errors (lambda () (delete-file destination)))))
         (test "a mode is the document it names"
               #:shuffle? #f
               (let ((bookmarks (begin
                                  (run "--file" bookmarks-file "--mode" "cli")
                                  (get-setting 'lenkesamler-bookmarks))))
                 (assert-equal #:name "markdown is md and commonmark"
                               #:expect (render-bookmarks bookmarks 'markdown)
                               #:got (render-bookmarks bookmarks 'commonmark))
                 (assert-equal #:name "and netscape is browser and web"
                               #:expect (render-bookmarks bookmarks 'netscape)
                               #:got (render-bookmarks bookmarks 'web))
                 (assert-contains #:name
                  "and a folder built by map is read, whatever the mode"
                  #:expect (render-bookmarks bookmarks 'cli)
                  #:got "Grafana | https://grafana.prod-backend.nl")))
         (test "a mode nobody knows is named as a mistake"
               #:shuffle? #f
               (assert-error (lambda ()
                               (render-bookmarks (list (url "a.example")) 'csv))
                             #:name "there is no CSV mode yet"))
         (test "a bookmarks file that is not there is named as a mistake"
               #:shuffle? #f
               (assert-error (lambda ()
                               (run "--file" "test/fixtures/no-such-file.scm"
                                    "--mode" "cli"))
                             #:name "a path a run cannot read is said so"))
         (test "a file with no lenkesamler-bookmarks in it is named as a mistake"
               #:shuffle? #f
               (begin
                 ;; A run loads the file, which is what makes the module the
                 ;; setting is read from exist.
                 (run "--file" bookmarks-file "--mode" "cli")
                 (assert-error (lambda ()
                                 (get-setting 'lenkesamler-bookmarks-typo))
                               #:name "asking for a setting the file does not define says which one")))))

(define (spec)
  (veritas-run main-suite))

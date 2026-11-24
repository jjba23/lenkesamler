;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
;;; a mode are the same document, and a mode nobody knows -- SQLite is a TODO of
;;; the README, not a mode -- is a mistake to be named rather than a document to
;;; be guessed at.  A file that is not there, and a file with no bookmarks in
;;; it, are named the same way.
;;;
;;; `--import' takes a file from somewhere else and writes a bookmarks file back,
;;; without being told which kind of file it was given: a browser's file and this
;;; project's JSON are both read, and one of each is read here.  What the run
;;; wrote is read again by another run, because a file that only looked like a
;;; bookmarks file would pass every reading of the text.
;;;
;;; `--check' writes a report where a document would be.  The file it is run over
;;; holds no pages, so the report is of links that are skipped rather than of the
;;; internet: what is read here is that a check is a run like any other -- a
;;; report in the place of a document, and no mode to choose.  A check that finds
;;; a broken link exits non-zero, which a spec process cannot observe without
;;; exiting itself, so that reading is in `(veritas unit checker-spec)', where a
;;; check is given its answers instead of asking.
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

;; The bookmarks file a browser wrote, and the bookmarks file a run makes of it.
(define browser-file
  "test/fixtures/browser-bookmarks.html")

(define imported-file
  "reports/spec/imported-bookmarks.scm")

;; The JSON a program reads, and the bookmarks file a run makes of it.
(define json-file
  "test/fixtures/bookmarks.json")

(define imported-json-file
  "reports/spec/imported-json-bookmarks.scm")

;; A bookmarks file whose links are not pages, so that a check of it asks
;; nothing of the internet.
(define offline-file
  "test/fixtures/offline-bookmarks.scm")

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
                 (assert-equal #:name "and scheme is scm"
                               #:expect (render-bookmarks bookmarks 'scheme)
                               #:got (render-bookmarks bookmarks 'scm))
                 (assert-contains #:name
                  "and a folder built by map is read, whatever the mode"
                  #:expect (render-bookmarks bookmarks 'cli)
                  #:got "Grafana | https://grafana.prod-backend.nl")
                 (assert-contains #:name "and xbel is an XML document"
                  #:expect (render-bookmarks bookmarks 'xbel)
                  #:got "<xbel version=\"1.0\">")))
         (test "a mode nobody knows is named as a mistake"
               #:shuffle? #f
               (assert-error (lambda ()
                               (render-bookmarks (list (url "a.example")) 'sqlite))
                             #:name "there is no SQLite mode yet"))
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
                               #:name "asking for a setting the file does not define says which one")))
         (test "a browser's bookmarks file is imported as a bookmarks file"
               #:shuffle? #f
               (ignoring-errors (lambda () (delete-file imported-file)))
               (let ((printed (run "--import" browser-file
                                   "--destination" imported-file)))
                 (assert-equal #:name
                  "a run that imports writes a file and prints nothing"
                  #:expect ""
                  #:got printed)
                 (assert-true (file-exists? imported-file)
                              #:name "the file it wrote is there")
                 (assert-contains #:name
                  "and what it wrote is a bookmarks file of this project"
                  #:expect (contents-of imported-file)
                  #:got "(define lenkesamler-bookmarks")
                 ;; The file a run wrote is a bookmarks file, so the reading of
                 ;; it is another run of the program: a file that only looked
                 ;; like a bookmarks file would fail here.
                 (let ((read-again (run "--file" imported-file "--mode" "cli")))
                   (assert-contains #:name "the folder a browser wrote is a folder here"
                    #:expect read-again
                    #:got "[Work]")
                   (assert-contains #:name "and the link inside it is the link it was"
                    #:expect read-again
                    #:got "https://codeberg.org/jjba23")
                   (assert-contains #:name "and the folder inside the folder keeps its name"
                    #:expect read-again
                    #:got "[Ops & friends]"))
                 (ignoring-errors (lambda () (delete-file imported-file)))))
         (test "a JSON bookmarks file is imported as a bookmarks file"
               #:shuffle? #f
               (ignoring-errors (lambda () (delete-file imported-json-file)))
               (let ((printed (run "--import" json-file
                                   "--destination" imported-json-file)))
                 (assert-equal #:name "a run that imports writes a file"
                               #:expect ""
                               #:got printed)
                 (let ((read-again (run "--file" imported-json-file
                                        "--mode" "cli")))
                   (assert-contains #:name "the folder a JSON document held is a folder here"
                    #:expect read-again
                    #:got "[Work]")
                   (assert-contains #:name "with the folder inside it"
                    #:expect read-again
                    #:got "[Ops]")
                   (assert-contains #:name "and the link leads where it did"
                    #:expect read-again
                    #:got "https://codeberg.org/jjba23"))
                 ;; The tags of a JSON document are strings, and a bookmarks file
                 ;; names them as symbols: what a run wrote is read here as the
                 ;; source it is, because a tag read as a string would read as
                 ;; one until somebody's file would not load.
                 (assert-contains #:name "and the tags came with it, as a file writes them"
                  #:expect (contents-of imported-json-file)
                  #:got "#:tags '(dev)")
                 (ignoring-errors (lambda () (delete-file imported-json-file)))))
         (test "a check is a report, not a document"
               #:shuffle? #f
               (let ((printed (begin
                                (run "--file" bookmarks-file "--mode" "cli")
                                (run "--file" offline-file "--check"))))
                 (assert-contains #:name "a run that checks prints its report"
                  #:expect printed
                  #:got "checked 2 links")
                 (assert-contains #:name
                  "a link that is not a page is said to be skipped, and not to be gone"
                  #:expect printed
                  #:got "skipped  mailto:post@example.org (not a web address)")
                 (assert-contains #:name "an address written twice is reported once"
                  #:expect printed
                  #:got "0 ok, 0 moved, 0 broken, 0 error, 2 skipped"))
               (assert-error (lambda ()
                               (run "--file" offline-file
                                    "--check"
                                    "--mode" "cli"))
                             #:name "a run that checks takes no mode, because it writes no document"))
         (test "a run reads one file, and is told which"
               #:shuffle? #f
               (assert-error (lambda ()
                               (run "--file" bookmarks-file
                                    "--import" browser-file
                                    "--mode" "cli"))
                             #:name "a run given both a bookmarks file and a browser's file")
               (assert-error (lambda () (run "--mode" "cli"))
                             #:name "a run given no file at all"))))

(define (spec)
  (veritas-run main-suite))

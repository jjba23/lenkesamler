;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; A bookmarks file written back as a bookmarks file.
;;;
;;; Every other mode of this program is a way out of the DSL; this one is the
;;; way back in, and what is read here is that it really is a way in: the source
;;; is written to a file, the file is loaded, and the bookmarks that come out of
;;; it are the bookmarks that went in.  A renderer whose output only looked like
;;; a bookmarks file would pass every reading of the text and fail this one.
;;;
;;; The readings of the text are of the two decisions the format takes.  A value
;;; is written with `write', so a name holding a quote, a backslash or a
;;; character outside ASCII reads back as the name it was -- a file written to
;;; be read again cannot be written as prose.  And a `#:name' equal to the link
;;; is left out, because `(url "x")' already names a link `x': a file read and
;;; written again says what it said, and not what the renderer found it
;;; convenient to say.
;;;
;;; The last reading is of a file with no bookmarks in it.  That is written as
;;; an empty list rather than as an empty document, so reading it gives no
;;; bookmarks instead of an error.

(define-module (veritas unit scheme-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler renderer scheme)
  #:use-module (ice-9 textual-ports)
  #:export (spec))

;;; ====== A bookmarks file, written back ======

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
             #:name "Mastodon")
        ;; A link named by its own address: `(url "x")' is a link named `x', so
        ;; writing the name as well would say the same thing twice.
        (url "example.org")))

;; Where a file of the suite is written: below the project, in the directory the
;; runner already keeps its reports in, which is not part of the project's own
;; sources.
(define written-file
  "reports/spec/written-bookmarks.scm")

(define (written bookmarks)
  "BOOKMARKS as the source of a bookmarks file."
  (scheme-bookmark-renderer bookmarks))

(define (reading-of path)
  "The bookmarks the bookmarks file at PATH defines, loaded."
  (load (canonicalize-path path))
  (get-setting 'lenkesamler-bookmarks))

(define (ignoring-errors thunk)
  "THUNK, whatever it does: a file that is not there is already what was wanted."
  (catch #t thunk (lambda (key . args) #f)))

;;; ====== The suite ======

(define scheme-suite
  (suite "the file written back"
         #:shuffle? #f
         ;; The file is loaded, which makes it the module the bookmarks are read
         ;; from: one reading of it at a time, so that each reading reads the
         ;; file it wrote.
         #:concurrent? #f
         (test "what is written is a bookmarks file"
               #:shuffle? #f
               (let ((source (written (list (url "mastodon.social"
                                                 #:name "Mastodon")))))
                 (assert-contains #:name "the module a bookmarks file defines"
                  #:expect source
                  #:got "(define-module (lenkesamler bookmarks)")
                 (assert-contains #:name "and the list it is read from"
                  #:expect source
                  #:got "(define lenkesamler-bookmarks")
                 (assert-contains #:name "and the link it holds"
                  #:expect source
                  #:got "(url \"mastodon.social\" #:name \"Mastodon\")")))
         (test "a name equal to the link is not written twice"
               #:shuffle? #f
               (assert-contains #:name "a link named by its address stays one form"
                #:expect (written (list (url "example.org")))
                #:got "(url \"example.org\")")
               (assert-not-contains #:name "with no name written beside it"
                #:expect (written (list (url "example.org")))
                #:got "#:name"))
         (test "a value is written as the value it is"
               #:shuffle? #f
               (assert-contains #:name "a name holding a quote is a string, quoted"
                #:expect (written (list (url "example.org"
                                            #:name "a \"quoted\" read")))
                #:got "\"a \\\"quoted\\\" read\"")
               (assert-contains #:name "and a character outside ASCII is itself"
                #:expect (written (list (url "example.org" #:name "🌐 REST")))
                #:got "🌐 REST"))
         (test "the file that is written is the file that is read"
               #:shuffle? #f
               (ignoring-errors (lambda () (delete-file written-file)))
               (call-with-output-file written-file
                 (lambda (port) (display (written bookmarks) port)))
               (assert-equal #:name
                "loading the written file gives back the bookmarks it was written from"
                #:expect bookmarks
                #:got (reading-of written-file))
               (assert-equal #:name
                "and writing what was read gives the same source again"
                #:expect (written bookmarks)
                #:got (written (reading-of written-file)))
               (ignoring-errors (lambda () (delete-file written-file))))
         (test "a file with no bookmarks in it is still a file"
               #:shuffle? #f
               (ignoring-errors (lambda () (delete-file written-file)))
               (call-with-output-file written-file
                 (lambda (port) (display (written '()) port)))
               (assert-equal #:name "reading it gives no bookmarks"
                             #:expect '()
                             #:got (reading-of written-file))
               (ignoring-errors (lambda () (delete-file written-file))))))

(define (spec)
  (veritas-run scheme-suite))

;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; What one run of lenkesamler does.
;;
;; A run reads exactly one file: this project's own bookmarks DSL, or a file a
;; browser exported, which is a migration rather than a rendering and yields the
;; DSL's own mode.  The bookmarks that come out are either checked -- every link
;; asked for, and a dead one makes the run exit 1 so a pipeline hears about it --
;; or rendered through the renderer the mode names.  Either way the result is one
;; document, written to the file a run named or to the standard output, and the
;; report of the run goes to the error port so that a redirected output holds
;; the document and nothing else.
;;
;; ```mermaid
;; flowchart LR
;;   file["bookmarks file<br/>(the Scheme DSL)"] --> load["bookmarks-of-file"]
;;   browser["a browser's export"] --> import["bookmarks-of-import"]
;;   load --> bookmarks["bookmarks"]
;;   import --> bookmarks
;;   bookmarks --> check{"--check?"}
;;   check -- yes --> report["check-bookmarks<br/>and check-report"]
;;   check -- no --> render["render-bookmarks<br/>one renderer per mode"]
;;   report --> emit["emit"]
;;   render --> emit
;;   emit --> out["--destination file<br/>or standard output"]
;; ```
;;
;;; Code:

(define-module (lenkesamler main)
  #:declarative? #f
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 match)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-13)
  #:use-module (lenkesamler renderer cli)
  #:use-module (lenkesamler renderer csv)
  #:use-module (lenkesamler renderer org)
  #:use-module (lenkesamler renderer netscape)
  #:use-module (lenkesamler renderer json)
  #:use-module (lenkesamler renderer markdown)
  #:use-module (lenkesamler renderer scheme)
  #:use-module (lenkesamler renderer xbel)
  #:use-module (lenkesamler importer)
  #:use-module (lenkesamler checker)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler html)
  #:export (main bookmark-modes render-bookmarks write-document))

;; Every spelling a mode may be asked for by.
(define bookmark-modes
  '(cli csv json org markdown md commonmark netscape browser web scheme scm
        xbel))

;; ====== Rendering ======

(define* (render-bookmarks bookmarks mode)
  "The document MODE asks for, rendered from BOOKMARKS.

The document is the whole output of a run, so it is also the whole of what a
destination file holds: nothing is written to a port here."
  (match mode
    ('cli (cli-bookmark-renderer bookmarks))
    ('csv (csv-bookmark-renderer bookmarks))
    ('json (json-bookmark-renderer bookmarks))
    ('org (org-bookmark-renderer bookmarks))
    ((or 'markdown 'md 'commonmark) (markdown-bookmark-renderer bookmarks))
    ((or 'netscape 'browser 'web)
     (with-output-to-string (lambda ()
                              (sxml->xml (netscape-bookmark-renderer
                                          bookmarks)))))
    ((or 'scheme 'scm) (scheme-bookmark-renderer bookmarks))
    ('xbel (xbel-bookmark-renderer bookmarks))
    (_ (error "lenkesamler: unknown output mode" mode
              "-- expected one of:" bookmark-modes))))

;; ====== Writing what a run made ======

(define (ensure-directory path)
  "Create PATH, and every directory above it, unless it is already there."
  (unless (or (string-null? path)
              (string=? path ".")
              (string=? path "/")
              (file-exists? path))
    (ensure-directory (dirname path))
    ;; Two runs may race here; a directory that appeared in the meantime is
    ;; the outcome that was wanted.
    (catch 'system-error (lambda () (mkdir path))
           (lambda (key . args)
             (unless (file-exists? path) (apply throw key args))))))

(define (write-document document destination)
  "Write DOCUMENT to the file DESTINATION, making its directory if needed."
  (ensure-directory (dirname destination))
  (call-with-output-file destination (lambda (port) (display document port))))

(define (emit text destination)
  "TEXT, to the file DESTINATION when a run named one, and to the output otherwise.

A run that names no destination writes what it made and nothing else: the
document of a mode, or the report of a check, and not a word about the run
around it."
  (if destination
      (begin
        (write-document text destination)
        (format (current-error-port) "lenkesamler: wrote ~a~%" destination))
      (begin
        (display text)
        ;; A text that already ends its last line is not given a second one.
        (unless (string-suffix? "\n" text)
          (newline)))))

;; ====== Reading the bookmarks ======

(define* (existing-file file #:key (what "bookmarks file"))
  "FILE as the absolute path of a file, or a clear error naming WHAT it is not.

The path is resolved against the directory the program was started in.  Guile's
`load' would otherwise resolve it against `%load-path', where a bookmarks file
-- a file of the user's, not a module of this project -- is not to be found."
  (let ((path (catch #t (lambda () (canonicalize-path file))
                 (lambda (key . args) #f))))
    (if (and path (file-exists? path))
        path
        (error (format #f "lenkesamler: no ~a at" what) file))))

(define (bookmarks-of-file file)
  "The bookmarks FILE defines, FILE being a bookmarks file of this project."
  (load (existing-file file))
  (get-setting 'lenkesamler-bookmarks))

(define (bookmarks-of-import file)
  "The bookmarks FILE holds: a browser's bookmarks file, or this project's JSON."
  (call-with-input-file (existing-file file #:what "file to import")
    (lambda (port)
      (bookmarks-of-import-text (get-string-all port)))))

;; ====== Entry point ======

(define* (main #:key (args (command-line)))

  (let* ((option-spec '((mode (single-char #\m)
                              (value #t))
                        (destination (single-char #\o)
                                     (value #t))
                        (file (single-char #\p)
                              (value #t))
                        (import (single-char #\i)
                                (value #t))
                        (check (single-char #\c))))
         (options (getopt-long args option-spec))
         (import-file (option-ref options
                                  'import #f))
         (check? (option-ref options
                             'check #f))
         (asked-mode (option-ref options
                                 'mode #f))
         (mode (string->symbol (or asked-mode
                                   ;; Reading a browser's file is a migration:
                                   ;; what is wanted back is the file a person
                                   ;; edits, which is this project's own source.
                                   (if import-file "scheme" "netscape"))))
         (file (option-ref options
                           'file #f))
         (destination (option-ref options
                                  'destination #f)))
    (when (and file import-file)
      (error "lenkesamler: a run reads one file" file import-file
             "-- name --file or --import, not both"))
    (unless (or file import-file)
      (error "lenkesamler: no bookmarks to read"
             "-- name a bookmarks file with --file, or a browser's bookmarks file with --import"))
    (when (and check? asked-mode)
      (error "lenkesamler: --check reports on the links of a file" asked-mode
             "-- it writes no document, so it takes no --mode"))
    ;; The report of the run goes to the error port: the standard output is what
    ;; the run made, and a run whose output is redirected into a `.json' or a
    ;; bookmarks file must hold that and nothing else.
    (format (current-error-port)
            "
---------------------------------------------------------
Lenkesamler: Your bookmark manager and sync tool powered by Lisp
    reading: ~a
    ~a
---------------------------------------------------------
"
            (or import-file file)
            (if check?
                "checking every link"
                (format #f "output mode: ~a" mode)))
    ;; --- Load the bookmarks ---
    (let ((bookmarks (if import-file
                         (bookmarks-of-import import-file)
                         (bookmarks-of-file file))))
      ;; --- Write the document, or read the links ---
      (if check?
          (let ((checks (check-bookmarks bookmarks)))
            (emit (check-report checks) destination)
            ;; A file of links that no longer lead anywhere is a failure a
            ;; pipeline is meant to hear about.
            (when (checks-failed? checks)
              (exit 1)))
          (emit (render-bookmarks bookmarks mode) destination)))))

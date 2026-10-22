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

(define-module (lenkesamler main)
  #:declarative? #f
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-13)
  #:use-module (lenkesamler renderer cli)
  #:use-module (lenkesamler renderer org)
  #:use-module (lenkesamler renderer netscape)
  #:use-module (lenkesamler renderer json)
  #:use-module (lenkesamler renderer markdown)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler html)
  #:export (main bookmark-modes render-bookmarks write-document))

;; Every spelling a mode may be asked for by.
(define bookmark-modes
  '(cli json org markdown md commonmark netscape browser web))

;; ====== Rendering ======

(define* (render-bookmarks bookmarks mode)
  "The document MODE asks for, rendered from BOOKMARKS.

The document is the whole output of a run, so it is also the whole of what a
destination file holds: nothing is written to a port here."
  (match mode
    ('cli (cli-bookmark-renderer bookmarks))
    ('json (json-bookmark-renderer bookmarks))
    ('org (org-bookmark-renderer bookmarks))
    ((or 'markdown 'md 'commonmark) (markdown-bookmark-renderer bookmarks))
    ((or 'netscape 'browser 'web)
     (with-output-to-string (lambda ()
                              (sxml->xml (netscape-bookmark-renderer
                                          bookmarks)))))
    (_ (error "lenkesamler: unknown output mode" mode
              "-- expected one of:" bookmark-modes))))

;; ====== Writing the document ======

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

;; ====== Reading the bookmarks file ======

(define (bookmarks-file file)
  "FILE as the absolute path of a bookmarks file, or a clear error.

The path is resolved against the directory the program was started in.  Guile's
`load' would otherwise resolve it against `%load-path', where a bookmarks file
-- a file of the user's, not a module of this project -- is not to be found."
  (let ((path (catch #t (lambda () (canonicalize-path file))
                 (lambda (key . args) #f))))
    (if (and path (file-exists? path))
        path
        (error "lenkesamler: no bookmarks file at" file))))

;; ====== Entry point ======

(define* (main #:key (args (command-line)))

  (let* ((option-spec '((mode (single-char #\m)
                              (value #t))
                        (destination (single-char #\o)
                                     (value #t))
                        (resources (single-char #\r)
                                   (value #t))
                        (file (single-char #\p)
                              (value #t)
                              (required? #t))))
         (options (getopt-long args option-spec))
         (mode (string->symbol (option-ref options
                                           'mode "netscape")))
         (file (option-ref options
                           'file #f))
         (destination (option-ref options
                                  'destination #f)))
    ;; The report of the run goes to the error port: the standard output is the
    ;; document, and a run whose output is redirected into a `.json' or a
    ;; bookmarks file must hold that document and nothing else.  `--resources'
    ;; is accepted for the wrapper script's sake; nothing is read from it yet.
    (format (current-error-port)
            "
---------------------------------------------------------
Lenkesamler: Your bookmark manager and sync tool powered by Lisp
    loading file: ~a
    output mode: ~a
---------------------------------------------------------
"
            file mode)
    ;; --- Load user bookmarks file ---
    (load (bookmarks-file file))
    ;; --- Render bookmarks ---
    (let ((document (render-bookmarks (get-setting 'lenkesamler-bookmarks)
                                      mode)))
      (if destination
          (begin
            (write-document document destination)
            (format (current-error-port) "lenkesamler: wrote ~a~%" destination))
          (begin
            (display document)
            ;; A document that already ends its last line is not given a second
            ;; one: an empty line at the end of a Netscape file is harmless but
            ;; one at the end of a Markdown file is not nothing either.
            (unless (string-suffix? "\n" document)
              (newline)))))))

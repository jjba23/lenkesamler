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
  #:use-module (lenkesamler renderer cli)
  #:use-module (lenkesamler renderer netscape)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler netscape)
  #:export (main))

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
                                           'mode
                                           "netscape")))
         (file (option-ref options
                           'file #f))
         (destination (option-ref options
                                  'destination "./bookmarks-export.html"))
         (resources (option-ref options
                                'resources #f)))
    (display (format #f
              "
---------------------------------------------------------
Lenkesamler: Your bookmark manager and sync tool powered by Lisp
    loading file: ~a
    output mode: ~a
---------------------------------------------------------
"
              file mode))
    ;; --- Load user bookmarks file ---
    (load file)
    ;; --- Render bookmarks ---
    (let* ((user-bookmarks (get-setting 'lenkesamler-bookmarks)))
      (cond
        ((eq? mode
              'cli)
         (cli-bookmark-logger user-bookmarks))
        ((eq? mode
              'netscape)
         (display (with-output-to-string (lambda ()
                                           (sxml->xml (netscape-bookmark-logger
                                                       user-bookmarks))))))
        (else (throw "unknown mode specified" mode))))))

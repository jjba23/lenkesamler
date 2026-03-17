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
  #:declarative? #t
  #:use-module (ice-9 getopt-long)
  #:use-module (lenkesamler prelude)
  #:export (main))

(define* (main #:key (args (command-line)))
  
  (let* ((_ (begin
              (newline)
              (write args)
              (newline)))
         (option-spec '((locale (single-char #\l)
                                (value #t))
                        (destination (single-char #\o)
                                     (value #t))
                        (resources (single-char #\r)
                                   (value #t))
                        (file (single-char #\p)
                              (value #t)
                              (required? #t))))

         (options (getopt-long args option-spec))
         (file (option-ref options
                           'file #f))
         (destination (option-ref options
                                  'destination "./dist"))
         (resources (option-ref options
                                'resources #f))
         ;; (locale (option-ref options
         ;; 'locale "en"))
         )
    (display "
---------------------------------------------------------
")
    (display "Lenkesamler")
    (display (format #f "\n  loading file: ~a" file))
    (display "
---------------------------------------------------------
")
    (load file)
    (simple-bookmark-logger (get-setting 'lenkesamler-bookmarks))
    (newline)
    (newline)

    ))

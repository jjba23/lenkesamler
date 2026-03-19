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

(define-module (lenkesamler renderer org)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (lenkesamler prelude)
  #:export (org-bookmark-renderer))

(define* (org-bookmark-renderer xs
                     #:key (indent 1))
  (for-each (lambda (x)
              (cond
                ((dir-record? x)
                 (format #t "\n\n~a ~a"
                         (make-string indent #\*)
                         (dir-name x))
                 (cli-bookmark-renderer (dir-urls x)
                                         #:indent (+ 1 indent))
                 (newline))
                ((url-record? x)
                 (format #t "\n- [[~a][~a]]"
                         (url-name x)
                         (if (string-prefix? "http"
                                             (url-link x))
                             (url-link x)
                             (format #f "https://~a"
                                     (url-link x)))))
                (else (throw "unknown data type for bookmark" x)))) xs)
  (newline))

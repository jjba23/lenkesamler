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

(define-module (lenkesamler prelude)
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
  #:export (get-setting ~
                        simple-bookmark-logger
                        url-record
                        dir-record
                        make-dir
                        dir
                        url
                        dir-record?
                        dir-name
                        dir-urls
                        make-url
                        url-record?
                        url-name
                        url-link))

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define-record-type dir-record
  (make-dir name urls) dir-record?
  (name dir-name)
  (urls dir-urls))

(define* (dir name . urls)
  (make-dir name urls))

(define-record-type url-record
  (make-url link name) url-record?
  (link url-link)
  (name url-name))

(define* (url link
              #:key (name #f))
  (make-url link
            (if (not name) link name)))

(define-syntax-rule (get-setting setting)
  "Get a setting for lenkesamler."
  (let* ((user-setting (module-variable (resolve-module '(lenkesamler
                                                          bookmarks)) setting)))
    (variable-ref user-setting)))

(define* (simple-bookmark-logger xs
                                 #:key (indent 0))
  (for-each (lambda (x)
              (cond
                ((dir-record? x)
                 (format #t "\n\n~a[ ~a ]"
                         (make-string indent #\space)
                         (dir-name x))
                 (simple-bookmark-logger (dir-urls x)
                                         #:indent (+ 4 indent))
                 (newline))
                ((url-record? x)
                 (format #t "\n~aurl: ~a | ~a"
                         (make-string indent #\space)
                         (url-name x)
                         (if (string-prefix? "http"
                                             (url-link x))
                             (url-link x)
                             (format #f "https://~a"
                                     (url-link x)))))
                (else (throw "unknown data type for bookmark" x)))) xs))

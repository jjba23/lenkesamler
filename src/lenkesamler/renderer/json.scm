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

(define-module (lenkesamler renderer json)
  #:declarative? #t
  #:use-module (web server)
  #:use-module (web request)
  #:use-module (web response)
  #:use-module (web uri)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (sxml ssax input-parse)
  #:use-module (sxml ssax)
  #:use-module (sxml transform)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 time)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 iconv)
  #:use-module (lenkesamler prelude)
  #:use-module (ice-9 threads)
  #:use-module (json)
  #:export (json-bookmark-renderer))

(define (serialize-dir x)
  `((name unquote
          (dir-name x))
    (items unquote
           (list->vector (map parse-lenksamler-to-json
                              (dir-items x))))))

(define (serialize-url x)
  `((link unquote
          (url-link x))
    (name unquote
          (url-name x))
    (added unquote
           (url-added x))
    (tags unquote
          (url-tags x))))

(define (parse-lenksamler-to-json x)
  (cond
    ((dir-record? x)
     (serialize-dir x))
    ((url-record? x)
     (serialize-url x))
    (else (throw "unknown data type for bookmark" x))))

(define* (json-bookmark-renderer xs)
  (let* ((parsed (map parse-lenksamler-to-json xs))
         (_ (write parsed)))
    (scm->json-string parsed)))

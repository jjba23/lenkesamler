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
  #:export (get-setting
            ~
            url-record
            dir-record
            make-dir
            dir-record?
            dir-description
            dir-urls
            make-url
            url-record?
            url-description
            url-link))

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define-record-type dir-record
  (make-dir description urls) dir-record?
  (description dir-description)
  (urls dir-urls))

(define* (dir description urls)
  (make-dir description urls))

(define-record-type url-record
  (make-url link description) url-record?
  (link url-link)
  (description url-description))

(define* (url link
              #:key (description #f))
  (make-url link
            (if (not description) link description)))

(define-syntax-rule (get-setting setting)
  "Get a setting for lenkesamler."
  (let* ((user-setting (module-variable (resolve-module '(lenkesamler
                                                          bookmarks)) setting)))
    (variable-ref user-setting)))

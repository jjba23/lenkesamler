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
  #:use-module (srfi srfi-19)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:export (get-setting ~
                        ymd-date-to-epoch
                        url-record
                        dir-record
                        flatten
                        make-dir
                        dir
                        url
                        dir-record?
                        dir-name
                        dir-items
                        make-url
                        url-record?
                        url-name
                        url-added
                        url-tags
                        url-link
                        url-string-with-protocol))

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define-record-type dir-record
  (make-dir name urls) dir-record?
  (name dir-name)
  (urls dir-items))

(define* (dir name . urls)
  (make-dir name urls))

(define-record-type url-record
  (make-url link name added tags)
  url-record?
  (link url-link)
  (name url-name)
  (added url-added)
  (tags url-tags))

(define* (url link
              #:key (name #f)
              (added #f)
              (tags #f))
  (make-url link
            (if (not name) link name) added tags))

(define-syntax-rule (get-setting setting)
  "Get a setting for lenkesamler."
  (let* ((user-setting (module-variable (resolve-module '(lenkesamler
                                                          bookmarks)) setting)))
    (variable-ref user-setting)))

(define (ymd-date-to-epoch date)
  (let* ((parsed (string->date date "~Y-~m-~d"))
         (time (date->time-utc parsed)))
    (time-second time)))

(define (flatten x)
  (cond
    ((null? x)
     '())
    ((pair? x)
     (append (flatten (car x))
             (flatten (cdr x))))
    (else (list x))))

(define* (url-string-with-protocol x
                                   #:key (fallback-protocol "https://"))
  (cond
    ((string-prefix? "https:" x)
     x)
    ((string-prefix? "http:" x)
     x)
    (else (format #f "~a~a" fallback-protocol x))))

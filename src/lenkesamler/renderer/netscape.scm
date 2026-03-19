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

(define-module (lenkesamler renderer netscape)
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
  #:export (netscape-bookmark-renderer))

(define (dir-to-html x)
  `("\n<DT>" (H3 ,(dir-name x))
    (DL "<P>"
        ,@(map parse-lenksamler-to-html
               (dir-urls x)) "<P>")))

(define (url-to-html x)
  `("\n<DT>" (A (@ (href ,(if (string-prefix? "http"
                                              (url-link x))
                              (url-link x)
                              (format #f "https://~a"
                                      (url-link x)))))
                ,(url-name x))))

(define (parse-lenksamler-to-html x)
  (cond
    ((dir-record? x)
     (dir-to-html x))
    ((url-record? x)
     (url-to-html x))
    (else (throw "unknown data type for bookmark" x))))

(define* (netscape-bookmark-renderer xs)
  (let* ((parsed-nodes (map parse-lenksamler-to-html xs))
         (tree `("<!DOCTYPE NETSCAPE-Bookmark-file-1>" (META (@ (http-equiv
                                                                 Content-Type)
                                                                (content
                                                                 "text/html; charset=UTF-8")))
                 (TITLE "Bookmarks")
                 (H1 "Bookmarks")
                 "\n<DL><P>"
                 ,@parsed-nodes
                 "\n</DL><P>")))
    tree))

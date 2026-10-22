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

(define-module (lenkesamler renderer cli)
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
  #:export (cli-bookmark-renderer))

;; The tags of a link as a reader says them, `dev, calc' rather than the list
;; `(dev calc)' an S-expression would show.
(define (tags-line tags)
  (if (list? tags)
      (format #f " ~a " (string-join (map (lambda (tag)
                                            (format #f "~a" tag)) tags)
                                     ", "))
      ""))

(define* (cli-bookmark-renderer xs
                                #:key (indent 0))
  (string-join (map (lambda (x)
                      (cond
                        ((dir-record? x)
                         (format #f "\n~a[~a]\n~a"
                                 (make-string indent #\space)
                                 (dir-name x)
                                 (cli-bookmark-renderer (dir-items x)
                                                        #:indent (+ 4 indent))))
                        ((url-record? x)
                         (format #f
                                 "~a~a~a~a | ~a\n"
                                 (make-string indent #\space)
                                 (url-name x)
                                 (if (url-added x)
                                     (format #f " added: ~a "
                                             (url-added x)) "")
                                 (tags-line (url-tags x))
                                 (url-string-with-protocol (url-link x))))
                        (else (throw "unknown data type for bookmark" x))))
                    ;; A bookmarks file is a program: the README builds folders
                    ;; with `map', so a list can hold lists.  Flattened here, at
                    ;; the one place every item passes through.
                    (flatten xs))
               ""))

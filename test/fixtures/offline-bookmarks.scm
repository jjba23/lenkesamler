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

;;; A bookmarks file of links that are not pages, for the reading of a check.
;;;
;;; A check asks a server about each link, so a reading of one over a file of web
;;; pages reads the internet as well -- and a suite that reads the internet is a
;;; suite that fails on the day a page is gone.  These links are bookmarks with
;;; no server to ask, so the check is told about them and about nothing else.
;;;
;;; It lives outside `test/veritas' so the runner does not take it for a spec.

(define-module (lenkesamler bookmarks)
  #:declarative? #t
  #:use-module (lenkesamler prelude))

(define lenkesamler-bookmarks
  (list (url "mailto:post@example.org"
             #:name "Write to the list")
        (url "magnet:?xt=urn:btih:0123456789abcdef")
        ;; The same address twice: a check asks it once, and says so once.
        (dir "Writing"
             (url "mailto:post@example.org"
                  #:name "Write to the list"))))

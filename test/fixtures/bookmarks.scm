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

;;; A bookmarks file, as a user writes one, for the reading of a run.
;;;
;;; It is the file a spec hands to `lenkesamler` itself, so it holds what the
;;; README says a bookmarks file holds: folders inside folders, a link written
;;; without a scheme, the metadata a link may carry, a link that names its own
;;; scheme, a name with a character that is markup, and -- because a bookmarks
;;; file is a program -- a folder built by `map', which makes a list inside the
;;; list of bookmarks.
;;;
;;; It lives outside `test/veritas' so the runner does not take it for a spec:
;;; only the funnels named `unit' under `test/veritas' are read as one.

(define-module (lenkesamler bookmarks)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (lenkesamler prelude))

(define lenkesamler-bookmarks
  (list (dir "Work"
             (url "codeberg.org/jjba23"
                  #:name "Codeberg"
                  #:added "2025-01-22"
                  #:tags '(dev))
             (dir "Ops"
                  (url "grafana.test-backend.nl"
                       #:name "Grafana")))
        (url "mailto:post@example.org"
             #:name "Write to the list")
        (url "example.org/search?a=1&b=2"
             #:name "R&D <notes>")
        (map (lambda (environment)
               (dir (format #f "Ops ~a" environment)
                    (url (format #f "grafana.~a-backend.nl" environment)
                         #:name "Grafana")))
             '(prod test))))

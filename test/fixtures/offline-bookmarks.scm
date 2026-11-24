;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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

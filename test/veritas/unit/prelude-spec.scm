;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; The prelude: the records a bookmarks file is written in, and the two things
;;; every renderer asks of a link -- which address it is reached by, and which
;;; day it was added.
;;;
;;; A link is written the way a person writes one, `codeberg.org/jjba23', and
;;; the protocol is decided when the link is rendered.  The reading here is of
;;; that decision: a link that names its own scheme keeps it, whatever the
;;; scheme is -- a `mailto:' address and an `ftp:' archive are bookmarks as much
;;; as a web page -- while a host with a port on it is a host, not a document
;;; written in a scheme called `example.org'.
;;;
;;; The date is read with the clock of UTC, named by the spec rather than
;;; inherited: `ymd-date-to-epoch' reads a day in the timezone of the machine it
;;; runs on, and the epoch it answers is only the same number everywhere when
;;; that timezone is named.  A suite that inherited the clock would pass on one
;;; machine and fail on the next.

(define-module (veritas unit prelude-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:export (spec))

;;; ====== Reading with the clock of UTC ======

(define (in-utc thunk)
  "THUNK read with the clock of UTC, whatever clock this machine keeps."
  (let ((previous (getenv "TZ")))
    (dynamic-wind (lambda ()
                    (setenv "TZ" "UTC")
                    (tzset))
                  thunk
                  (lambda ()
                    (if previous (setenv "TZ" previous)
                        (unsetenv "TZ"))
                    (tzset)))))

;;; ====== The addresses a bookmark is reached by ======

;; A link, and the address it is written as.  Every scheme below is one a
;; bookmarks file may hold: the web, the archive, the mail server, the gemini
;; capsule and the magnet handle.
(define addressed
  '(("codeberg.org/jjba23" . "https://codeberg.org/jjba23")
    ("www.gnu.org/software/emacs" . "https://www.gnu.org/software/emacs")
    ("https://example.org" . "https://example.org")
    ("http://example.org" . "http://example.org")
    ("ftp://ftp.gnu.org/gnu" . "ftp://ftp.gnu.org/gnu")
    ("mailto:post@example.org" . "mailto:post@example.org")
    ("gemini://gemini.circumlunar.space" . "gemini://gemini.circumlunar.space")
    ("magnet:?xt=urn:btih:0123456789abcdef" . "magnet:?xt=urn:btih:0123456789abcdef")
    ;; A scheme is case-insensitive; the address keeps the case it was written
    ;; in, because a case changed is a different string to the reader even where
    ;; it is the same scheme to the browser.
    ("MAILTO:post@example.org" . "MAILTO:post@example.org")
    ;; A host and its port are not a scheme.
    ("example.org:8080/status" . "https://example.org:8080/status")))

(define (addresses-of links)
  "LINK of each pair of LINKS, rendered."
  (map (lambda (pair)
         (cons (car pair)
               (url-string-with-protocol (car pair))))
       links))

(define (wanted-of links)
  "The address each pair of LINKS asks to be written as."
  (map (lambda (pair)
         (cons (car pair) (cdr pair)))
       links))

;;; ====== The suite ======

(define prelude-suite
  (suite "the prelude"
         #:shuffle? #f
         ;; The clock is set for the readings that depend on it, so nothing else
         ;; is read while it is set.
         #:concurrent? #f
         (test "a link is reached by the scheme it names"
               #:shuffle? #f
               (assert-equal #:name
                "every link, with a scheme or without one, becomes the address it asks for"
                #:expect (wanted-of addressed)
                #:got (addresses-of addressed))
               (assert-equal #:name
                "the fallback protocol is the one a run names"
                #:expect "gemini://example.org"
                #:got (url-string-with-protocol "example.org"
                                                #:fallback-protocol "gemini://")))
         (test "a link is what it was written as"
               #:shuffle? #f
               (let ((bare (url "codeberg.org/jjba23"))
                     (named (url "codeberg.org/jjba23"
                                 #:name "Codeberg"
                                 #:added "2025-01-22"
                                 #:tags '(dev))))
                 (assert-equal #:name
                  "a link written without a name is named by its address"
                  #:expect "codeberg.org/jjba23"
                  #:got (url-name bare))
                 (assert-equal #:name "and carries no date"
                               #:expect #f
                               #:got (url-added bare))
                 (assert-equal #:name "and no tags"
                               #:expect #f
                               #:got (url-tags bare))
                 (assert-equal #:name "while a named link keeps its name"
                               #:expect "Codeberg"
                               #:got (url-name named))
                 (assert-equal #:name "and the day it was added"
                               #:expect "2025-01-22"
                               #:got (url-added named))
                 (assert-equal #:name "and its tags"
                               #:expect '(dev)
                               #:got (url-tags named))))
         (test "a folder is a name and the bookmarks in it"
               #:shuffle? #f
               (let ((folder (dir "Work"
                                  (url "codeberg.org/jjba23")
                                  (dir "Ops" (url "grafana.test-backend.nl")))))
                 (assert-equal #:name "the name is the one it was given"
                               #:expect "Work"
                               #:got (dir-name folder))
                 (assert-equal #:name
                  "and its items are the bookmarks written in it, in order"
                  #:expect 2
                  #:got (length (dir-items folder)))
                 (assert-true (dir-record? (cadr (dir-items folder)))
                              #:name "a folder holds folders")
                 (assert-true (url-record? (car (dir-items folder)))
                              #:name "and links")))
         (test "a day is read as the instant it names"
               #:shuffle? #f
               (assert-equal #:name "the first day of the epoch is the epoch"
                             #:expect 0
                             #:got (in-utc (lambda ()
                                             (ymd-date-to-epoch "1970-01-01"))))
               (assert-equal #:name
                "and a day the bookmarks of this project are dated with is read as midnight of that day"
                #:expect 1737504000
                #:got (in-utc (lambda ()
                                (ymd-date-to-epoch "2025-01-22"))))
               (assert-equal #:name
                "while a date that is not a date is refused rather than guessed"
                #:expect #t
                #:got (catch #t
                        (lambda ()
                          (in-utc (lambda ()
                                    (ymd-date-to-epoch "not-a-date")))
                          #f)
                        (lambda (key . args) #t))))
         (test "a list of lists is read as the bookmarks it holds"
               #:shuffle? #f
               (let* ((link (url "a.example"))
                      (folder (dir "Work" link))
                      (nested (list (list link folder) (list (list link)))))
                 (assert-equal #:name
                  "flattening keeps folders, and the links of every list in order"
                  #:expect (list link folder link)
                  #:got (flatten nested))
                 (assert-equal #:name "and an empty list holds nothing"
                               #:expect '()
                               #:got (flatten '()))))))

(define (spec)
  (veritas-run prelude-suite))

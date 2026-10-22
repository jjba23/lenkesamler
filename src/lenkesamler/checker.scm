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

(define-module (lenkesamler checker)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (ice-9 format)
  #:use-module (web client)
  #:use-module (web uri)
  #:use-module (web response)
  #:use-module (lenkesamler prelude)
  #:export (link-check link-check? check-url check-status check-detail
                        check-link check-bookmarks check-report checks-failed?
                        web-address? http-probe))

;;; Whether the links of a bookmarks file are still there.
;;;
;;; A bookmarks file is a promise about addresses, and the addresses are the
;;; part of it that somebody else can break.  `lenkesamler --check' asks every
;;; one of them what it answers now and reports what it found: a link that
;;; answers, a link that answers with an address other than the one written, a
;;; link that answers with a refusal, and a link that does not answer at all.
;;;
;;; What is asked is a HEAD request, which is a request for exactly this -- the
;;; status of a page without the page -- and a server that does not know HEAD
;;; (405, or 501) is asked for the page instead, because a refusal to answer the
;;; question is not the answer.  A redirect is reported and not counted as a
;;; failure: the file says where the bookmark was written to lead, and the
;;; reading is about where it leads now.  A refusal and a silence are failures,
;;; and they are what makes the run exit non-zero -- which is what lets a
;;; pipeline check a bookmarks file at all.
;;;
;;; Not every bookmark is a page.  A `mailto:' address and a `magnet:' link are
;;; bookmarks as much as a web page is, and nothing answers a HEAD request for
;;; them: asking would report the address itself as a broken link.  Those are
;;; reported as skipped and are not a failure, which is the difference between
;;; a link that is gone and a link that was never a page.
;;;
;;; The reading is done through one procedure, `http-probe', which answers with
;;; the status a server gave and, when it gave one, the address it points at.
;;; A spec hands `check-bookmarks' its own probe: what is being read in
;;; `(veritas unit checker-spec)' is the report a broken file makes, which is
;;; not something to find out by asking the internet whether it is still up.

;;; ====== What one link answered ======

(define-record-type link-check
  (make-link-check url status detail) link-check?
  (url check-url)
  ;; One of `ok', `moved', `broken', `error' or `skipped'.
  (status check-status)
  ;; What the answer said, for a reader: the code, where it leads, or why there
  ;; was no answer at all.
  (detail check-detail))

(define (status-of code)
  "What a link that answered with CODE is: there, moved, or broken."
  (cond
    ((not code) 'broken)
    ((and (>= code 200) (< code 300)) 'ok)
    ((and (>= code 300) (< code 400)) 'moved)
    (else 'broken)))

(define (web-address? address)
  "Whether ADDRESS is one a web server answers, which only http and https are.

An address written without a scheme is read as one, because that is how
`url-string-with-protocol' hands it over: `codeberg.org/jjba23' is a page."
  (let ((colon (string-index address #\:)))
    (and colon
         (if (member (string-downcase (substring address 0 colon))
                     '("http" "https"))
             #t
             #f))))

;;; ====== Asking a server ======

;; What this program says it is, because a server is allowed to answer
;; differently to a client that does not say.  It says no more than that: a
;; request is checked by Guile before it is sent, and `accept: */*' -- which a
;; server would read as fine -- is not a header it will build.
(define client-headers
  '((user-agent . "lenkesamler")))

(define (location-of headers)
  "Where a response says a redirect leads, or #f when it says nothing.

Guile hands `location' over as the URI it read, and a server that writes
something it cannot read as one leaves a string: both are the address the answer
points at, and what is wanted here is the address as text."
  (let ((location (assq-ref headers 'location)))
    (cond
      ((string? location) location)
      ((uri? location) (uri->string location))
      (else #f))))

(define* (http-probe url)
  "The status URL answers with, and the address it leads to instead, if any.

A HEAD request is asked first; a server that answers 405 or 501 does not know
that request and is asked for the page itself.  The answer is `(CODE . LOCATION)'
with LOCATION `#f' when the answer was not a redirect.  A server that cannot be
reached at all raises, which `check-link' reports as no answer."
  (define (response-for method)
    (if (eq? method 'HEAD)
        (http-head url #:headers client-headers)
        (call-with-values (lambda ()
                            (http-get url #:headers client-headers
                                      #:streaming? #f))
          (lambda (response page)
            response))))
  (let loop ((method 'HEAD))
    (let* ((response (response-for method))
           (code (response-code response)))
      (if (and (eq? method 'HEAD) (memv code '(405 501)))
          (loop 'GET)
          (cons code (location-of (response-headers response)))))))

;;; ====== Checking a file ======

(define* (check-link url #:key (probe http-probe))
  "The reading of URL, as the check PROBE makes of it."
  (if (not (web-address? url))
      ;; Nothing to ask: the address is not a page, so it is neither there nor
      ;; gone, and a run that failed over it would fail over the file.
      (make-link-check url 'skipped "not a web address")
      (catch #t
        (lambda ()
          (let* ((answer (probe url))
                 (code (car answer))
                 (location (cdr answer))
                 (status (status-of code)))
            (make-link-check url status
                             (if (eq? status 'moved)
                                 (format #f "~a -> ~a" code (or location "?"))
                                 (format #f "~a" code)))))
        (lambda (key . args)
          (make-link-check url 'error
                           (format #f "~a~@[: ~a~]"
                                   key
                                   (and (pair? args) (car args))))))))

(define (addresses-of item)
  "The addresses ITEM holds: itself, when it is a link, and, when it is a
folder, the addresses of everything inside it.

A folder is walked rather than flattened: `flatten' reads nested lists -- a
folder built by `map' -- and a folder is a record, which is not a list, so its
links would be left unchecked."
  (cond
    ((dir-record? item)
     (append-map addresses-of (flatten (dir-items item))))
    ((url-record? item)
     (list (url-string-with-protocol (url-link item))))
    (else '())))

(define* (check-bookmarks bookmarks #:key (probe http-probe))
  "A reading of every link BOOKMARKS holds, each address read once.

The reading is in the order the file holds the links, and an address written
twice -- two folders holding the same page, which is how a bookmarks file of a
person's usually goes -- is read once and reported once."
  (delete-duplicates
   (map (lambda (address)
          (check-link address #:probe probe))
        (delete-duplicates (append-map addresses-of (flatten bookmarks))
                           string=?))
   (lambda (first second)
     (string=? (check-url first) (check-url second)))))

(define (checks-of checks status)
  "The checks of CHECKS that read as STATUS."
  (filter (lambda (check)
            (eq? (check-status check) status))
          checks))

(define (checks-failed? checks)
  "Whether a run of these CHECKS is a failure: a refusal or no answer at all."
  (or (pair? (checks-of checks 'broken))
      (pair? (checks-of checks 'error))))

;;; ====== What a run says ======

(define (line-of check)
  "CHECK as one line of the report: what it is, where it leads, and what it said."
  (format #f "~8a ~a~a"
          (check-status check)
          (check-url check)
          (if (check-detail check)
              (format #f " (~a)" (check-detail check))
              "")))

(define (check-report checks)
  "CHECKS as the report of a run, one line per link and a count of them."
  (let ((count (length checks)))
    (string-append
     (format #f "checked ~a ~a~%"
             count
             (if (= count 1) "link" "links"))
     (if (null? checks)
         ""
         (string-append (string-join (map line-of checks) "\n")
                        "\n"))
     (format #f "~a ok, ~a moved, ~a broken, ~a error, ~a skipped~%"
             (length (checks-of checks 'ok))
             (length (checks-of checks 'moved))
             (length (checks-of checks 'broken))
             (length (checks-of checks 'error))
             (length (checks-of checks 'skipped))))))

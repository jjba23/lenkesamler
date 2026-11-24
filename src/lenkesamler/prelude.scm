;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
  (let* ((module (resolve-module '(lenkesamler bookmarks)))
         (user-setting (module-variable module setting)))
    ;; A bookmarks file that is loaded but defines no such variable is a
    ;; mistake in the file, not a bug here: say which file shape is wanted
    ;; instead of failing inside `variable-ref' with an empty message.
    (if user-setting
        (variable-ref user-setting)
        (error "lenkesamler: no such setting in the bookmarks file"
               setting
               "-- a bookmarks file must define the module (lenkesamler bookmarks) and, in it, a lenkesamler-bookmarks list"))))

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

(define url-schemes
  '("http" "https" "ftp" "ftps" "sftp" "mailto" "gemini" "gopher" "irc"
    "ircs" "magnet" "ssh" "git" "file" "tel" "news" "nntp" "data" "ws"
    "wss" "urn" "xmpp"))

(define (absolute-url? x)
  "Whether X already names the URL scheme it is reached by.

Only the schemes listed above count: `example.org:8080/status' is a host and
its port, not a document written in a scheme called `example.org', so it is
still handed the fallback protocol."
  (let ((colon (string-index x #\:)))
    (and colon
         (if (member (string-downcase (substring x 0 colon)) url-schemes)
             #t
             #f))))

(define* (url-string-with-protocol x
                                   #:key (fallback-protocol "https://"))
  "X as a URL a browser can follow.

A link written without a scheme -- which is how most of a bookmarks file is
written, `codeberg.org/jjba23' -- is reached over FALLBACK-PROTOCOL.  A link
that already names its own scheme keeps it, whatever the scheme is: a
`mailto:' address and an `ftp:' archive are as much bookmarks as a web page."
  (if (absolute-url? x)
      x
      (format #f "~a~a" fallback-protocol x)))

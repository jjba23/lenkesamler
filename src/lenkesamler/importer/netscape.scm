;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (lenkesamler importer netscape)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-13)
  #:use-module (srfi srfi-19)
  #:use-module (ice-9 format)
  #:use-module (ice-9 regex)
  #:use-module (lenkesamler prelude)
  #:export (parse-netscape-bookmarks))

;;; Reading what a browser writes.
;;;
;;; The file a browser exports is the same archaic HTML this project writes in
;;; `(lenkesamler renderer netscape)', read the other way: a `<DL>' opens a
;;; list, an `<H3>' names the folder of the list that follows it, and an `<A>'
;;; is a link with an address in `HREF'.  It is not XML and cannot be read as
;;; XML -- `DT' is never closed, `P' stands alone between the tags, and the
;;; doctype of the format is not a document type anybody could declare -- so it
;;; is read here the way a browser reads it: tag by tag, in order, with the
;;; unclosed ones simply not being a problem.
;;;
;;; Two details of the format are worth naming.  A name and an address are
;;; written with the entities of HTML -- `R&amp;D' -- because `&' in an
;;; attribute or a name would otherwise be the start of an entity, so both are
;;; read back.  And a day is written as `ADD_DATE', seconds since the epoch in
;;; the timezone the browser ran in; that instant is read back as the day it
;;; names in this machine's timezone, which is the zone the browser wrote it in
;;; when the file is imported where it was exported.
;;;
;;; Whatever a browser writes that this project has no use for -- `LAST_CHARSET',
;;; `PLACEHOLDER', `ICON', the `TAGS' of a browser that tracks none -- is
;;; dropped.  The `TAGS' a browser does write are kept, because Firefox writes
;;; them and they are bookmarks' own data.

;;; ====== The tags of a file ======

;; A tag as `(tag NAME . RAW)': the name it opens or closes, in lowercase, and
;; the whole of what stood between its brackets.  The text between two tags is
;; `(text . STRING)'.  Nothing else is a token.
(define (tag-token? token)
  (eq? (car token) 'tag))

(define (tag-token-name token)
  (cadr token))

(define (tag-token-raw token)
  (cddr token))

(define (text-token? token)
  (eq? (car token) 'text))

(define (text-token-text token)
  (cdr token))

(define (names-end text)
  "How much of TEXT may be part of a tag's name."
  (let loop ((index 0))
    (if (and (< index (string-length text))
             (let ((character (string-ref text index)))
               (or (char-alphabetic? character)
                   (char-numeric? character)
                   (char=? character #\!))))
        (loop (+ index 1))
        index)))

(define (tag-name raw)
  "The name RAW opens or closes, lowercase.

A tag that closes one keeps the slash it is written with in the file, so the
closing `a` and the opening `a` of a link are two names and not one."
  (let* ((trimmed (string-trim-both raw))
         (closing? (and (positive? (string-length trimmed))
                        (char=? (string-ref trimmed 0) #\/)))
         (body (if closing?
                   (string-trim-both (substring trimmed 1))
                   trimmed)))
    (string-downcase (string-append (if closing? "/" "")
                                    (substring body 0 (names-end body))))))

(define (text-before text from to)
  "TEXT between FROM and TO, if there is anything between them."
  (if (< from to) (substring text from to) ""))

(define (tokens-of text)
  "TEXT as the tags it holds and the text between them, in order.

A tag whose brackets are never closed is text: a file that is broken at its end
is read as far as it goes rather than refused."
  (let ((length (string-length text)))
    (let loop ((position 0) (out '()))
      (let ((start (string-index text #\< position)))
        (cond
          ((not start)
           (reverse (if (< position length)
                        (cons (cons 'text (substring text position length)) out)
                        out)))
          (else
           (let ((out (if (< position start)
                          (cons (cons 'text (text-before text position start)) out)
                          out)))
             (if (and (<= (+ start 4) length)
                      (string=? (substring text start (+ start 4)) "<!--"))
                 ;; A comment is not a tag: it is skipped whole, and the `>' of
                 ;; a comment that holds one does not end anything.
                 (let ((end (string-contains text "-->" start)))
                   (loop (if end (+ end 3) length) out))
                 (let ((end (string-index text #\> start)))
                   (if (not end)
                       (reverse (cons (cons 'text (substring text start length))
                                      out))
                       (loop (+ end 1)
                             (cons (cons 'tag
                                         (cons (tag-name (substring text
                                                                    (+ start 1)
                                                                    end))
                                               (substring text (+ start 1) end)))
                                   out))))))))))))

;;; ====== What a tag says about itself ======

;; An attribute of a browser's bookmarks, quoted or not: `HREF="..."' is what
;; every browser writes, and the unquoted `HREF=...' of a hand-edited file is
;; read the same way rather than lost.
(define attribute-pattern
  (make-regexp "([A-Za-z_-]+)[ \t\r\n]*=[ \t\r\n]*(\"([^\"]*)\"|([^ \t\r\n>]+))"))

(define (attributes-of raw)
  "The attributes RAW holds, as a list of (NAME . VALUE) pairs, names lowercased."
  (let loop ((start 0) (out '()))
    (let ((match (regexp-exec attribute-pattern raw start)))
      (if (not match)
          (reverse out)
          (let ((name (string-downcase (match:substring match 1)))
                (value (or (match:substring match 3)
                           (match:substring match 4))))
            (loop (match:end match 0)
                  (cons (cons name value) out)))))))

(define (attribute attributes name)
  "The NAME of ATTRIBUTES, or #f when it was not written."
  (let ((found (assoc name attributes)))
    (and found (cdr found))))

;;; ====== The entities of HTML ======

(define named-entities
  '(("amp" . "&")
    ("lt" . "<")
    ("gt" . ">")
    ("quot" . "\"")
    ("apos" . "'")
    ("nbsp" . " ")))

(define entity-pattern
  (make-regexp "&(#[0-9]+|#[xX][0-9A-Fa-f]+|[A-Za-z][A-Za-z0-9]*);"))

(define (character-text code)
  "CODE as the one-character text it stands for, or #f when it is no character."
  (and (and code (exact-integer? code) (<= 0 code 1114111))
       (string (integer->char code))))

(define (entity-text name)
  "The text the entity NAME stands for, or #f for an entity nobody knows."
  (cond
    ((string-prefix? "#x" name)
     (character-text (string->number (substring name 2) 16)))
    ((string-prefix? "#X" name)
     (character-text (string->number (substring name 2) 16)))
    ((string-prefix? "#" name)
     (character-text (string->number (substring name 1))))
    (else (assoc-ref named-entities (string-downcase name)))))

(define (unescaped text)
  "TEXT with the entities of HTML read back as the characters they stand for.

An entity nobody knows is left as it was written: a name is not worth losing to
a `&' that somebody typed."
  (regexp-substitute/global #f entity-pattern text
                            'pre
                            (lambda (match)
                              (or (entity-text (match:substring match 1))
                                  (match:substring match 0)))
                            'post))

;;; ====== The day a link was added ======

(define (day-of seconds)
  "SECONDS since the epoch as the day it names, or #f when it names none."
  (let ((value (and seconds (string->number seconds))))
    (and value
         (date->string (time-utc->date (make-time time-utc 0 (inexact->exact
                                                              (truncate value))))
                       "~Y-~m-~d"))))

;;; ====== The tags a browser kept ======

(define (tags-of written)
  "The tags WRITTEN holds, as the symbols a bookmarks file names them with."
  (if written
      (apply append
             (map (lambda (tag)
                    (let ((name (string-trim-both (unescaped tag))))
                      (if (string-null? name)
                          '()
                          (list (string->symbol name)))))
                  (string-split written #\,)))
      #f))

;;; ====== A link, a folder, and the file's own list ======

(define (url-of tag name)
  "The link the anchor TAG holds, named NAME."
  (let* ((attributes (attributes-of (tag-token-raw tag)))
         (link (unescaped (or (attribute attributes "href") ""))))
    (url link
         #:name (if (string-null? name) link name)
         #:added (day-of (let ((written (attribute attributes "add_date")))
                           (and written (unescaped written))))
         #:tags (tags-of (let ((written (attribute attributes "tags")))
                           (and written (unescaped written)))))))

(define (text-until tokens name)
  "The text of TOKENS up to the tag that closes NAME, and what follows it.

TOKENS begins with the tag that opened NAME.  Anything else that turns up
inside -- a `<b>' a browser wrote into a name -- is not part of the name."
  (let loop ((rest (cdr tokens)) (out '()))
    (cond
      ((null? rest) (values (string-concatenate (reverse out)) '()))
      ((and (tag-token? (car rest))
            (string=? (tag-token-name (car rest))
                      (string-append "/" name)))
       (values (string-concatenate (reverse out)) (cdr rest)))
      ((text-token? (car rest))
       (loop (cdr rest) (cons (text-token-text (car rest)) out)))
      (else (loop (cdr rest) out)))))

(define (close-frame stack)
  "STACK with its innermost list closed, and its folder added to the one around."
  (let* ((frame (car stack))
         (parent (cadr stack))
         (items (reverse (cdr frame)))
         ;; `dir' takes the bookmarks of a folder as the arguments after its
         ;; name, so the list of them is spread over the call: passing the list
         ;; itself would make a folder holding one bookmark that is a list.
         (made (if (car frame)
                   (list (apply dir (car frame) items))
                   items)))
    (cons (cons (car parent) (append (reverse made) (cdr parent)))
          (cddr stack))))

(define (parse-netscape-bookmarks text)
  "TEXT, the bookmarks file a browser wrote, as the bookmarks it holds.

The answer is a list of `dir' and `url' records -- the same records a bookmarks
file is written in -- so a file a browser wrote can be rendered in every mode
this program has, a bookmarks file included.

A file that ends in the middle of a folder -- a download that stopped, a file
somebody edited -- is read as far as it goes: the lists still open at the end of
the text are closed there, so the folders that were written are the folders that
come out."
  (let loop ((tokens (tokens-of text))
             ;; The stack of the lists being read, innermost first.  The frame
             ;; at the bottom is the file's own list, which has no name; every
             ;; frame above it is the list of a folder.
             (stack (list (cons #f '())))
             (pending #f))
    (if (null? tokens)
        (let finish ((stack stack))
          (if (null? (cdr stack))
              (reverse (cdr (car stack)))
              (finish (close-frame stack))))
        (let ((token (car tokens)))
          (cond
            ((not (tag-token? token)) (loop (cdr tokens) stack pending))
            (else
             (let ((name (tag-token-name token))
                   (raw (tag-token-raw token)))
               (case (string->symbol name)
                 ((h3)
                  (let-values (((folder rest) (text-until tokens "h3")))
                    (loop rest stack
                          (let ((name (string-trim-both (unescaped folder))))
                            (and (not (string-null? name)) name)))))
                 ((a)
                  (let-values (((written rest) (text-until tokens "a")))
                    (let* ((frame (car stack))
                           (link (url-of token
                                         (string-trim-both (unescaped written)))))
                      (loop rest
                            (cons (cons (car frame) (cons link (cdr frame)))
                                  (cdr stack))
                            pending))))
                 ((dl)
                  ;; A list that names no folder is the file's own list, which
                  ;; is already the frame at the bottom of the stack.
                  (loop (cdr tokens)
                        (if pending
                            (cons (cons pending '()) stack)
                            stack)
                        #f))
                 ((/dl)
                  (loop (cdr tokens)
                        (if (null? (cdr stack))
                            stack
                            (close-frame stack))
                        pending))
                 (else (loop (cdr tokens) stack pending))))))))))

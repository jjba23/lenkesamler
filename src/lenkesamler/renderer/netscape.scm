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
  #:use-module (lenkesamler html)
  #:use-module (ice-9 threads)
  #:export (netscape-bookmark-renderer))

;; Names are text of the document, not markup of it: a bookmark named `R&D' or
;; `a < b' is written as `R&amp;D' and `a &lt; b', which is what makes the file
;; a browser imports the file that was written.  The markup collected around
;; them below is the format's own glue -- the `<DT>' of a line and the `<DL><P>'
;; of a folder, which this archaic format expects unclosed -- so it is written
;; as it stands.  An attribute -- the link of a bookmark -- is escaped by the
;; writer itself, whenever it is written.
(define (text x)
  "X as the text of a document: the characters that are markup are entities."
  (call-with-output-string (lambda (port) (string->escaped-xml x port))))

(define (dir-to-html x)
  `("\n<DT>" (H3 ,(text (dir-name x)))
    (DL "<P>"
        ,@(map parse-lenksamler-to-html
               (dir-items x)) "<P>")))

;; A link's tags are written as the one `TAGS' attribute Firefox reads, comma
;; separated -- which is also how they are read back again.  The attribute has
;; been written and read by browsers since long before this project, and a link
;; that came out of one with tags is a link that goes back into one with them.
(define (tags-attribute tags)
  (if (list? tags)
      `((TAGS ,(string-join (map (lambda (tag)
                                   (format #f "~a" tag)) tags)
                            ",")))
      '()))

(define (url-to-html x)
  `("\n<DT>" (A (@ (HREF ,(url-string-with-protocol (url-link x)))
                   ,@(if (url-added x)
                         `((ADD_DATE ,(ymd-date-to-epoch (url-added x))))
                         '())
                   ,@(tags-attribute (url-tags x)))
                ,(text (url-name x)))))

(define (parse-lenksamler-to-html x)
  (cond
    ((dir-record? x)
     (dir-to-html x))
    ((url-record? x)
     (url-to-html x))
    ((list? x)
     (map parse-lenksamler-to-html x))
    (else (throw "unknown data type for bookmark" x))))

(define* (netscape-bookmark-renderer xs)
  (let* ((parsed-nodes (map parse-lenksamler-to-html (flatten xs)))
         (tree `("<!DOCTYPE NETSCAPE-Bookmark-file-1>" (META (@ (http-equiv
                                                                 Content-Type)
                                                                (content
                                                                 "text/html; charset=UTF-8")))
                 (TITLE "Bookmarks")
                 (H1 "Bookmarks")
                 "\n<DL><P>"
                 ,@parsed-nodes
                 "\n</DL><P>\n")))
    tree))

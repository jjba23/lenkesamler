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

(define-module (lenkesamler renderer xbel)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 format)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler html)
  #:export (xbel-bookmark-renderer))

;;; A bookmarks file as XML Bookmark Exchange Language.
;;;
;;; XBEL is the one format of the three this project writes that is a document
;;; rather than a transcription of somebody's screen: an `<xbel>' root holding
;;; `folder' and `bookmark' elements, a folder named by a `title' child and
;;; spelling its nesting by its own nesting, and a bookmark carrying its address
;;; in `href' and its name in a `title' child as well.
;;;
;;; Two decisions are the format's, not this renderer's.  The day of a link goes
;;; in the `added' attribute of the bookmark, which is where XBEL keeps it.  And
;;; the tags of a link are not written at all: XBEL 1.0 has no place for them,
;;; and a `metadata' element of this project's own invention would be a document
;;; that says it is XBEL and is not.  A file that needs the tags is a file for
;;; another mode -- `json' or `scheme' keep everything this project holds.
;;;
;;; What is written is a well-formed XML document, so every value is escaped as
;;; XML escapes a value: the writer is asked to, because a name holding an
;;; ampersand is a name and not the start of an entity.  The prologue -- the
;;; declaration and the doctype -- is written outside the writer, because a
;;; doctype is not an element and a declaration is not even markup.

(define prologue
  (string-append "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                 "<!DOCTYPE xbel"
                 " PUBLIC \"+//IDN python.org//DTD XML Bookmark Exchange Language 1.0//EN//XML\""
                 " \"http://www.python.org/topics/xml/dtds/xbel-1.0.dtd\">\n"))

(define* (node-of item #:key (indent 0))
  "ITEM as the XBEL element it is, its children INDENT spaces in."
  (let ((pad (make-string indent #\space))
        (inner (make-string (+ indent 2) #\space)))
    (cond
      ((dir-record? item)
       `(folder (title ,(dir-name item))
                ;; Each child of a folder is a line of its own, and the folder
                ;; is closed on a line of its own under them.
                ,@(append-map (lambda (child)
                                (list "\n" inner
                                      (node-of child #:indent (+ indent 2))))
                              (flatten (dir-items item)))
                "\n" ,pad))
      ((url-record? item)
       `(bookmark (@ (href ,(url-string-with-protocol (url-link item)))
                     ,@(if (url-added item)
                           `((added ,(url-added item)))
                           '()))
                  (title ,(url-name item))))
      (else (throw "unknown data type for bookmark" item)))))

(define (xbel-bookmark-renderer xs)
  "XS as an XBEL document."
  (string-append
   prologue
   (with-output-to-string
     (lambda ()
       (sxml->xml `(xbel (@ (version "1.0"))
                          ,@(append-map (lambda (item)
                                          (list "\n  " (node-of item #:indent 2)))
                                        (flatten xs))
                          "\n")
                  (current-output-port)
                  ;; Asked for, because a name is text and not markup: the
                  ;; document is the one a reader of XML is handed.
                  #t)))
   "\n"))

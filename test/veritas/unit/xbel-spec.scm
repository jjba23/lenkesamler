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

;;; A bookmarks file as XML Bookmark Exchange Language.
;;;
;;; XBEL is the only mode of this program whose document is meant to be read by
;;; another program, so the reading that matters most here is not of the text:
;;; the document is handed to an XML parser, and what the parser makes of it is
;;; a tree of folders and bookmarks -- a file that only looked like XML would
;;; pass every reading of the text and fail this one.
;;;
;;; The readings of the text are of the three decisions the format takes.  A
;;; folder is an element whose nesting is its nesting, because XBEL has no list
;;; of folders and titles to zip together.  A link carries its address in
;;; `href' and its name in a `title' child, and its day in `added' -- with no
;;; `added' at all for a link that has no day, because an empty attribute would
;;; say the link was added on the day of nothing.  And a name is text: XML is
;;; markup all the way down, so a name holding `&' or `<' is escaped, and the
;;; parser gives back the name it was.
;;;
;;; The last reading is of the tags, which are not in the document.  XBEL 1.0
;;; has nowhere to keep them, and a `metadata' element invented here would be a
;;; file that says it is XBEL and is not.

(define-module (veritas unit xbel-spec)
  #:use-module (veritas veritas)
  #:use-module (sxml simple)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler renderer xbel)
  #:export (spec))

;;; ====== A bookmarks file, written as XBEL ======

(define bookmarks
  (list (dir "Work"
             (url "codeberg.org/jjba23"
                  #:name "Codeberg"
                  #:added "2025-01-22")
             (dir "Ops"
                  (url "grafana.test-backend.nl"
                       #:name "Grafana")))
        (url "example.org"
             #:name "R&D <notes>")))

(define (document-of bookmarks)
  "BOOKMARKS as an XBEL document."
  (xbel-bookmark-renderer bookmarks))

(define (parsed bookmarks)
  "BOOKMARKS, as the XML parser reads the document written from them."
  (xml->sxml (document-of bookmarks) #:trim-whitespace? #t))

;;; ====== The suite ======

(define xbel-suite
  (suite "the XBEL reading"
         #:shuffle? #f
         (test "the document says what it is"
               #:shuffle? #f
               (assert-true (string-prefix? "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                                            (document-of bookmarks))
                            #:name "it begins with the XML declaration")
               (assert-contains #:name "and a doctype naming the language"
                #:expect (document-of bookmarks)
                #:got "<!DOCTYPE xbel PUBLIC \"+//IDN python.org//DTD XML Bookmark Exchange Language 1.0//EN//XML\" \"http://www.python.org/topics/xml/dtds/xbel-1.0.dtd\">")
               (assert-contains #:name "the root is xbel, at version 1.0"
                #:expect (document-of bookmarks)
                #:got "<xbel version=\"1.0\">")
               (assert-true (string-suffix? "</xbel>\n" (document-of bookmarks))
                            #:name "and the root is closed, on a line of its own"))
         (test "a folder is an element holding what it holds"
               #:shuffle? #f
               (assert-contains #:name "a folder is named by its title child"
                #:expect (document-of bookmarks)
                #:got "  <folder><title>Work</title>\n")
               (assert-contains #:name
                "a link inside it is nested one level further, with its address and name"
                #:expect (document-of bookmarks)
                #:got "    <bookmark href=\"https://codeberg.org/jjba23\" added=\"2025-01-22\"><title>Codeberg</title></bookmark>\n")
               (assert-contains #:name
                "a folder inside a folder is nested again, not listed beside it"
                #:expect (document-of bookmarks)
                #:got "    <folder><title>Ops</title>\n")
               (assert-contains #:name "and a folder is closed on a line of its own"
                #:expect (document-of bookmarks)
                #:got "    </folder>\n"))
         (test "a link says where it leads and what it is called"
               #:shuffle? #f
               (assert-contains #:name "a link written without a scheme is a page"
                #:expect (document-of (list (url "grafana.test-backend.nl"
                                                #:name "Grafana")))
                #:got "<bookmark href=\"https://grafana.test-backend.nl\"><title>Grafana</title></bookmark>")
               (assert-contains #:name "a link that names its own scheme keeps it"
                #:expect (document-of (list (url "mailto:post@example.org"
                                                #:name "Write")))
                #:got "href=\"mailto:post@example.org\"")
               (assert-not-contains #:name
                "a link with no day is given no `added', rather than an empty one"
                #:expect (document-of (list (url "example.org" #:name "N")))
                #:got "added")
               (assert-contains #:name
                "a link named by its own address is titled with it"
                #:expect (document-of (list (url "example.org")))
                #:got "<title>example.org</title>"))
         (test "a name is text, not markup"
               #:shuffle? #f
               (assert-contains #:name "an ampersand in a name is escaped"
                #:expect (document-of bookmarks)
                #:got "<title>R&amp;D &lt;notes&gt;</title>"))
         (test "a reader of XML reads the file"
               #:shuffle? #f
               (assert-equal #:name
                "the document parses to the folders and links it was written from"
                #:expect
                '(*TOP* (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"")
                        (xbel (@ (version "1.0"))
                              (folder
                               (title "Work")
                               (bookmark
                                (@ (href "https://codeberg.org/jjba23")
                                   (added "2025-01-22"))
                                (title "Codeberg"))
                               (folder
                                (title "Ops")
                                (bookmark
                                 (@ (href "https://grafana.test-backend.nl"))
                                 (title "Grafana"))))
                              (bookmark
                               (@ (href "https://example.org"))
                               (title "R&D <notes>"))))
                #:got (parsed bookmarks)))
         (test "a document of no bookmarks is still a document"
               #:shuffle? #f
               (assert-equal #:name "the file parses to an empty xbel"
                             #:expect
                             '(*TOP* (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"")
                                     (xbel (@ (version "1.0"))))
                             #:got (parsed '())))))

(define (spec)
  (veritas-run xbel-suite))

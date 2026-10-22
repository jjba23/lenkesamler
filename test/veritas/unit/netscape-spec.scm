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

;;; The file a browser imports.
;;;
;;; The Netscape format is the archaic, half-closed HTML every browser still
;;; reads, so the reading here is of the document as a browser is handed it: the
;;; doctype that says which format this is, the `<DL>' that makes a folder, the
;;; `<H3>' that names it and the `<A>' of a link, with `ADD_DATE' on the links
;;; that were given a day.
;;;
;;; Two things a bookmarks file of a person's holds are read more closely.  A
;;; name is text of the document and is written as entities, because `R&D' is a
;;; name and not the opening of one; and an address that names its own scheme
;;; keeps it, because `mailto:' written as `https://mailto:' is a link a browser
;;; cannot follow.  A folder built by `map' -- a list inside the list of
;;; bookmarks, which is how the README builds one -- is read as the links it
;;; holds, in order.
;;;
;;; The day a link was added is read with the clock of UTC, named by the spec:
;;; `ymd-date-to-epoch' reads a date in the timezone of the machine it runs on,
;;; and a reading that inherited that clock would pass here and fail elsewhere.

(define-module (veritas unit netscape-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler html)
  #:use-module (lenkesamler renderer netscape)
  #:export (spec))

;;; ====== Reading a bookmarks file as a browser reads it ======

(define (markup-of bookmarks)
  "BOOKMARKS as the text of the file a browser imports."
  (with-output-to-string (lambda ()
                           (sxml->xml (netscape-bookmark-renderer bookmarks)))))

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

;; The head every file of this format begins with: the doctype, the encoding a
;; reader is told to expect, and the two names of the document.
(define head
  "<!DOCTYPE NETSCAPE-Bookmark-file-1><META http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><TITLE>Bookmarks</TITLE><H1>Bookmarks</H1>\n<DL><P>")

(define tail
  "\n</DL><P>\n")

;;; ====== The suite ======

(define netscape-suite
  (suite "the file a browser imports"
         #:shuffle? #f
         #:concurrent? #f
         (test "a link is a line of the list"
               #:shuffle? #f
               (assert-equal #:name
                "a file holding one link is the format's head, the link and the format's tail"
                #:expect (string-append head
                                        "\n<DT><A HREF=\"https://codeberg.org/jjba23\">Codeberg</A>"
                                        tail)
                #:got (markup-of (list (url "codeberg.org/jjba23"
                                            #:name "Codeberg"))))
               (assert-equal #:name
                "the day a link was added is the instant that day began"
                #:expect (string-append head
                                        "\n<DT><A HREF=\"https://codeberg.org/jjba23\" ADD_DATE=\"1737504000\">Codeberg</A>"
                                        tail)
                #:got (in-utc (lambda ()
                                (markup-of (list (url "codeberg.org/jjba23"
                                                      #:name "Codeberg"
                                                      #:added "2025-01-22")))))))
         (test "a folder is a list inside the list"
               #:shuffle? #f
               (assert-equal #:name
                "a folder is named by an H3 and holds a list of its own"
                #:expect (string-append head
                                        "\n<DT><H3>Work</H3><DL><P>"
                                        "\n<DT><A HREF=\"https://codeberg.org/jjba23\">Codeberg</A>"
                                        "<P></DL>"
                                        tail)
                #:got (markup-of (list (dir "Work"
                                            (url "codeberg.org/jjba23"
                                                #:name "Codeberg")))))
               (assert-equal #:name "and a folder may hold a folder"
                             #:expect (string-append head
                                                     "\n<DT><H3>Work</H3><DL><P>"
                                                     "\n<DT><H3>Ops</H3><DL><P>"
                                                     "\n<DT><A HREF=\"https://grafana.test-backend.nl\">Grafana</A>"
                                                     "<P></DL>"
                                                     "<P></DL>"
                                                     tail)
                             #:got (markup-of (list (dir "Work"
                                                         (dir "Ops"
                                                              (url "grafana.test-backend.nl"
                                                                   #:name "Grafana")))))))
         (test "a name is text of the document, not markup of it"
               #:shuffle? #f
               (assert-contains #:name
                "an ampersand and an angle bracket in a name are entities"
                #:expect (markup-of (list (url "example.org" #:name "R&D <notes>")))
                #:got "R&amp;D &lt;notes&gt;")
               (assert-not-contains #:name
                "and the name is never written to the file as it was typed"
                #:expect (markup-of (list (url "example.org" #:name "R&D <notes>")))
                #:got "R&D <notes>")
               (assert-contains #:name
                "while the markup the format's own glue is made of is written as it stands"
                #:expect (markup-of (list (dir "Work" (url "a.example"))))
                #:got "<DL><P>"))
         (test "an address is reached by the scheme it names"
               #:shuffle? #f
               (assert-contains #:name "a mail address stays a mail address"
                #:expect (markup-of (list (url "mailto:post@example.org"
                                              #:name "Write to the list")))
                #:got "HREF=\"mailto:post@example.org\"")
               (assert-contains #:name "and a link written without a scheme is reached over https"
                #:expect (markup-of (list (url "mastodon.social" #:name "Mastodon")))
                #:got "HREF=\"https://mastodon.social\"")
               (assert-contains #:name
                "and a query in an address is escaped as the attribute it is written in"
                #:expect (markup-of (list (url "example.org/search?a=1&b=2"
                                              #:name "Search")))
                #:got "HREF=\"https://example.org/search?a=1&amp;b=2\""))
         (test "a folder built by map is the links it holds"
               #:shuffle? #f
               (assert-equal #:name
                "a list inside the list of bookmarks is read as its links, in order"
                #:expect (string-append head
                                        "\n<DT><A HREF=\"https://prod.example\">Prod</A>"
                                        "\n<DT><A HREF=\"https://test.example\">Test</A>"
                                        tail)
                #:got (markup-of (list (list (url "prod.example" #:name "Prod")
                                             (url "test.example" #:name "Test"))))))))

(define (spec)
  (veritas-run netscape-suite))

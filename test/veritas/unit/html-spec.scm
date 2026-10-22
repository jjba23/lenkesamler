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

;;; The writer: SXML in, the text of a document out.
;;;
;;; A bookmark is a name somebody gave a page, so it holds what people type into
;;; names -- an ampersand, an angle bracket, a quote.  Written into a document
;;; as they were typed, they are markup: a link named `R&D' would open an entity
;;; the file never closes.  The writer is therefore asked, by the run that
;;; renders a page, to write the characters of a text as the entities they are;
;;; and the reading here is that asking it for one part of a document asks it
;;; for every part -- the root of a document is a list, and a writer that
;;; forgot what it was asked when it stepped into that list left every element
;;; of every document unescaped.
;;;
;;; The markup this project writes by hand -- the unclosed `<DT>' of the
;;; Netscape format's own glue -- is written as it stands, which is why escaping
;;; is something a caller asks for rather than something the writer always does.

(define-module (veritas unit html-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler html)
  #:export (spec))

(define (written tree . options)
  "TREE written as a document, with OPTIONS -- ESCAPE? -- as given."
  (with-output-to-string (lambda ()
                           (apply sxml->xml tree (current-output-port) options))))

;;; ====== The suite ======

(define html-suite
  (suite "the writer"
         #:shuffle? #f
         (test "a text that holds markup is written as entities"
               #:shuffle? #f
               (assert-equal #:name "an ampersand in the body of an element"
                             #:expect "<p>a &amp; b</p>"
                             #:got (written '(p "a & b") #t))
               (assert-equal #:name "and in an element of a document"
                             #:expect "<p>a &amp; b</p>"
                             #:got (written '(*TOP* (p "a & b")) #t))
               (assert-equal #:name
                "and in every element of a document, not only the first"
                #:expect "x &amp; y<p>a &amp; b</p>"
                #:got (written (list "x & y" '(p "a & b")) #t))
               (assert-equal #:name
                "while a writer not asked for it writes the text as it stands"
                #:expect "<p>a & b</p>"
                #:got (written '(p "a & b"))))
         (test "an attribute is escaped whenever it is written"
               #:shuffle? #f
               (assert-equal #:name "an address holding a query"
                             #:expect "<a href=\"x?a=1&amp;b=2\">t</a>"
                             #:got (written '(a (@ (href "x?a=1&b=2")) "t"))))
         (test "the shape of the markup a browser is handed"
               #:shuffle? #f
               (assert-equal #:name "an element with no body is closed at once"
                             #:expect "<br />"
                             #:got (written '(br)))
               (assert-equal #:name "a bare text is written as it stands"
                             #:expect "plain"
                             #:got (written "plain"))
               (assert-equal #:name
                "the body of an element is written, and then the element closed"
                #:expect "<div><span>a</span></div>"
                #:got (written '(div (span "a")))))
         (test "a page is read for what it says"
               #:shuffle? #f
               (assert-equal #:name
                "the text of a document is its words, without its markup"
                #:expect "ab"
                #:got (sxml->string '(div "a" (span "b")))))))

(define (spec)
  (veritas-run html-suite))

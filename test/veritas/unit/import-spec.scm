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

;;; Reading what a browser writes.
;;;
;;; The file a browser exports is the same archaic HTML this project exports,
;;; read the other way, and it is not XML: `DT' is never closed, `P' stands
;;; alone, and the doctype of the format declares nothing.  So the readings here
;;; are of a file as a browser needs it read, not as an XML parser would refuse
;;; it: a folder, a folder inside a folder, a link in either, and a comment
;;; whose own text holds a `>' that ends nothing.
;;;
;;; The two details of the format worth their own reading are the entities of
;;; HTML -- `R&amp;D' is a name, and `&amp;b=2' is a query -- and the day of a
;;; link, which a browser writes as seconds since the epoch.  The day is read
;;; with the clock of UTC, named by the spec: the importer reads an instant as
;;; the day it names on the machine it runs on, which is the zone the browser
;;; wrote it in when the file is imported where it was exported, and a reading
;;; that inherited the clock would pass here and fail on the next machine.
;;;
;;; The last reading is the whole point of the feature: what a browser wrote,
;;; written back out as a bookmarks file of this project, and read again -- the
;;; link that went in is the link that comes out.  What a browser writes and
;;; this project has no place for -- `ICON', `LAST_CHARSET', the `<DD>' a
;;; browser wrote a note into -- is dropped, which is why the round trip is
;;; taken through this project's own export rather than through the browser's
;;; file: a format that only carries half of a bookmark cannot carry the half
;;; it never had.

(define-module (veritas unit import-spec)
  #:use-module (veritas veritas)
  #:use-module (lenkesamler prelude)
  #:use-module (lenkesamler importer netscape)
  #:use-module (lenkesamler renderer netscape)
  #:use-module (lenkesamler renderer scheme)
  #:use-module (lenkesamler html)
  #:use-module (ice-9 textual-ports)
  #:export (spec))

;;; ====== The file a browser wrote ======

(define fixture
  "test/fixtures/browser-bookmarks.html")

(define (imported path)
  "The bookmarks the browser's file at PATH holds."
  (parse-netscape-bookmarks
   (call-with-input-file path (lambda (port) (get-string-all port)))))

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

(define (folders-of bookmarks)
  "The folders BOOKMARKS holds, at the top level."
  (filter dir-record? (flatten bookmarks)))

(define bookmarks (in-utc (lambda ()
                           (imported fixture))))

(define work (car (folders-of bookmarks)))

(define ops (car (folders-of (dir-items work))))

;;; ====== The suite ======

(define import-suite
  (suite "the file a browser wrote"
         #:shuffle? #f
         #:concurrent? #f
         (test "a folder is the folder a browser wrote"
               #:shuffle? #f
               (assert-equal #:name "the folder of the file, by its name"
                             #:expect "Work"
                             #:got (dir-name work))
               (assert-equal #:name "and the folder written inside it"
                             #:expect "Ops & friends"
                             #:got (dir-name ops))
               (assert-equal #:name "the top level is the two folders and the links"
                             #:expect '(dir url url)
                             #:got (map (lambda (item)
                                          (if (dir-record? item) 'dir 'url))
                                        (flatten bookmarks))))
         (test "a link is the link a browser wrote"
               #:shuffle? #f
               (let ((link (car (dir-items work))))
                 (assert-equal #:name "the address it was written with"
                               #:expect "https://codeberg.org/jjba23"
                               #:got (url-link link))
                 (assert-equal #:name "the name it was written under"
                               #:expect "Codeberg"
                               #:got (url-name link))
                 (assert-equal #:name "and the day it was added, read as a day"
                               #:expect "2025-01-22"
                               #:got (url-added link))))
         (test "the entities of HTML are read back"
               #:shuffle? #f
               (let ((notes (list-ref (flatten (dir-items work)) 2))
                     (link (car (dir-items ops))))
                 (assert-equal #:name "an ampersand in a folder's name"
                               #:expect "Ops & friends"
                               #:got (dir-name ops))
                 (assert-equal #:name "an angle bracket in a link's name"
                               #:expect "R&D <notes>"
                               #:got (url-name notes))
                 (assert-equal #:name "and an ampersand in a query, which is no entity"
                               #:expect "http://example.org/search?a=1&b=2"
                               #:got (url-link notes))
                 (assert-equal #:name "an address with no day was given none"
                               #:expect #f
                               #:got (url-added (list-ref (flatten bookmarks) 1)))
                 (assert-true (url-record? link)
                              #:name "a folder holding only a link holds that link")))
         (test "the tags a browser kept are kept"
               #:shuffle? #f
               (let ((notes (list-ref (flatten (dir-items work)) 2))
                     (plain (car (dir-items work))))
                 (assert-equal #:name "a link a browser tagged is tagged here"
                               #:expect '(dev search)
                               #:got (url-tags notes))
                 (assert-equal #:name "and a link it did not tag is not"
                               #:expect #f
                               #:got (url-tags plain))))
         (test "an address that names its own scheme keeps it"
               #:shuffle? #f
               (let ((mail (list-ref (flatten bookmarks) 1)))
                 (assert-equal #:name "a mail address is a mail address"
                               #:expect "mailto:post@example.org"
                               #:got (url-link mail))
                 (assert-equal #:name
                               "and a day of zero is the day it names, not no day"
                               #:expect "1970-01-01"
                               #:got (url-added (list-ref (flatten bookmarks) 2)))))
         (test "a file with no bookmarks in it holds none"
               #:shuffle? #f
               (assert-equal #:name "an empty file"
                             #:expect '()
                             #:got (parse-netscape-bookmarks ""))
               (assert-equal #:name "and a file that never opens a list"
                             #:expect '()
                             #:got (parse-netscape-bookmarks
                                   "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n<TITLE>x</TITLE>\n"))
               (assert-equal #:name
                             "a comment whose own text holds a bracket ends nothing"
                             #:expect "https://x.example"
                             #:got (url-link
                                   (car (parse-netscape-bookmarks
                                         "<DL><p><!-- a > b --><DT><A HREF=\"https://x.example\">X</A></DL>")))))
         (test "what a browser wrote becomes a bookmarks file"
               #:shuffle? #f
               (let ((source (scheme-bookmark-renderer bookmarks)))
                 (assert-contains #:name "the folder a browser wrote is a folder here"
                  #:expect source
                  #:got "(dir \"Work\"")
                 (assert-contains #:name "and the folder inside it is inside it"
                  #:expect source
                  #:got "(dir \"Ops & friends\"")
                 (assert-contains #:name "and the tags a browser kept are tags here"
                  #:expect source
                  #:got "#:tags '(dev search)")))
         (test "a bookmarks file read back is the file it wrote"
               #:shuffle? #f
               ;; Every address here is one a browser's file can hold as it
               ;; stands.  A link written without a scheme -- `example.org' --
               ;; is written with one, because that is the address a browser
               ;; follows; the reading of that is below, on its own.
               (let* ((original (list (dir "Work"
                                           (url "https://codeberg.org/jjba23"
                                                #:name "Codeberg"
                                                #:added "2025-01-22"
                                                #:tags '(dev))
                                           (dir "Ops"
                                                (url "https://grafana.test-backend.nl"
                                                     #:name "Grafana")))
                                     (url "mailto:post@example.org"
                                          #:name "Write to the list")
                                     (url "https://example.org")))
                      (exported (in-utc (lambda ()
                                          (with-output-to-string
                                            (lambda ()
                                              (sxml->xml (netscape-bookmark-renderer
                                                          original)))))))
                      (read-again (in-utc (lambda ()
                                            (parse-netscape-bookmarks exported)))))
                 (assert-equal #:name
                  "the file this project exports is the file it imports"
                  #:expect original
                  #:got read-again)))
         (test "a file holds addresses, and an address is what is given back"
               #:shuffle? #f
               (let* ((written (in-utc (lambda ()
                                         (with-output-to-string
                                           (lambda ()
                                             (sxml->xml (netscape-bookmark-renderer
                                                         (list (url "example.org"
                                                                    #:name "Example")))))))))
                      (read-again (in-utc (lambda ()
                                            (parse-netscape-bookmarks written)))))
                 (assert-equal #:name
                  "a link written without a scheme comes back with the one a browser follows"
                  #:expect "https://example.org"
                  #:got (url-link (car read-again)))))))

(define (spec)
  (veritas-run import-suite))

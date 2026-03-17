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

(define-module (lenkesamler bookmarks)
  #:declarative? #t
  #:use-module (lenkesamler prelude))

(define joe-bookmarks
  (list (dir "jointhefreeworld"
             (url "jointhefreeworld.org")
             (url "wikimusic.jointhefreeworld.org"
                  #:name "WikiMusic")
             (url "lucidplan.jointhefreeworld.org"
                  #:name "LucidPlan")
             (url "byggsteg.jointhefreeworld.org"
                  #:name "Byggsteg")
             (url "oculuslambda.jointhefreeworld.org"
                  #:name "OculusLambda")
             (url "hygguile.jointhefreeworld.org"
                  #:name "Hygguile"))
        (url "web.whatsapp.com/"
             #:name "WhatsApp")
        (url "mastodon.social"
             #:name "Mastodon")
        (url "codeberg.org/jjba23"
             #:name "Codeberg")))

(define lenkesamler-bookmarks
  joe-bookmarks)

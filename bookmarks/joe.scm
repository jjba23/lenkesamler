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
  #:declarative? #t)

(define joe-bookmarks
  (list (dir "jointhefreeworld"
             (list (url "jointhefreeworld.org" "https://jointhefreeworld.org")
                   (url "WikiMusic" "https://wikimusic.jointhefreeworld.org")
                   (url "LucidPlan" "https://lucidplan.jointhefreeworld.org")
                   (url "Byggsteg" "https://byggsteg.jointhefreeworld.org")
                   (url "OculusLambda"
                        "https://oculuslambda.jointhefreeworld.org")
                   (url "Hygguile" "https://hygguile.jointhefreeworld.org")))
        (url "WhatsApp" "https://web.whatsapp.com/")
        (url "Mastodon" "https://mastodon.social")
        (url "Codeberg" "https://codeberg.org/jjba23")
        ))

(define bookmarks
  joe-bookmarks)

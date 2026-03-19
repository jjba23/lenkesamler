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

(define emacs-dir
  (dir "Emacs"
       (url "protesilaos.com/codelog/2024-09-10-emacs-show-font-0-1-0"
            #:name "show-font")
       (url "www.gnu.org/software/emacs/manual/html_mono/calc.html"
            #:name "Calc Manual"
            #:tags '(calc))))

(define dev-dir
  (dir "Dev"
       (url
        "www.iankduncan.com/engineering/2026-02-09-what-functional-programmers-get-wrong-about-systems/"
        #:name "What functional programmers get wrong about systems")))

(define jointhefreeworld-dir
  (dir "jointhefreeworld"
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
            #:name "Hygguile")))

(define torrents-dir
  (dir "Torrents"
       (url "www.limetorrents.to"
            #:name "LimeTorrents")
       (url "torrentgalaxy-official.is/"
            #:name "TorrentGalaxy")))

(define work-documents-dir
  (dir "Documents"
       (url
        "vandebron.atlassian.net/wiki/spaces/DIG/pages/95583095586887/REST+standards"
        #:name "🌐 REST standards"
        #:tags '(work))))

(define work-dir
  (dir "Work" work-documents-dir
       (url "app.slack.com/client/T1XNW2SF5/C08UHE7KM99"
            #:name "Slack")
       (dir "Ops P"
            (url "grafana.prod-backend.vdbinfra.nl"
                 #:name "Grafana"))
       (dir "Ops T"
            (url "grafana.test-backend.vdbinfra.nl"
                 #:name "Grafana"))))

(define social-dir
  (dir "Social"
       (url "web.whatsapp.com"
            #:name "WhatsApp")
       (url "mastodon.social"
            #:name "Mastodon")))

(define joe-bookmarks
  (list jointhefreeworld-dir
        work-dir
        dev-dir
        emacs-dir
        social-dir
        torrents-dir
        (url "codeberg.org/jjba23"
             #:name "Codeberg"
             #:added "2025-01-22"
             #:tags '(dev))))

(define lenkesamler-bookmarks
  joe-bookmarks)


;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (lenkesamler bookmarks)
  #:declarative? #t
  #:use-module (lenkesamler prelude))

(define emacs-dir
  (dir "Emacs"
       (url "protesilaos.com/codelog/2024-09-10-emacs-show-font-0-1-0"
            #:name "show-font"
            #:added "2026-03-17")
       (url "www.gnu.org/software/emacs/manual/html_mono/calc.html"
            #:name "Calc Manual"
            #:added "2026-03-18"
            #:tags '(calc))
       (url "github.com/doomemacs/themes/tree/screenshots"
            #:name "Doom Emacs screenshots")))

(define dev-dir
  (dir "Dev"
       (url "codeberg.org/jjba23"
            #:name "Codeberg"
            #:added "2025-01-22"
            #:tags '(dev))
       (dir "Articles"
            (url
             "www.iankduncan.com/engineering/2026-02-09-what-functional-programmers-get-wrong-about-systems"
             #:name "What functional programmers get wrong about systems"
             #:added "2026-03-20"))))

(define games-dir
  (dir "Games"
       (dir "Genshin"
            (url
             "act.hoyolab.com/ys/app/interactive-map/index.html?lang=en-us#/map/2?shown_types=&center=2008.50,-1084.00&zoom=-3.00"
             #:name "Teyvat Map"))))

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
       (url "torrentgalaxy-official.is"
            #:name "TorrentGalaxy")))

(define work-documents-dir
  (dir "Documents"
       (url
        "vandebron.atlassian.net/wiki/spaces/DIG/pages/95583095586887/REST+standards"
        #:name "🌐 REST standards"
        #:tags '(work))
       (url
        "vandebron.atlassian.net/wiki/spaces/DIG/pages/95582920015899/Energy+Report+-+Useful+links+observability+monitoring"
        #:name "Energy Report Links")
       (url
        "vandebron.lightning.force.com/lightning/r/Report/00OVk00000GJGXhMAP/view"
        #:name "Energy Report Salesforce Cases")
       (url "github.com/Vandebron/town-steering"
            #:name "Town Steering")
       (url
        "github.com/Vandebron/town-steering/blob/main/docs/domains-and-urls-we-use-at-vandebron.md"
        #:name "URLs and Domains @ Vandebron")
       (url
        "vandebron.atlassian.net/wiki/spaces/DIG/pages/95583079858182/Gewoon+Spring+explained+DRAFT"
        #:name "Gewoon Spring")))

(define work-tickets-dir
  (dir "Tickets"
       (url "vandebron.atlassian.net/browse/PT-986"
            #:name "Epic: Cohort 2: Termination Fee")))

(define work-dir
  (dir "Work"
       (url "app.slack.com/client/T1XNW2SF5/C08UHE7KM99"
            #:name "Slack")
       (url "vandebron.atlassian.net/jira/software/c/projects/PT/boards/1493"
            #:name "Sprint Payments")
       (url "portal.vdbinfra.nl"
            #:name "Backstage Portal")
       (url
        "github.com/Vandebron/onboarding/blob/main/onboarding/setup-internal-registries.md"
        #:name "Onboarding VDB")
       (url "pact-broker.serv-scw-backend.vdbinfra.nl"
            #:name "Pact Broker")
       (url
        "ecedo-test.vdbinfra.nl/swagger/ui/#!/SysAdvancePayments/SysAdvancePayments_Get_MostRecent"
        #:name "Ecedo Swagger")
       (url "sonarcloud.io/projects"
            #:name "SonarQube")
       (url
        "sites.google.com/vandebron.nl/wiki-people-and-culture/people-topics/wellbeing-personal-growth#h.wkj5f3k9gbrr"
        #:name "People&Culture")
       (dir "GraphQL"
            (url "the-guild.dev/graphql/tools/docs/mocking"
                 #:name "Mocking GraphQL"))
       (url
        "vandebron.atlassian.net/wiki/spaces/DIG/pages/95582464311304/Support+hero"
        #:name "Support Hero")
       (url "app.sendgrid.com"
            #:name "SendGrid")
       (url "keepersecurity.eu/vault/#"
            #:name "Keeper Vault")
       (url
        "github.com/pulls?q=is%3Aopen+is%3Apr+label%3Arenovate+team-review-requested%3AVandebron%2Fteam-payments"
        #:name "Dependency Update PRs")
       (url "github.com/Vandebron/kricket"
            #:name "Kricket - Kotlin Reference Implementation")
       (url "api.vandebron-kraken.systems/v1/graphql/#query=&variables="
            #:name "Kraken GraphQL Playground")
       (url "mijn-pr-51.test.vdbinfra.nl/financieel"
            #:name "PR51 Mijn Vandebron")
       (url
        "vandebron.atlassian.net/wiki/spaces/DIG/pages/95583078514695/Backend+Stack+Payments+-+Gewoon+Spring"
        #:name "Backend Stack @ Payments - Gewoon Spring")
       work-tickets-dir
       work-documents-dir
       (map (lambda (k)
              (dir (format #f "Ops ~a" k)
                   (url (format #f "grafana.~a-backend.vdbinfra.nl" k)
                        #:name (format #f "Grafana ~a" k))
                   (url (format #f "argocd.~a-backend.vdbinfra.nl" k)
                        #:name (format #f "ArgoCD ~a" k))
                   (url (format #f "dbgate-ms.~a-backend.vdbinfra.nl" k)
                        #:name (format #f "DBGate MS ~a" k))
                   (url (format #f "docs.~a.vandebron.dev" k)
                        #:name (format #f "API Catalog ~a" k))))
            '(prod test acce))))

(define social-dir
  (dir "Social"
       (url "web.whatsapp.com"
            #:name "WhatsApp")
       (url "mastodon.social"
            #:name "Mastodon")))

(define utils-dir
  (dir "Utils"
       (url "my.1password.com/home"
            #:name "1Password")))

(define lisp-dir
  (dir "Lisp"
       (url "racket-stories.com"
            #:name "Racket Stories")
       (url "andreashohmann.com/guile-exceptions"
            #:name "Guile Exceptions")))

(define joe-bookmarks
  (list jointhefreeworld-dir
        work-dir
        dev-dir
        lisp-dir
        emacs-dir
        social-dir
        torrents-dir
        utils-dir))

(define lenkesamler-bookmarks
  joe-bookmarks)

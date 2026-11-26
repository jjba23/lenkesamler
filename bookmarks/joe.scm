;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (lenkesamler bookmarks)
  #:declarative? #t
  #:use-module (lenkesamler prelude))

;;; Josep's bookmarks: the Chrome bookmark bar, sorted by hand into the folders it
;;; should have had -- Chrome's own JSON is not a format this project imports --
;;; next to the communities and projects worth keeping with them.

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
            #:name "Doom Emacs screenshots")
       (url "orgmode.org/"
            #:name "Org mode")
       (url "magit.vc/"
            #:name "Magit")
       (url "sachachua.com/blog/"
            #:name "Sacha Chua")
       (url "protesilaos.com/"
            #:name "Protesilaos")))

(define lisp-dir
  (dir "Lisp"
       (url "jeko.frama.io/"
            #:name "Guile Hacker Handbook"
            #:added "2026-07-12")
       (url "codeberg.org/ZelphirKaltstahl/guile-awesome/src/branch/main/list.md"
            #:name "guile-awesome"
            #:added "2026-09-26")
       (url "guix.gnu.org/manual/1.5.0/en/html_node/Invoking-guix-pack.html"
            #:name "guix pack"
            #:added "2026-07-12")
       (url "raw.githubusercontent.com/spk121/guile-gi/refs/heads/master/docs/Enums-and-Flags.html"
            #:name "Guile-GI Enums and Flags"
            #:added "2026-07-29")
       (url "racket-stories.com"
            #:name "Racket Stories")
       (url "andreashohmann.com/guile-exceptions"
            #:name "Guile Exceptions")
       (url "archive.softwareheritage.org"
            #:name "Software Heritage"
            #:added "2026-09-23")
       (url "github.com/OrangeShark/guile-commonmark"
            #:name "guile-commonmark")
       (url "github.com/opencog/guile-dbi"
            #:name "guile-dbi")
       (url "github.com/joshwalters/guile-pipe"
            #:name "guile-pipe")
       (url "github.com/ufo5260987423/scheme-langserver"
            #:name "Scheme language server")
       (url "github.com/cloudstreet-dev/Lisp-in-2025"
            #:name "Lisp in 2025")
       (url "github.com/Robert-van-Engelen/tinylisp"
            #:name "tinylisp")
       (url "github.com/lisper004/replos"
            #:name "REPL OS")
       (url "github.com/jank-lang/jank"
            #:name "jank")
       (url
        "www.iankduncan.com/engineering/2026-02-09-what-functional-programmers-get-wrong-about-systems"
        #:name "What functional programmers get wrong about systems"
        #:added "2026-03-20")))

(define tools-dir
  (dir "Tools"
       (url "dprint.dev/overview/"
            #:name "dprint"
            #:added "2026-11-21")
       (url "flathub.org/en/apps/io.github.aandrew_me.ytdn"
            #:name "ytDownloader"
            #:added "2026-08-25")
       (url "gitlab.com/metsatron/dotfiles/-/blob/master/all/.config/maak/maak.scm"
            #:name "Metsatron's maak.scm"
            #:added "2026-06-14")
       (url "github.com/topgrade-rs/topgrade"
            #:name "topgrade")
       (url "github.com/checkmake/checkmake"
            #:name "checkmake")
       (url "github.com/EbodShojaei/bake"
            #:name "bake")))

(define forge-dir
  (dir "Forge"
       (url "github.com/jjba23"
            #:name "GitHub"
            #:added "2026-10-26")
       (url "github.com/jjba23?tab=repositories"
            #:name "Your Repositories"
            #:added "2026-10-28")
       (url "github.com/jjba23/nixpkgs"
            #:name "jjba23/nixpkgs"
            #:added "2026-10-22")
       (url "github.com/orgs/jjba23-project-graveyard/repositories"
            #:name "Project Graveyard"
            #:added "2026-11-21")
       (url "codeberg.org/jjba23"
            #:name "Codeberg"
            #:added "2025-01-22"
            #:tags '(dev))
       (url "status.codeberg.org/status/codeberg"
            #:name "Codeberg Status"
            #:added "2026-10-11")
       (url "salsa.debian.org"
            #:name "Debian Salsa"
            #:added "2026-08-13")
       (url "build.opensuse.org/project/show/home:jjba23"
            #:name "OBS home:jjba23"
            #:added "2026-08-19")
       (url "openbuildservice.org/help/manuals/obs-user-guide/art-obs-bg"
            #:name "OBS Beginner's Guide"
            #:added "2026-08-20")
       (url "build.opensuse.org/request/show/1376192"
            #:name "lambdock OBS Request"
            #:added "2026-09-07")
       (url "sr.ht/"
            #:name "SourceHut")))

(define linux-dir
  (dir "Linux"
       (url "github.com/niri-wm/niri/pull/4105"
            #:name "niri: ignore-opacity"
            #:added "2026-09-06")
       (url "niri-wm.github.io/niri/"
            #:name "niri")
       (url "swaywm.org/"
            #:name "Sway")
       (url "wayland.freedesktop.org/"
            #:name "Wayland")
       (url "github.com/rcalixte/awesome-wayland"
            #:name "awesome-wayland")
       (url "gtk.org/"
            #:name "GTK")
       (url "www.gnome.org/"
            #:name "GNOME")))

(define virtualization-dir
  (dir "Virtualization"
       (url "github.com/kholia/osx-kvm"
            #:name "OSX-KVM"
            #:added "2026-08-17")
       (url "revsuine.xyz/blog/windows_11_vm/"
            #:name "Windows 11 on KVM"
            #:added "2026-08-17")
       (url "docs.darwinkvm.com/"
            #:name "DarwinKVM"
            #:added "2026-08-23")
       (url "dortania.github.io/OpenCore-Install-Guide/"
            #:name "OpenCore Install Guide")
       (url "github.com/OttoMeister/Win-KVM-Qemu-Linux"
            #:name "Windows 11 on QEMU/KVM")))

(define ai-dir
  (dir "AI"
       (url "www.deepseek.com/en/"
            #:name "DeepSeek"
            #:added "2026-10-19")
       (url "platform.deepseek.com/usage"
            #:name "DeepSeek Platform"
            #:added "2026-10-19")
       (url "eca.dev/workflows/"
            #:name "ECA Workflows"
            #:added "2026-11-25")
       (url "freebuff.com/"
            #:name "Freebuff"
            #:added "2026-10-10")
       (url "www.cubic.dev/dashboard"
            #:name "cubic"
            #:added "2026-11-02")))

(define web-dir
  (dir "Web"
       (url "specification.website/"
            #:name "The Website Specification"
            #:added "2026-06-02")
       (url "ladybird.org/"
            #:name "Ladybird"
            #:added "2026-11-25")
       (url "dbushell.com/2026/11/25/web-industry/"
            #:name "The year the web industry gave up"
            #:added "2026-11-25")
       (url "breck.lol/plMakers.html"
            #:name "The Language Makers Homepages"
            #:added "2026-08-16")))

(define type-dir
  (dir "Type"
       (url "juliamono.netlify.app/"
            #:name "JuliaMono"
            #:added "2026-11-02")
       (url "fonts.google.com/specimen/Work+Sans"
            #:name "Work Sans"
            #:added "2026-11-02")
       (url "fonts.google.com/specimen/Source+Serif+4"
            #:name "Source Serif 4"
            #:added "2026-11-02")
       (url "github.com/tywr/Nordwand-Mono"
            #:name "Nordwand Mono")
       (url "github.com/sayyadirfanali/Myna"
            #:name "Myna")))

(define dev-dir
  (dir "Dev"
       lisp-dir
       tools-dir
       forge-dir
       linux-dir
       virtualization-dir
       ai-dir
       web-dir
       type-dir))

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
            #:name "Hygguile")
       (url "grafana.jointhefreeworld.org/dashboards"
            #:name "Grafana"
            #:added "2026-10-20")
       (dir "Zulip"
            (url "jointhefreeworld.zulipchat.com/"
                 #:name "Inbox"
                 #:added "2026-09-08")
            (url "jointhefreeworld.zulipchat.com/#narrow/channel/632484-lambdock"
                 #:name "#lambdock"
                 #:added "2026-09-08")
            (url "jointhefreeworld.zulipchat.com/#narrow/channel/632494-maak"
                 #:name "#maak"
                 #:added "2026-09-08"))))

(define music-dir
  (dir "Music"
       (url "rmpc.mierak.dev/overview/"
            #:name "rmpc"
            #:added "2026-09-02")
       (url "common-good.codeberg.page/awesome-mpd/"
            #:name "Awesome MPD"
            #:added "2026-08-31")
       (url "icecast.org/docs/icecast-2.4.0/auth.html"
            #:name "Icecast Authentication"
            #:added "2026-09-18")
       (url "naurissteins.com/kwybars"
            #:name "Kwybars"
            #:added "2026-08-14")
       (url "github.com/mpdel/mpdel"
            #:name "MPDel")))

(define torrents-dir
  (dir "Torrents"
       (url "www.limetorrents.to"
            #:name "LimeTorrents")
       (url "torrentgalaxy-official.is"
            #:name "TorrentGalaxy")
       (url "rargb.to/"
            #:name "RARBG"
            #:added "2026-07-05")
       (url "piratebayproxy.info/"
            #:name "Pirate Bay Proxy"
            #:added "2026-08-16")
       (url "rutracker.org/forum/index.php"
            #:name "RuTracker"
            #:added "2026-08-26")))

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
            '(prod test acce))
       (dir "GraphQL"
            (url "the-guild.dev/graphql/tools/docs/mocking"
                 #:name "Mocking GraphQL"))))

(define communities-dir
  (dir "Communities"
       (dir "Hacker"
            (url "news.ycombinator.com/"
                 #:name "Hacker News")
            (url "lobste.rs/"
                 #:name "Lobsters")
            (url "hackaday.com/"
                 #:name "Hackaday")
            (url "phrack.org/"
                 #:name "Phrack")
            (url "www.2600.com/"
                 #:name "2600")
            (url "defcon.org/"
                 #:name "DEF CON")
            (url "www.ccc.de/"
                 #:name "Chaos Computer Club")
            (url "ctftime.org/"
                 #:name "CTFtime")
            (url "overthewire.org/wargames/"
                 #:name "OverTheWire")
            (url "picoctf.org/"
                 #:name "picoCTF")
            (url "tryhackme.com/"
                 #:name "TryHackMe")
            (url "www.hackthebox.com/"
                 #:name "Hack The Box")
            (url "www.exploit-db.com/"
                 #:name "Exploit-DB")
            (url "www.reddit.com/r/netsec/"
                 #:name "r/netsec")
            (url "www.reddit.com/r/ReverseEngineering/"
                 #:name "r/ReverseEngineering")
            (url "www.reddit.com/r/hacking/"
                 #:name "r/hacking")
            (url "www.reddit.com/r/cybersecurity/"
                 #:name "r/cybersecurity"))
       (dir "Lisp"
            (url "www.reddit.com/r/scheme/"
                 #:name "r/scheme")
            (url "www.reddit.com/r/lisp/"
                 #:name "r/lisp")
            (url "planet.scheme.org/"
                 #:name "Planet Scheme")
            (url "srfi.schemers.org/"
                 #:name "SRFI")
            (url "lists.gnu.org/mailman/listinfo/guile-user"
                 #:name "guile-user mailing list")
            (url "web.libera.chat/?channels=%23guile"
                 #:name "#guile on Libera")
            (url "web.libera.chat/?channels=%23scheme"
                 #:name "#scheme on Libera"))
       (dir "Nix & Guix"
            (url "guix.gnu.org/"
                 #:name "GNU Guix")
            (url "guix.gnu.org/manual/en/html_node/"
                 #:name "Guix Manual")
            (url "nixos.org/"
                 #:name "NixOS")
            (url "nix.dev/"
                 #:name "nix.dev")
            (url "discourse.nixos.org/"
                 #:name "NixOS Discourse")
            (url "www.reddit.com/r/guix/"
                 #:name "r/GUIX")
            (url "www.reddit.com/r/NixOS/"
                 #:name "r/NixOS"))
       (dir "Emacs"
            (url "www.reddit.com/r/emacs/"
                 #:name "r/emacs")
            (url "emacs.stackexchange.com/"
                 #:name "Emacs Stack Exchange")
            (url "systemcrafters.net/"
                 #:name "System Crafters"))
       (dir "Linux"
            (url "www.reddit.com/r/linux/"
                 #:name "r/linux")
            (url "www.reddit.com/r/linuxquestions/"
                 #:name "r/linuxquestions")
            (url "www.reddit.com/r/unixporn/"
                 #:name "r/unixporn")
            (url "www.reddit.com/r/wayland/"
                 #:name "r/wayland")
            (url "www.reddit.com/r/rust/"
                 #:name "r/rust")
            (url "www.reddit.com/r/selfhosted/"
                 #:name "r/selfhosted")
            (url "www.reddit.com/r/homelab/"
                 #:name "r/homelab")
            (url "www.reddit.com/r/programming/"
                 #:name "r/programming"))))

(define projects-dir
  (dir "Projects"
       (url "github.com/jjba23/maak"
            #:name "maak")
       (url "github.com/jjba23/lenkesamler"
            #:name "lenkesamler")
       (url "github.com/jjba23/whelk"
            #:name "whelk")
       (url "github.com/jjba23/lambdock"
            #:name "lambdock")
       (url "github.com/jjba23/scriba"
            #:name "scriba")
       (url "github.com/jjba23/sift"
            #:name "sift")
       (url "github.com/jjba23/olive-css"
            #:name "olive-css")
       (url "github.com/jjba23/hygguile"
            #:name "hygguile")
       (url "github.com/jjba23/veritas"
            #:name "veritas")
       (url "github.com/jjba23/wolk-jjba"
            #:name "wolk-jjba")
       (url "github.com/jjba23/heks-linux"
            #:name "heks-linux")
       (url "github.com/jjba23/guix-jointhefreeworld"
            #:name "guix-jointhefreeworld")
       (url "github.com/jjba23/nix-jointhefreeworld"
            #:name "nix-jointhefreeworld")
       (url "github.com/jjba23/wikimusic"
            #:name "wikimusic")
       (url "github.com/jjba23/lucidplan"
            #:name "lucidplan")
       (url "github.com/jjba23/byggsteg"
            #:name "byggsteg")
       (url "github.com/jjba23/guile-dokgen"
            #:name "guile-dokgen")
       (url "github.com/jjba23/ggg"
            #:name "ggg")
       (url "github.com/jjba23/orgwebalchemy"
            #:name "orgwebalchemy")
       (url "github.com/jjba23/kracht"
            #:name "kracht")))

(define career-dir
  (dir "Career"
       (url "www.reddit.com/r/EngineeringResumes/wiki/index/"
            #:name "r/EngineeringResumes wiki"
            #:added "2026-07-17")
       (url "www.nicksingh.com/posts/36-resume-rules-for-software-engineers"
            #:name "36 Resume Rules for Software Engineers"
            #:added "2026-07-17")
       (url "github.com/AH-Human-Resources/backend-Josep-Bigorra"
            #:name "AH Backend Assignment"
            #:added "2026-07-27")
       (url "www.pitchhut.com/my-projects"
            #:name "PitchHut"
            #:added "2026-11-13")
       (url "github.com/jjba23/iter-vitae"
            #:name "iter-vitae")))

(define personal-dir
  (dir "Personal"
       (url "www.topotijdreis.nl/"
            #:name "Topotijdreis"
            #:added "2026-06-29")
       (url "www.samsung.com/nl/smartphones/galaxy-a/galaxy-a57-5g-awesome-navy-256gb-sm-a576bdbdeub/"
            #:name "Galaxy A57 5G"
            #:added "2026-07-01")
       (url "www.amazon.nl/dp/B0G7W2WVKT"
            #:name "Dexnor Galaxy A57 case"
            #:added "2026-07-01")
       (url
        "www.rabobank.nl/particulieren/beleggen/rabo-zelf-beleggen/waarin-beleggen/obligaties/staatsobligaties"
        #:name "Rabobank: staatsobligaties"
        #:added "2026-08-28")
       (url "www.asnbank.nl/online/mijn-product-openen/?productId=ASNGespreidbeleggen"
            #:name "ASN Gespreid Beleggen"
            #:added "2026-08-28")
       (url "account.proton.me/vpn"
            #:name "Proton VPN"
            #:added "2026-09-22")
       (url "www.brennenstuhl.nl/nl-NL/producten"
            #:name "Brennenstuhl"
            #:added "2026-11-15")
       (url "www.allekabels.nl/230_volt/stekkerdoos/overspanningsbeveiliging.html"
            #:name "Overspanningsbeveiligde stekkerdoos"
            #:added "2026-11-15")
       (url "naaiwijzer.nl/brother-hf37-mechanische-naaimachine-37-patronen/"
            #:name "Brother HF37 naaimachine"
            #:added "2026-11-19")
       (url "www.hofilpenstein.nl/"
            #:name "Hof Ilpenstein"
            #:added "2026-11-22")
       (url
        "www.cultura.gob.es/cultura/areas/archivos/mc/archivos/nhn/destacados/jovenes-genealogistas.html"
        #:name "Archivo Histórico de la Nobleza"
        #:added "2026-09-26")))

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

(define joe-bookmarks
  (list jointhefreeworld-dir
        work-dir
        dev-dir
        projects-dir
        emacs-dir
        communities-dir
        music-dir
        torrents-dir
        games-dir
        career-dir
        personal-dir
        social-dir
        utils-dir))

(define lenkesamler-bookmarks
  joe-bookmarks)

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

(define-module (maak)
  #:use-module (maak maak)
  #:declarative? #t)

;; ====== Maak constants ======

;; The path to the directory where the main project files will be deployed.
(define deploy-dir
  "/srv/http/jointhefreeworld.org")

;; The URL for the CSS stylesheet used to style API documentation.
(define api-docs-css-url
  "https://jointhefreeworld.org/static/css/jointhefreeworld.css")

(define project-name
  'lenkesamler)

(define hot-reload-file-types
  '(scm))

;; ====== Maak tasks ======

(define (help)
  "Display program help screen."
  (time-machine-program-shell '("lenkesamler --help")))

(define (default)
  "Default task to run, call program's help."
  (list-tasks))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")
     #:verbose? #t))

(define (repl)
  "Development REPL."
  (manifest-shell '("guile -L ./src"
                    "-c '((@ (ares server) run-nrepl-server))'")))

(define (test)
  "Run the project's test suite.

The specs live under test/veritas/unit, which is where the runner looks for a
suite -- the test root ./test, the module prefix `veritas' and the suite name
`unit' -- and it is also what their own `(veritas unit ...)' module names
resolve to on the load path below, next to this project's own sources.

The run names the locale it reads in instead of inheriting one, and names it
before the runner is asked: Guile reads a page by the locale in force, and this
suite reads documents that hold more than ASCII -- a bookmark named `R&D', a
title in another script.  `C.UTF-8' is that name for a machine that has never
generated a locale, which is what a container, a service and this project's own
continuous integration are.  The suite sets the clock it reads dates by itself,
so the machine's timezone is not a part of the reading.

The specs are compiled every run rather than read from a cache.  A compiled
spec outlives the library it was compiled against -- Guile decides a compiled
file is still good by the spec's own text, and not by the macros that text was
compiled with -- so a spec compiled before `(veritas veritas)' changed shape is
loaded afterwards as if it still had the old one, which reads as a failure
inside this project.  Compiling from source costs a few seconds and makes the
reading depend on the specs alone, which is what a suite run to judge a change
has to be."
  (time-machine-manifest-shell
   (list "guile --fresh-auto-compile -L ./src -L . -L ./test"
         "-c '(begin (setlocale LC_ALL \"C.UTF-8\") (use-modules (veritas runner)) (run-tests))'")))

(define (docs)
  "Generate technical API documentation for Maak."
  (delete-file-recursively "doc")
  (time-machine-manifest-shell (list (~ "documenta api ./src/~a && "
                                        project-name)
                                     (~ "texi2any -v --html --css-ref=~a"
                                        api-docs-css-url)
                                     "./doc/api/index.texi"))
  (mv "./index" "./doc/api-dist"))

(define (deploy)
  (docs)
  ;; Deploy API docs
  (remkdir-p (~ "~a/api-docs/~a" deploy-dir project-name))
  (mv "doc/api-dist/*"
      (~ "~a/api-docs/~a" deploy-dir project-name))
  (delete-file-recursively "doc"))

(define (package-docker)
  "Create a Docker image for Iter Vitae."
  (time-machine-manifest-shell '("guix pack --file=./guix.scm"
                                 "--format=docker" "--image-tag=lenkesamler"
                                 "-S /bin=bin"
                                 "bash coreutils util-linux-with-udev guile")))

(define (dev-run* bookmarks-file)
  (time-machine-manifest-shell (list
                                "guile -L ./src -c '((@(lenkesamler main) main))'"
                                (~
                                 "--file /home/joe/Hacking/lenkesamler/bookmarks/~a.scm"
                                 bookmarks-file)
                                "--destination ./bookmarks-export.html")
                               #:verbose? #t))

(define (run* bookmarks-file)
  (time-machine-program-shell (list (~ "lenkesamler --file ./bookmarks/~a.scm"
                                     bookmarks-file)
                                    "--destination ./bookmarks-export.html")
                              #:verbose? #t))

(define (run)
  "Run lenkesamler."
  (run* 'joe))

(define (dev-run)
  "Run lenkesamler (dev)."
  (dev-run* 'joe))

(define (hot-reload)
  "Hot-reloading developer's setup."
  (time-machine-manifest-shell (list "watchexec"
                                     "--clear"
                                     (~ "--exts ~a"
                                        (string-join (map symbol->string
                                                      hot-reload-file-types)
                                                     ","))
                                     "--on-busy-update=restart"
                                     "--shell bash"
                                     "--watch . --"
                                     "maak run")))

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (dev)
  "Developer's setup."
  (hot-reload))

;; ====== Container tasks ======

(define (container-build)
  "Build the container image for lenkesamler."
  ($ '("podman build -t lenkesamler .")))

(define (container-run)
  "Run the container image for lenkesamler."
  ($ '("podman run --rm -it lenkesamler:latest")))

;; lenkesamler
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(use-modules (guix gexp)
             (guix packages)
             (guix git-download)
             ((guix licenses)
              #:prefix license:)
             (guix build-system guile)
             ((guix build utils)
              #:select (with-directory-excursion wrap-program))
             (gnu packages)
             (gnu packages bash)
             (gnu packages guile)
             (gnu packages guile-xyz)
             (gnu packages tls))

(define %source-dir
  (dirname (current-filename)))

(define-public lenkesamler
  (package
    (name "lenkesamler")
    (version "dev")
    (source
     (local-file %source-dir
                 #:recursive? #t
                 #:select? (git-predicate %source-dir)))
    (arguments
     `(#:source-directory "src"
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'install-program-files
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (share (string-append out "/share"))
                    (program (string-append bin "/lenkesamler")))
               (install-file "resources/help.txt"
                             (string-append share "/resources/"))
               (install-file "scripts/lenkesamler" bin)
               (install-file "scripts/log.bash"
                             (string-append share "/scripts/"))
               (chmod program #o755)
               ;; The wrapper hands Guile this project's own sources and
               ;; nothing else, which is enough for the standard library and
               ;; not for guile-json: a run that writes JSON, or reads a
               ;; browser's file, needs the propagated inputs on the load path
               ;; too.  `guix shell -f guix.scm -- lenkesamler' puts the
               ;; package's own output on the command line, rather than behind
               ;; the profile the wrapper would otherwise read its paths from,
               ;; so say where they are.
               (let ((json (assoc-ref inputs "guile-json"))
                     (tls (assoc-ref inputs "guile-gnutls")))
                 (when json
                   (wrap-program program
                     `("GUILE_LOAD_PATH" ":" prefix
                       (,(string-append json "/share/guile/site/3.0")
                        ,(string-append tls "/share/guile/site/3.0")))
                     `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                       (,(string-append out "/lib/guile/3.0/site-ccache")
                        ,(string-append json
                                        "/lib/guile/3.0/site-ccache")
                        ,(string-append tls
                                        "/lib/guile/3.0/site-ccache"))))))))))))

    (build-system guile-build-system)
    (native-inputs (list guile-3.0))
    ;; A check of a bookmarks file asks https addresses, and Guile's web client
    ;; asks GnuTLS to do it: the bindings are loaded at run time, from the load
    ;; path, so an installed lenkesamler has to carry them where Guile looks.
    (propagated-inputs (list guile-json-4 guile-gnutls))
    (inputs (list guile-3.0 bash-minimal gnutls))
    (synopsis "")
    (description "")
    (home-page "https://codeberg.org/jjba23/lenkesamler")
    (license license:expat)))

lenkesamler

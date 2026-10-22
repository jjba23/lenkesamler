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

(use-modules (guix packages)
             (gnu)
             (guix utils)
             (guix git-download)
             (guix download)
             (gnu packages guile)
             (gnu packages nss)
             (gnu packages admin)
             (gnu packages web)
             (gnu packages gnupg)
             (gnu packages guile-xyz)
             (gnu packages pkg-config)
             (guix build-system guile)
             (gnu packages linux)
             (gnu packages compression)
             (gnu packages texinfo)
             (gnu packages rust-apps)
             (gnu packages autotools)
             (gnu packages build-tools)
             ((guix licenses)
              #:prefix license:))

;; The framework the test suite is written in.  It is defined here rather than
;; taken from the pinned channel so that a run of the suite is judged by the
;; framework this project names, in one place, wherever it runs.
(define-public guile-veritas
  (package
    (name "guile-veritas")
    (version "0.8.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/veritas.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1cpc4cnm5aac8528s8b5wslcbxq0kdf7ya9y5rm6alv1h154pj47"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"))
    (native-inputs (list guile-3.0))
    (propagated-inputs (list guile-fibers guile-json-4))
    (home-page "https://codeberg.org/jjba23/veritas")
    (synopsis "Testing framework for Guile")
    (description
     "Veritas is a testing framework for Guile with an embedded domain-specific
language to define test suites.  Emphasis is placed on legible, maintainable
tests.  Veritas shuffles tests and runs them concurrently by default.")
    (license license:lgpl3+)))

(packages->manifest (list maak
                          guile-3.0-latest
                          guile-json-4
                          guile-veritas
                          watchexec
                          texinfo
                          guile-documenta
                          guile-ares-rs))


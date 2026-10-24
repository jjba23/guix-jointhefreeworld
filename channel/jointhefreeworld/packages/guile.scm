;;; guile.scm --- Guile libraries from the jointhefreeworld collection.

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; This file is part of guix-jointhefreeworld.
;;
;; guix-jointhefreeworld is free software: you can redistribute it and/or
;; modify it under the terms of the GNU Affero General Public License as
;; published by the Free Software Foundation, either version 3 of the License,
;; or (at your option) any later version.
;;
;; guix-jointhefreeworld is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero
;; General Public License for more details.
;;
;; You should have received a copy of the GNU Affero General Public License
;; along with guix-jointhefreeworld.  If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; These are the libraries a jointhefreeworld program is assembled from: a
;; prelude, structured logging, testing, authentication tokens, web components,
;; an Org parser, an OpenAPI generator and a CSS generator.  The order below is
;; the order of that stack, from the general to the particular.
;;
;;; Code:

(define-module (jointhefreeworld packages guile)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system guile)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages guile)
  #:use-module ((gnu packages guile-xyz)
                #:hide (guile-kracht guile-hygguile
                        guile-bewaking guile-veritas))
  #:export (guile-kracht
            guile-scriba
            guile-veritas
            guile-bewaking
            guile-hygguile
            guile-orgwebalchemy
            guile-openapi-generator
            guile-olive-css))

(define-public guile-kracht
  (package
    (name "guile-kracht")
    (version "0.3.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/kracht.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1c3zxb681ffn3ddzpx8bqvvz3llsr8c6x3pj7g49qc7p5c6qfhyy"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (home-page "https://codeberg.org/jjba23/kracht")
    (synopsis "Opt-in prelude that enhances Guile's standard library")
    (description
     "Kracht (Dutch for power, and a recursive acronym for \"KRACHT Reliable And
Consistent Helper Tools\") is a prelude for Guile Scheme: an opt-in set of
procedures for lists, strings, I/O, SQL and HTML that a program can import
without forking the language's standard library.")
    (license license:lgpl3+)))

(define-public guile-scriba
  (package
    (name "guile-scriba")
    (version "0.4.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/scriba.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1r6b2dscn4xnw9ry1d4b0g7jfhc8z0p5pmx0n18b2c90lrnn7mfm"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-json-4))
    (home-page "https://codeberg.org/jjba23/scriba")
    (synopsis "Structured logging framework for Guile Scheme")
    (description
     "Scriba is a structured logging library for GNU Guile.  It provides modular
log routing, formatting and filtering: human-readable console logs during
development, machine-readable JSON logs in production, and rotating plaintext
logs on disk.  It includes an auto-logger configured through environment
variables, dynamically scoped log contexts and ahead-of-time level filtering.")
    (license license:lgpl3+)))

(define-public guile-veritas
  (package
    (name "guile-veritas")
    (version "0.8.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/veritas.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1c371ab8grh9q1idypavl56rniyl9ycddr7x8fljcq6p7v8ijnk3"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-fibers
           guile-json-4))
    (home-page "https://codeberg.org/jjba23/veritas")
    (synopsis "Testing framework for Guile")
    (description
     "Veritas is a testing framework for Guile with an embedded domain-specific
language for defining test suites.  Emphasis is placed on legible, maintainable
tests: Veritas shuffles them and runs them concurrently by default, and reports
failures with the values that produced them.")
    (license license:lgpl3+)))

(define-public guile-bewaking
  (package
    (name "guile-bewaking")
    (version "0.4.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/bewaking.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0l5knqx2bdvlizyrgd1162v43b8smdlrns8q7zr65rz9acm0gk9l"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-gcrypt
           guile-uuid))
    (home-page "https://codeberg.org/jjba23/bewaking")
    (synopsis "Authentication and authorization tokens for Guile Scheme")
    (description
     "Bewaking creates and verifies lifetime-limited, encrypted digital
credentials that carry information securely.  Tokens are protected through
multiple layers of cryptography and obfuscation, producing secure tokens usable
as web session cookies or as authenticating API calls.")
    (license license:lgpl3+)))

(define-public guile-hygguile
  (package
    (name "guile-hygguile")
    (version "2.7.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/hygguile.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1qs6fn0c32aqs6s693gc638zvkwx55f2kwgkifwv1bkm9sknw3b4"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-uuid))
    (home-page "https://codeberg.org/jjba23/hygguile")
    (synopsis "Web UI component library for Guile Scheme projects")
    (description
     "Hygguile creates cozy, professional and accessible web user interfaces
from Guile Scheme.  It defines an expressive domain-specific language over
S-expressions and SXML, and ships components whose names resemble their HTML
counterparts, easing the learning curve and reducing cognitive load.")
    (license license:lgpl3+)))

(define-public guile-orgwebalchemy
  (package
    (name "guile-orgwebalchemy")
    (version "1.2.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/orgwebalchemy.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "11mvqs3j7zl9fm0gb1g35956b2cjl5j24dxx0907ax4jvdrsnz1f"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (home-page "https://codeberg.org/jjba23/orgwebalchemy")
    (synopsis "Org mode to HTML and Markdown converter for Guile Scheme")
    (description
     "Orgwebalchemy parses Org mode documents with a Parsing Expression Grammar
and renders them as HTML or Markdown.  It is the Org exporter behind the
jointhefreeworld web applications: headings, lists, tables, source blocks,
links and the usual Org furniture are read by one grammar and written by two
renderers.")
    (license license:lgpl3+)))

(define-public guile-openapi-generator
  (package
    (name "guile-openapi-generator")
    (version "0.0.7")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/guile-openapi-generator.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1nqnlnh192bhvs0fijh5sgfj0250cnqz3a4qddgdkvldydqlx6w3"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-json-4
           guile-curl))
    (home-page "https://codeberg.org/jjba23/guile-openapi-generator")
    (synopsis "OpenAPI 3 to Guile Scheme code generator")
    (description
     "guile-openapi-generator reads OpenAPI 3.x specifications written in YAML or
JSON and generates Guile Scheme code: validated record data models, controllers
(plain Guile or Artanis) and HTTP clients (plain Guile or libcurl), including
support for polymorphism, enumerations, JSON merge patch and the security
schemes described by the specification.")
    (license license:agpl3+)))

(define-public guile-olive-css
  (package
    (name "guile-olive-css")
    (version "0.6.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/olive-css.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "004414jd1cxka0nzmmmc33xr56c8vv7y7p7mchy12k7ml8lp6cfq"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-resources
            (lambda _
              (copy-recursively
               "resources"
               (string-append #$output "/share/olive-css/resources")))))))
    (native-inputs
     (list guile-3.0))
    (home-page "https://codeberg.org/jjba23/olive-css")
    (synopsis "Utility-class CSS framework written in Guile Scheme")
    (description
     "Olive CSS generates a utility-class stylesheet from S-expressions.  Every
declaration is a Scheme value rather than a string, the stylesheet is produced
by the library, and the tree shaker keeps only the rules whose classes appear
in a directory of built HTML.  Prebuilt stylesheets for the jointhefreeworld
projects are installed under share/olive-css/resources/css.")
    (license license:lgpl3+)))

;;; guile.scm --- Guile libraries from the jointhefreeworld collection.

;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
  ;; Only the bindings this module uses are imported: `#:hide' would name the
  ;; packages this channel shadows, and a name upstream drops - `guile-kracht'
  ;; left `(gnu packages guile-xyz)' in the Guix of 2026-11-24 - turns the whole
  ;; channel into "no binding `guile-kracht' to hide".  A `#:select' makes the
  ;; upstream copies invisible without naming them, so a package moving in or out
  ;; of Guix cannot stop the channel from loading.
  #:use-module ((gnu packages guile-xyz)
                #:select (guile-fibers guile-uuid))
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
    (version "0.4.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/kracht.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0disfg5hzaal1zv64ia7s5aick43q9j4ma14j8igzazbrakjnz65"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (home-page "https://github.com/jjba23/kracht")
    (synopsis "Opt-in prelude that enhances Guile's standard library")
    (description
     "Kracht (Dutch for power, and a recursive acronym for \"KRACHT Reliable And
Consistent Helper Tools\") is a prelude for Guile Scheme: an opt-in set of
procedures for lists, strings, I/O, SQL and HTML that a program can import
without forking the language's standard library.")
    (license license:expat)))

(define-public guile-scriba
  (package
    (name "guile-scriba")
    (version "1.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/scriba.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1b8axhxjdxm4nypfhbzyj12cklmraahqw9kj85jqz2699jykzd1r"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-json-4))
    (home-page "https://github.com/jjba23/scriba")
    (synopsis "Structured logging framework for Guile Scheme")
    (description
     "Scriba is a structured logging library for GNU Guile.  It provides modular
log routing, formatting and filtering: human-readable console logs during
development, machine-readable JSON logs in production, and rotating plaintext
logs on disk.  It includes an auto-logger configured through environment
variables, dynamically scoped log contexts and ahead-of-time level filtering.")
    (license license:expat)))

(define-public guile-veritas
  (package
    (name "guile-veritas")
    (version "1.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/veritas.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1lb80y2dks68a2jlr5xix9m8pyqnzwiqiaynbl05p463xxhzs0v7"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-fibers
           guile-json-4))
    (home-page "https://github.com/jjba23/veritas")
    (synopsis "Testing framework for Guile")
    (description
     "Veritas is a testing framework for Guile with an embedded domain-specific
language for defining test suites.  Emphasis is placed on legible, maintainable
tests: Veritas shuffles them and runs them concurrently by default, and reports
failures with the values that produced them.")
    (license license:expat)))

(define-public guile-bewaking
  (package
    (name "guile-bewaking")
    (version "0.5.12")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/bewaking.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dv1hgcwnci0x10zln3p6bybxmsf2vhsw989lyyzyaf0wmprfzj7"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-gcrypt
           guile-uuid))
    (home-page "https://github.com/jjba23/bewaking")
    (synopsis "Authentication and authorization tokens for Guile Scheme")
    (description
     "Bewaking creates and verifies lifetime-limited, encrypted digital
credentials that carry information securely.  Tokens are protected through
multiple layers of cryptography and obfuscation, producing secure tokens usable
as web session cookies or as authenticating API calls.")
    (license license:expat)))

(define-public guile-hygguile
  (package
    (name "guile-hygguile")
    (version "2.8.11")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/hygguile.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1jj2xdi9j1kmzpfllvrgrv4539z9avlzykqhiyppfjzjdmh4np15"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-uuid))
    (home-page "https://github.com/jjba23/hygguile")
    (synopsis "Web UI component library for Guile Scheme projects")
    (description
     "Hygguile creates cozy, professional and accessible web user interfaces
from Guile Scheme.  It defines an expressive domain-specific language over
S-expressions and SXML, and ships components whose names resemble their HTML
counterparts, easing the learning curve and reducing cognitive load.")
    (license license:expat)))

(define-public guile-orgwebalchemy
  (package
    (name "guile-orgwebalchemy")
    (version "1.3.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/orgwebalchemy.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "01zmllnlxh5wmdmnmvv35dylppa782bjmy2shijl85s6n39dixal"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (home-page "https://github.com/jjba23/orgwebalchemy")
    (synopsis "Org mode to HTML and Markdown converter for Guile Scheme")
    (description
     "Orgwebalchemy parses Org mode documents with a Parsing Expression Grammar
and renders them as HTML, Markdown, JSON or SXML.  It is the Org exporter behind
the jointhefreeworld web applications: headings, lists, tables, source blocks,
links and the usual Org furniture are read by one grammar and written by three
renderers, and the tree itself can be handed to another language as JSON.")
    (license license:expat)))

(define-public guile-openapi-generator
  (package
    (name "guile-openapi-generator")
    (version "0.1.10")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/guile-openapi-generator.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0mip5rgz5pnhs49yiwyigz3aqqrfjn8jxhlzq0a441l95h9dqlj0"))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "src"))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-json-4
           guile-curl))
    (home-page "https://github.com/jjba23/guile-openapi-generator")
    (synopsis "OpenAPI 3 to Guile Scheme code generator")
    (description
     "guile-openapi-generator reads OpenAPI 3.x specifications written in YAML or
JSON and generates Guile Scheme code: validated record data models, controllers
(plain Guile or Artanis) and HTTP clients (plain Guile or libcurl), including
support for polymorphism, enumerations, JSON merge patch and the security
schemes described by the specification.")
    (license license:expat)))

(define-public guile-olive-css
  (package
    (name "guile-olive-css")
    (version "2.0.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/olive-css.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0qk4dqlr1xkhqnfryxrrzfmq53p3g9yah22nin21ivpfgdyb8bs8"))))
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
    (home-page "https://github.com/jjba23/olive-css")
    (synopsis "Utility-class CSS framework written in Guile Scheme")
    (description
     "Olive CSS generates a utility-class stylesheet from S-expressions.  Every
declaration is a Scheme value rather than a string, the stylesheet is produced
by the library, and the tree shaker keeps only the rules whose classes appear
in a directory of built HTML.  Prebuilt stylesheets for the jointhefreeworld
projects are installed under share/olive-css/resources/css.")
    (license license:expat)))

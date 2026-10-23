;;; applications.scm --- Guile programs from the jointhefreeworld collection.

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
;; The command-line programs.  Each is a Guile library plus a bash launcher, so
;; each definition installs the launcher and the data it reads, then wraps the
;; launcher with the Guile and the libraries it needs.
;;
;;; Code:

(define-module (jointhefreeworld packages applications)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system guile)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages guile)
  #:use-module ((gnu packages guile-xyz)
                #:hide (guile-kracht guile-hygguile
                        guile-bewaking guile-veritas))
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages tls)
  #:use-module (jointhefreeworld packages guile)
  #:export (maak
            ggg
            iter-vitae
            lenkesamler
            consceal
            skapa
            araneola
            mutastructura
            cask-and-cons
            guile-carvoeiro-water-fun))

(define-public maak
  (package
    (name "maak")
    (version "0.12.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/maak.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1yfj2w9wik5zy8pysh55yna6v2bq9wx5fs1zrqffdmsk6qr2icl1"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (share (string-append #$output "/share")))
                (install-file "scripts/maak" bin)
                (chmod (string-append bin "/maak") #o755)
                (copy-recursively "resources"
                                  (string-append share "/resources"))
                (install-file "man/maak.1"
                              (string-append share "/man/man1")))))
          (add-after 'install-documentation 'install-completions
            (lambda _
              (let ((bash (string-append
                           #$output "/share/bash-completion/completions"))
                    (fish (string-append
                           #$output "/share/fish/vendor_completions.d"))
                    (zsh (string-append
                          #$output "/share/zsh/site-functions")))
                (mkdir-p bash)
                (install-file "scripts/maak-completion.bash" bash)
                (mkdir-p fish)
                (copy-file "scripts/maak-completion.fish"
                           (string-append fish "/maak.fish"))
                (mkdir-p zsh)
                (copy-file "scripts/maak-completion.zsh"
                           (string-append zsh "/_maak")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let ((wrapper (string-append #$output "/bin/maak")))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append
                       #$output "/lib/guile/3.0/site-ccache"))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           util-linux))
    (home-page "https://codeberg.org/jjba23/maak")
    (synopsis "Command runner à la Make using Guile Scheme")
    (description
     "Maak is a command runner and control plane for projects.  It lets you use
the power of Lisp (Guile Scheme) to define tasks, build steps and other
automation, calling external shell commands and integrating with existing
scripts and tools.  It is inspired by GNU Make but does away with much of the
complexity that comes with its history.")
    (license license:gpl3+)))

(define-public ggg
  (package
    (name "ggg")
    (version "0.16.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/ggg.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1xb5n0vrj2l1srsh0d7rhy3g581f2ng83y3gf3mc9wh6pbizlkk8"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (install-file "scripts/ggg" bin)
                (chmod (string-append bin "/ggg") #o755)
                (copy-recursively
                 "resources"
                 (string-append #$output "/share/ggg/resources")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let ((wrapper (string-append #$output "/bin/ggg")))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")
                     ,(string-append #$imagemagick "/bin")))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append
                       #$output "/lib/guile/3.0/site-ccache"))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           imagemagick
           util-linux))
    (home-page "https://codeberg.org/jjba23/ggg")
    (synopsis "SVG badge and glyph generator written in Guile Scheme")
    (description
     "GGG (Guile Glyph Generator) generates pretty SVG images and badges for
projects: the technologies they use, the projects they appreciate, the versions
they support and the sponsors they thank.  It reads Scheme files in which the
glyphs are declared, supports badges of one to three parts, and renders SVG
from S-expressions, producing pixel-perfect output.")
    (license license:agpl3+)))

(define-public iter-vitae
  (package
    (name "iter-vitae")
    (version "1.0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/iter-vitae.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0d05v2qjpp2c63c2ycz8i21gmn5p2ybw8qq9hs27dyh2c0z1f161"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (share (string-append #$output "/share")))
                (install-file "scripts/iter-vitae" bin)
                (chmod (string-append bin "/iter-vitae") #o755)
                (install-file "resources/help.txt"
                              (string-append share "/resources"))
                (copy-recursively "resources/css"
                                  (string-append share "/resources/css")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let ((wrapper (string-append #$output "/bin/iter-vitae")))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append
                       #$output "/lib/guile/3.0/site-ccache"))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           util-linux))
    (home-page "https://codeberg.org/jjba23/iter-vitae")
    (synopsis "Curriculum vitae generator written in Guile Scheme")
    (description
     "Iter Vitae generates a résumé or curriculum vitae from an S-expression
description of its owner.  It separates the data from the presentation, the way
a model-view-controller application does, and writes a web-site version of the
document with SXML and Olive CSS.  It is designed for long-term use, so a CV can
be updated and evolved over the years, and it supports multilingual content.")
    (license license:agpl3+)))

(define-public lenkesamler
  (package
    (name "lenkesamler")
    (version "0.0.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/lenkesamler.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "05nk2jrciqqqr5dm63xac4h48rwd82kh710wxn53hdlv2g9wffny"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (share (string-append #$output "/share")))
                (install-file "scripts/lenkesamler" bin)
                (chmod (string-append bin "/lenkesamler") #o755)
                (install-file "resources/help.txt"
                              (string-append share "/resources"))
                (install-file "scripts/log.bash"
                              (string-append share "/scripts")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let* ((wrapper (string-append #$output "/bin/lenkesamler"))
                     (dependencies (list #$guile-json-4
                                         #$guile-gnutls)))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")
                     ,@(map (lambda (dependency)
                              (string-append dependency "/bin"))
                            dependencies)))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/share/guile/site/3.0"))
                            dependencies)))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append #$output
                                     "/lib/guile/3.0/site-ccache")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/lib/guile/3.0/site-ccache"))
                            dependencies))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           gnutls
           util-linux))
    (propagated-inputs
     (list guile-gnutls
           guile-json-4))
    (home-page "https://codeberg.org/jjba23/lenkesamler")
    (synopsis "Bookmark collector and converter written in Guile Scheme")
    (description
     "Lenkesamler (Norwegian for \"link collector\") gathers, checks and converts
bookmarks.  It reads the bookmark files browsers write, verifies the addresses
they contain, and emits the same collection as HTML, JSON, Markdown, Org or a
Netscape bookmarks file.")
    (license license:agpl3+)))

(define-public consceal
  (package
    (name "consceal")
    (version "0.0.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/consceal.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1hy1rkn9hmwbryh92mvb764iipafkpbrcfbc0zx9lf4s486py6zv"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (share (string-append #$output "/share")))
                (install-file "scripts/consceal" bin)
                (chmod (string-append bin "/consceal") #o755)
                (install-file "resources/help.txt"
                              (string-append share "/resources"))
                (install-file "scripts/log.bash"
                              (string-append share "/scripts")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let* ((wrapper (string-append #$output "/bin/consceal"))
                     (dependencies (list #$guile-bewaking
                                         #$guile-kracht
                                         #$guile-uuid)))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")
                     ,@(map (lambda (dependency)
                              (string-append dependency "/bin"))
                            dependencies)))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/share/guile/site/3.0"))
                            dependencies)))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append #$output
                                     "/lib/guile/3.0/site-ccache")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/lib/guile/3.0/site-ccache"))
                            dependencies))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           util-linux))
    (propagated-inputs
     (list guile-bewaking
           guile-kracht
           guile-uuid))
    (home-page "https://codeberg.org/jjba23/consceal")
    (synopsis "Secret manager and deployer written in Guile Scheme")
    (description
     "Consceal manages and deploys secrets with the power of Lisp.  Secrets are
kept encrypted, and a deployment writes them where the program that needs them
expects to find them, so that a repository can describe its secrets without
ever holding them in the clear.")
    (license license:gpl3+)))

(define-public skapa
  (package
    (name "skapa")
    (version "0.0.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/skapa.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1fy6mdi6s0jxkxzcl5s5df7jny23iz42ikrj1bv5wyzjf2irg5j9"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (install-file "scripts/skapa" bin)
                (chmod (string-append bin "/skapa") #o755)
                (copy-recursively
                 "resources"
                 (string-append #$output "/share/resources")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let* ((wrapper (string-append #$output "/bin/skapa"))
                     (dependencies (list #$guile-scriba
                                         #$guile-json-4)))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")
                     ,@(map (lambda (dependency)
                              (string-append dependency "/bin"))
                            dependencies)))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/share/guile/site/3.0"))
                            dependencies)))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append #$output
                                     "/lib/guile/3.0/site-ccache")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/lib/guile/3.0/site-ccache"))
                            dependencies))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           util-linux))
    (propagated-inputs
     (list guile-scriba
           guile-json-4))
    (home-page "https://codeberg.org/jjba23/skapa")
    (synopsis "Interactive project scaffolder written in Guile Scheme")
    (description
     "Skapa (Swedish for \"create\") is a command-line wizard that scaffolds a new
project.  It asks the questions a project has to answer -- its name, its
language, its licence -- and writes the files that follow from the answers from
a template system that a project can extend.")
    (license license:gpl3+)))

(define-public araneola
  (package
    (name "araneola")
    (version "0.0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/araneola.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0w39dlxh8i11f1bw7m777y35lwjjdm3hqwbvamjwnby7kn7fixnx"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (share (string-append #$output "/share")))
                (install-file "scripts/araneola" bin)
                (chmod (string-append bin "/araneola") #o755)
                (install-file "resources/help.txt"
                              (string-append share "/resources"))
                (install-file "scripts/log.bash"
                              (string-append share "/scripts")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let* ((wrapper (string-append #$output "/bin/araneola"))
                     (dependencies (list #$guile-scriba
                                         #$guile-json-4
                                         #$guile-lib
                                         #$guile-gnutls)))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")
                     ,@(map (lambda (dependency)
                              (string-append dependency "/bin"))
                            dependencies)))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/share/guile/site/3.0"))
                            dependencies)))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append #$output
                                     "/lib/guile/3.0/site-ccache")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/lib/guile/3.0/site-ccache"))
                            dependencies))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           gnutls
           util-linux))
    (propagated-inputs
     (list guile-gnutls
           guile-json-4
           guile-lib
           guile-scriba))
    (home-page "https://codeberg.org/jjba23/araneola")
    (synopsis "Static site crawler and link checker written in Guile Scheme")
    (description
     "Araneola (a small spider) crawls a web site, reads its pages, and reports
what it finds: broken links, missing pages, duplicate addresses and the shape
of the site as a crawler sees it.  It can also write a sitemap and a robots
file from what it found.")
    (license license:agpl3+)))

(define-public mutastructura
  (package
    (name "mutastructura")
    (version "0.9.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/mutastructura.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "12qjy0pgwd2l3vxxx99pgb0i2hana5py4ll6x4lqlmd3vidz2y6p"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (install-file "scripts/mutastructura" bin)
                (chmod (string-append bin "/mutastructura") #o755)
                (copy-recursively
                 "resources"
                 (string-append #$output "/share/resources")))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let* ((wrapper (string-append #$output "/bin/mutastructura"))
                     (dependencies (list #$guile-dbi
                                         #$guile-dbd-mysql
                                         #$guile-dbd-sqlite3
                                         #$guile-dbd-postgresql
                                         #$guile-gcrypt)))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")
                     ,@(map (lambda (dependency)
                              (string-append dependency "/bin"))
                            dependencies)))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/share/guile/site/3.0"))
                            dependencies)))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append #$output
                                     "/lib/guile/3.0/site-ccache")
                     ,@(map (lambda (dependency)
                              (string-append dependency
                                             "/lib/guile/3.0/site-ccache"))
                            dependencies)))
                  `("GUILE_DBD_PATH" ":" prefix
                    (,@(map (lambda (dependency)
                              (string-append dependency "/lib"))
                            dependencies))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           util-linux))
    (propagated-inputs
     (list guile-dbi
           guile-dbd-mysql
           guile-dbd-sqlite3
           guile-dbd-postgresql
           guile-gcrypt))
    (home-page "https://codeberg.org/jjba23/mutastructura")
    (synopsis "Relational database schema migrations powered by Guile Scheme")
    (description
     "Mutastructura provides a familiar, declarative and transactional approach
to managing database states, with a command-line interface and library
functions for PostgreSQL, MySQL and SQLite.  Migrations run transactionally and
are recorded with a SHA-256 checksum in a migrations_history table, which is
what makes a migration safe to run again.")
    (license license:agpl3+)))

(define-public cask-and-cons
  (package
    (name "cask-and-cons")
    (version "0.1.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/cask-and-cons.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "18c87qrls14v81jywy6d1sijr0xqjjinyvc82cd31jkayw797z3x"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (data (string-append
                           #$output "/share/guile/site/3.0/cask-and-cons")))
                (install-file "caco" bin)
                (chmod (string-append bin "/caco") #o755)
                (install-file "src/cask-and-cons/omniwm-settings.toml" data)
                (install-file "src/cask-and-cons/shell-lib.zsh" data)
                (install-file "src/cask-and-cons/lesskey" data))))
          (add-before 'build 'patch-data-lookup
            (lambda _
              ;; zsh.scm looks for its data beside the module and, failing
              ;; that, under ./src.  Installed, the data is beside the
              ;; installed modules, which is what %search-load-path reads.
              (substitute* "src/cask-and-cons/zsh.scm"
                (("\\(format #f \"src/cask-and-cons/~a\" name\\)")
                 (string-append
                  "(or (%search-load-path (format #f \"cask-and-cons/~a\" name))\n"
                  "                      (format #f \"src/cask-and-cons/~a\" name))")))))
          (add-after 'install-documentation 'install-launcher
            (lambda _
              ;; The checkout's launcher adds ./src to the load path, which is
              ;; right in the checkout and wrong in the store.  The installed
              ;; launcher lets the wrapper's GUILE_LOAD_PATH do that job.
              (let ((launcher (string-append #$output "/bin/caco")))
                (call-with-output-file launcher
                  (lambda (port)
                    (format port
                            "#!~a/bin/bash~%exec guile -c '((@ (cask-and-cons main) main) (command-line))' \"$@\"~%"
                            #$bash-minimal)))
                (chmod launcher #o755))))
          (add-after 'patch-shebangs 'wrap-program
            (lambda _
              (let ((wrapper (string-append #$output "/bin/caco")))
                (wrap-program wrapper
                  #:sh (string-append #$bash-minimal "/bin/bash")
                  `("PATH" ":" prefix
                    (,(string-append #$guile-3.0 "/bin")
                     ,(string-append #$bash-minimal "/bin")
                     ,(string-append #$coreutils-minimal "/bin")
                     ,(string-append #$util-linux "/bin")))
                  `("GUILE_LOAD_PATH" ":" prefix
                    (,(string-append #$output "/share/guile/site/3.0")))
                  `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                    (,(string-append
                       #$output "/lib/guile/3.0/site-ccache"))))))))))
    (native-inputs
     (list guile-3.0))
    (inputs
     (list bash-minimal
           coreutils-minimal
           util-linux))
    (home-page "https://codeberg.org/jjba23/cask-and-cons")
    (synopsis "Desktop setup tasks from a Cask and Cons file")
    (description
     "Cask and Cons collects the repetitive chores of setting up and maintaining
a desktop -- installing a tool, pointing a program at a configuration, keeping
two machines in step -- into one command with named tasks.  The tasks are
written in Guile Scheme, so a task can be a value computed from the machine it
runs on rather than a script that assumes the answer.")
    (license license:gpl3+)))

(define-public guile-carvoeiro-water-fun
  (package
    (name "guile-carvoeiro-water-fun")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/carvoeiro-water-fun.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1rvnl5dncvvc4gjvwppkyxinjsva42kmz7w0dw1slqkj81wxmdn3"))))
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
               (string-append
                #$output "/share/carvoeiro-water-fun/resources")))))))
    (native-inputs
     (list guile-3.0))
    (propagated-inputs
     (list guile-hygguile
           guile-kracht))
    (home-page "https://codeberg.org/jjba23/carvoeiro-water-fun")
    (synopsis "Small multilingual web site generator written in Guile Scheme")
    (description
     "Carvoeiro Water Fun builds the web site of the event it is named after: a
handful of pages in English and Portuguese, generated from Scheme values into
SXML and HTML.  It is included here as the library it is, with its CSS, images,
scripts and translation files installed under share/carvoeiro-water-fun, so that
a checkout of the site can build without fetching its own copy of them.")
    (license license:agpl3+)))

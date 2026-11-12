;;; emacs.scm --- Emacs packages from the jointhefreeworld collection.

;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; Emacs is where the Lisp in these projects is written, and four of the
;; projects extend Emacs itself.  Each is a single file, so the build system
;; needs no arguments beyond the source.
;;
;;; Code:

(define-module (jointhefreeworld packages emacs)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (emacs-maak
            emacs-modusregel
            emacs-veritas
            emacs-welkomscherm
            emacs-tekengrootte))

(define-public emacs-maak
  (package
    (name "emacs-maak")
    (version "0.9.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/maak.el.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1hr4rbn9764alwrr0z6k8gfn1apvfxxx4fy55jjqzm6sjmf4hq4b"))))
    (build-system emacs-build-system)
    (arguments
     (list #:tests? #f))
    (home-page "https://codeberg.org/jjba23/maak.el")
    (synopsis "Run Maak tasks from Emacs")
    (description
     "maak.el integrates the Maak command runner into Emacs.  It discovers the
maak.scm of the project a buffer belongs to, reads the tasks that file exports
and the lambda list each one declares, and runs one from the minibuffer with
its arguments gathered and prompted for.  Completion shows each task with its
signature and docstring, so the answer to \"what can this project do?\" is one
command away.")
    (license license:gpl3+)))

(define-public emacs-modusregel
  (package
    (name "emacs-modusregel")
    (version "0.9.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/modusregel.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0j6fk931kak44jla7hm77p8p55bm4a9x7nz9xib20zf1vkypr3p8"))))
    (build-system emacs-build-system)
    (arguments
     (list #:tests? #f))
    (home-page "https://github.com/jjba23/modusregel")
    (synopsis "Clean and fast mode line for Emacs")
    (description
     "Modusregel (Dutch for \"mode line\") is a mode line built with
customization, beauty and performance in mind.  It reports unsaved, read-only,
narrowed and remote buffers only when there is something to report, prettifies
major mode names including their tree-sitter variants, shows Eglot and Flymake
counters, and aligns the same way in a graphical frame and in a terminal.")
    (license license:gpl3+)))

(define-public emacs-veritas
  (package
    (name "emacs-veritas")
    (version "0.2.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/veritas.el.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "17bqpfnamzfpwc93mr1vl398yjkvgb9bs56s4gc4ar5jg0wap0hc"))))
    (build-system emacs-build-system)
    (arguments
     (list #:tests? #f))
    (home-page "https://github.com/jjba23/veritas.el")
    (synopsis "Emacs integration for the Veritas test framework")
    (description
     "veritas.el teaches Emacs the vocabulary of the Veritas test framework:
suites, tests, benchmarks, scenarios, BDD steps and assertions are fontified,
indexed with Imenu and reported in the mode line.  It runs them from the
project, the current file, the test at point or the suite at point, and shows
the result in a compilation buffer whose entries jump back to the line that
failed.")
    (license license:lgpl3+)))

(define-public emacs-welkomscherm
  (package
    (name "emacs-welkomscherm")
    (version "1.5.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/welkomscherm.el.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "03frqgls74kvpz821sclp72rwk5xjf7s3hazrfvykgxxsjvkndsb"))))
    (build-system emacs-build-system)
    (arguments
     (list #:tests? #f))
    (home-page "https://github.com/jjba23/welkomscherm.el")
    (synopsis "Quiet welcome screen and dashboard for Emacs")
    (description
     "Welkomscherm (Dutch for \"welcome screen\") is a calm dashboard for the
start of an Emacs session: a centred handful of lines, the links its owner
chose, and nothing that gets in the way.  It looks the same in a graphical
frame and in a terminal, it works on any Emacs from 28.1 upwards, and it asks
nothing of the editor that Emacs does not already provide.")
    (license license:expat)))

(define-public emacs-tekengrootte
  (package
    (name "emacs-tekengrootte")
    (version "0.4.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/tekengrootte.el.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0vp5k0arq5nh4ari587cw4qrzji26raqzc42lri48m2plc71yb9a"))))
    (build-system emacs-build-system)
    (arguments
     (list #:tests? #f))
    (home-page "https://github.com/jjba23/tekengrootte.el")
    (synopsis "Proportionally scaled face sizes for Emacs")
    (description
     "Tekengrootte (Dutch for \"character size\") replaces hard-coded face
heights with multiples of one adjustable scale: a face is declared to be 1.3
times the scale, and changing the scale resizes every face declared that way.
The scale itself is named rather than numbered, from nano to colossal, so a
configuration says how large a heading should be relative to the text around
it rather than how many points it should occupy.")
    (license license:gpl3+)))

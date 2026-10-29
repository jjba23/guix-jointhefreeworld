;;; site.scm --- the jointhefreeworld web site builder.

;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; jointhefreeworld is a program as much as a web site: its build script reads
;; the Org sources of a checkout and writes the HTML beside them.  The package
;; below installs the build script and the Emacs packages it loads, and provides
;; a command that runs it in the directory it is called from.  The checkout is
;; therefore the input, and its ./public directory is the output.
;;
;; The build script installs its Emacs packages from MELPA when it cannot find
;; them.  A package cannot reach the network at build time and must not, so the
;; three forms that would do so are neutralised here, and the packages are
;; supplied as inputs instead.
;;
;;; Code:

(define-module (jointhefreeworld packages site)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages web)
  #:export (jointhefreeworld))

(define-public jointhefreeworld
  (package
    (name "jointhefreeworld")
    (version "1.0.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/jointhefreeworld.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1yba3gslhs9xflzc71s39jnpn50f1hylfm1nxdvwf3v2yxzk5jbs"))))
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let* ((out #$output)
                 (share (string-append out "/share/jointhefreeworld"))
                 (bin (string-append out "/bin"))
                 (site (string-append share "/jointhefreeworld-site.el"))
                 (roots (string-append #$emacs-no-x " "
                                       #$emacs-esxml " "
                                       #$emacs-htmlize " "
                                       #$emacs-webfeeder " "
                                       #$emacs-use-package " "
                                       #$emacs-haskell-mode " "
                                       #$emacs-rust-mode " "
                                       #$emacs-kotlin-mode)))
            (mkdir-p share)
            (copy-file (string-append #$source "/jointhefreeworld-site.el")
                       site)
            (substitute* site
              ;; The packages come from the inputs, not from MELPA.
              (("\\(package-refresh-contents\\)") "nil")
              (("\\(package-install 'use-package\\)") "nil")
              ((":ensure t") ":ensure nil")
              ((":pin \"melpa-stable\"") ""))
            (call-with-output-file (string-append share "/build.el")
              (lambda (port)
                (format port
                        ";; Load the autoloads the Emacs packages installed beside~%\
;; their sources, the way package-initialize would.~%\
(let ((dirs (split-string (or (getenv \"EMACSLOADPATH\") \"\") \":\" t)))~%\
  (dolist (dir dirs)~%\
    (dolist (file (directory-files dir t \"-autoloads\\\\.elc?\\\\'\" t))~%\
      (load file nil t))))~%\
(load ~s)~%\
(setq jfw/project-root (file-name-as-directory~%\
 (or (getenv \"JFW_PROJECT_ROOT\") default-directory)))~%\
(jfw/publish)~%"
                        site)))
            (mkdir-p bin)
            (call-with-output-file (string-append bin "/jointhefreeworld-build")
              (lambda (port)
                (format port
                        "#!~a/bin/bash
set -euo pipefail
export JFW_PROJECT_ROOT=\"$(pwd)\"
EMACSLOADPATH=
for root in ~a; do
  for dir in \"$root\"/share/emacs/site-lisp \"$root\"/share/emacs/site-lisp/*/; do
    if [ -d \"$dir\" ]; then
      EMACSLOADPATH=\"${dir%/}:$EMACSLOADPATH\"
    fi
  done
done
export EMACSLOADPATH
exec emacs -Q --batch -l ~a \"$@\"
"
                        #$bash-minimal roots
                        (string-append share "/build.el"))))
            (chmod (string-append bin "/jointhefreeworld-build") #o755)
            (call-with-output-file (string-append bin "/jointhefreeworld-serve")
              (lambda (port)
                (format port
                        "#!~a/bin/bash
set -euo pipefail
exec darkhttpd \"${1:-./public}\" --port \"${PORT:-50011}\"
"
                        #$bash-minimal)))
            (chmod (string-append bin "/jointhefreeworld-serve") #o755)
            (wrap-program (string-append bin "/jointhefreeworld-build")
              #:sh (string-append #$bash-minimal "/bin/bash")
              `("PATH" ":" prefix
                (,(string-append #$emacs-no-x "/bin")
                 ,(string-append #$librsvg "/bin")
                 ,(string-append #$git "/bin")
                 ,(string-append #$coreutils-minimal "/bin"))))
            (wrap-program (string-append bin "/jointhefreeworld-serve")
              #:sh (string-append #$bash-minimal "/bin/bash")
              `("PATH" ":" prefix
                (,(string-append #$darkhttpd "/bin")
                 ,(string-append #$coreutils-minimal "/bin"))))))))
    (inputs (list emacs-no-x
                  emacs-esxml
                  emacs-htmlize
                  emacs-webfeeder
                  emacs-use-package
                  emacs-haskell-mode
                  emacs-rust-mode
                  emacs-kotlin-mode
                  librsvg
                  font-dejavu
                  git
                  darkhttpd
                  bash-minimal
                  coreutils-minimal))
    (home-page "https://jointhefreeworld.org")
    (synopsis "Static web site built from Org mode with GNU Emacs")
    (description
     "jointhefreeworld is a web site and the program that builds it.  The
sources are Org mode files; one Emacs Lisp program exports them into a static
web site, wraps each page in the site's layout, draws a social card for every
article, writes the RSS feed, and copies the stylesheet, the scripts and the
images beside the result.  This package installs that program together with the
Emacs packages it uses, and provides @command{jointhefreeworld-build}, which
builds the checkout it is run from, and @command{jointhefreeworld-serve}, which
serves the result.")
    (license license:agpl3+)))

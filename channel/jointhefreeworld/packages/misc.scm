;;; misc.scm --- programs and libraries that do not fit the other modules.

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
;; A shell configuration written in Scheme and a dock written in C and GTK.
;; They share nothing but their author and their home on Codeberg, so each is
;; written out in the build system it actually uses.
;;
;;; Code:

(define-module (jointhefreeworld packages misc)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system guile)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages pkg-config)
  #:export (guile-heks-bash
            lambdock))

(define-public guile-heks-bash
  (package
    (name "guile-heks-bash")
    (version "1.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/heks-bash.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hq077d5q1k032pp1zs7wqr8df9930gaypib6zrmakrfbj2999fl"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-data-files
            (lambda _
              (let ((data (string-append
                           #$output "/share/guile/site/3.0/heks-bash")))
                (install-file "src/heks-bash/shell-lib.bash" data)
                (install-file "src/heks-bash/lesskey" data))))
          (add-before 'build 'patch-data-lookup
            (lambda _
              ;; bash.scm reads its shell library from beside the module and,
              ;; failing that, from ./src.  Installed, the data sits beside the
              ;; installed modules, which is what %search-load-path reads.
              (substitute* "src/heks-bash/bash.scm"
                (("\\(format #f \"src/heks-bash/~a\" name\\)")
                 (string-append
                  "(or (%search-load-path (format #f \"heks-bash/~a\" name))\n"
                  "                      (format #f \"src/heks-bash/~a\" name))"))))))))
    (native-inputs
     (list guile-3.0))
    (home-page "https://codeberg.org/jjba23/heks-bash")
    (synopsis "Bash configuration written in Guile Scheme")
    (description
     "Heks-bash is a declarative configuration for the Bourne Again Shell.  The
rc file is not edited by hand: it is generated from Scheme values that name the
prompt, the aliases, the functions and the integrations the machine should
have.  The generated configuration keeps the same prompt, palette and git
segment on every machine, with a per-machine sigil, accent and badge, and it
integrates ble.sh, fzf and direnv.")
    (license license:gpl3+)))

(define-public lambdock
  (package
    (name "lambdock")
    (version "0.7.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/lambdock.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1k6h6xyv71441h2bvv1vxmmaykcs833q8851qaa7rp1k7iwdm9hz"))))
    (build-system meson-build-system)
    (arguments
     (list #:parallel-build? #t
           #:parallel-tests? #t))
    (native-inputs
     (list (list glib "bin")
           pkg-config
           gettext-minimal))
    (inputs
     (list gtk
           gtk4-layer-shell
           guile-3.0
           wlr-protocols))
    (home-page "https://codeberg.org/jjba23/lambdock")
    (synopsis "Wayland desktop dock customizable with GNU Guile Scheme")
    (description
     "Lambdock is a Wayland-native desktop dock built with GTK4 and
gtk4-layer-shell.  It tracks windows through the Wayland foreign-toplevel
management protocol, themes itself with CSS, slides out of the edge it was
given, places itself on any monitor, and embeds a GNU Guile Scheme engine so
that its configuration can be changed while it runs, from a REPL, without a
restart.")
    (license license:gpl3+)))

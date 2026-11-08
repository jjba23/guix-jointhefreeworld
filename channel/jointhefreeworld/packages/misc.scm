;;; misc.scm --- programs and libraries that do not fit the other modules.

;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; A shell configuration written in Scheme, a dock written in C and GTK, and
;; the window that shows the desktop's own keyboard reference, wallpapers and
;; palettes.  They share nothing but their author, so each is written out in
;; the build system it actually uses.
;;
;;; Code:

(define-module (jointhefreeworld packages misc)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system guile)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages pkg-config)
  #:export (guile-heks-bash
            lambdock
            heks-toon))

(define-public guile-heks-bash
  (package
    (name "guile-heks-bash")
    (version "2.0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/heks-bash.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1zaslbl3sz6v7c3kphlwzgrd8na09ybxxvr9ki6hgbkb8hhk946q"))))
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
                (install-file "src/heks-bash/notes.bash" data)
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
    (home-page "https://github.com/jjba23/heks-bash")
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
    (version "1.2.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/lambdock.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "175ss41rjy02dyihvz4gx61k4a14jyf53h6y228ipzbzsmwbj3gh"))))
    (build-system meson-build-system)
    (arguments
     ;; The wrap-glib-or-gtk phase points GSETTINGS_SCHEMA_DIR and
     ;; GIO_EXTRA_MODULES at this closure, which is what lets the dock read the
     ;; desktop's icon theme (and so resolve the icons of the running apps)
     ;; instead of falling back to Adwaita.
     (list #:glib-or-gtk? #t
           #:parallel-build? #t
           #:parallel-tests? #t))
    (native-inputs
     (list (list glib "bin")
           pkg-config
           gettext-minimal))
    (inputs
     (list gtk
           gtk4-layer-shell
           guile-3.0
           wlr-protocols
           dconf
           gsettings-desktop-schemas
           shared-mime-info
           hicolor-icon-theme))
    (home-page "https://github.com/jjba23/lambdock")
    (synopsis "Wayland desktop dock customizable with GNU Guile Scheme")
    (description
     "Lambdock is a Wayland-native desktop dock built with GTK4 and
gtk4-layer-shell.  It tracks windows through the Wayland foreign-toplevel
management protocol, themes itself with CSS, slides out of the edge it was
given, places itself on any monitor, and embeds a GNU Guile Scheme engine so
that its configuration can be changed while it runs, from a REPL, without a
restart.")
    (license license:expat)))

(define-public heks-toon
  (package
    (name "heks-toon")
    (version "0.3.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/heks-toon.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0liyw6pvxjlhqiqzyjgxzhrvi99g1k5klqspbln0lr5gjs3cxp5g"))))
    (build-system meson-build-system)
    (arguments
     (list #:glib-or-gtk? #t
           #:parallel-build? #t
           #:parallel-tests? #t))
    (native-inputs
     (list (list glib "bin")
           pkg-config))
    (inputs
     (list gdk-pixbuf
           gtk
           guile-3.0))
    (home-page "https://codeberg.org/jjba23/heks-toon")
    (synopsis "Keyboard reference, wallpapers and palettes of Heks GNU/Linux")
    (description
     "heks-toon is one GTK4 window with five views: the keyboard reference of a
Heks GNU/Linux desktop, the wallpaper collection with a large preview, the
palette chooser, the projects' own documentation, and their reconfigure tasks.

The window is painted from the palette the desktop is wearing - a blurred mesh of
the palette's colours behind translucent panes, with grain over it - and its
contents, colours and commands all come from an embedded GNU Guile Scheme
engine.")
    (license license:gpl3+)))

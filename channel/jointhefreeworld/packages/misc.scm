;;; misc.scm --- programs and libraries that do not fit the other modules.

;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; A shell configuration written in Scheme, a dock written in C and GTK, the
;; desktop shell those two belong to, and the window that shows the desktop's
;; own keyboard reference, wallpapers and palettes.  They share nothing but their author, so each is written out in
;; the build system it actually uses.
;;
;;; Code:

(define-module (jointhefreeworld packages misc)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (gnu packages commencement)
  #:use-module (guix build-system guile)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages commencement)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages xorg)
  #:export (guile-heks-bash
            lambdock
            whelk
            heks-toon))

(define-public guile-heks-bash
  (package
    (name "guile-heks-bash")
    (version "2.1.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/heks-bash.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0cifknx8z19aivi0z08qhz68ckdnap99nchkgfrcgxdh0790qd5r"))))
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
    (version "2.0.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/lambdock.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0cifknx8z19aivi0z08qhz68ckdnap99nchkgfrcgxdh0790qd5r"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     ;; The wrap-glib-or-gtk phase points GSETTINGS_SCHEMA_DIR and
     ;; GIO_EXTRA_MODULES at this closure, which is what lets the dock read the
     ;; desktop's icon theme (and so resolve the icons of the running apps)
     ;; instead of falling back to Adwaita.
     (list #:parallel-build? #t
           ;; cargo builds and `cargo xtask' installs: the data files, the Scheme
           ;; modules and the compiled catalogues have no cargo target of their
           ;; own.
           #:phases #~(modify-phases %standard-phases
                      (delete 'configure)
                      (replace 'build
                        (lambda _
                          (invoke "cargo" "build" "--offline" "--locked"
                                  "--release")))
                      (replace 'check
                        (lambda* (#:key tests? #:allow-other-keys)
                          (when tests?
                            (invoke "cargo" "test" "--offline" "--locked"))))
                      (replace 'install
                        (lambda _
                          (invoke "cargo" "run" "--offline" "--locked"
                                  "-p" "xtask" "--" "install"
                                  "--prefix" #$output))))
           #:parallel-tests? #t))
    (native-inputs
     ;; `cargo` builds the crate and runs its display-free suite; `glib:bin' and
     ;; `wayland' bring `glib-compile-resources' and `wayland-scanner', which
     ;; `build.rs' runs to generate the resources and the protocol interfaces.
     ;; `gcc-toolchain` is what provides `cc` and `ar`: `build.rs` compiles the
     ;; generated resource bundle and protocol code, and Guix's implicit `gcc`
     ;; installs `gcc`, not those names.
     (list (list glib "bin")
           pkg-config
           gettext-minimal
           wayland
           rust
           (list rust "cargo")
           gcc-toolchain))
    (inputs
     (list gtk
           gtk4-layer-shell
           guile-3.0
           ;; The optional X11 backend: the build turns it on when it finds
           ;; gtk4-x11.pc, which needs libX11 in the environment.
           libx11
           wlr-protocols
           dconf
           gsettings-desktop-schemas
           shared-mime-info
           hicolor-icon-theme))
    (home-page "https://github.com/jjba23/lambdock")
    (synopsis "Desktop dock customizable with GNU Guile Scheme")
    (description
     "Lambdock is a desktop dock built with GTK4.  On Wayland it anchors itself
with gtk4-layer-shell and tracks windows through the foreign-toplevel management
protocol; on X11 it docks itself through EWMH and reserves its edge with a strut.
It themes itself with CSS, slides out of the edge it was given, places itself on
any monitor, and embeds a GNU Guile Scheme engine so that its configuration can
be changed while it runs, from a REPL, without a restart.")
    (license license:expat)))

(define-public whelk
  (package
    (name "whelk")
    (version "0.35.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/whelk.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "09cw5ksqvvpx1q36j3d42xqjpba3ydzk9l1smvs7cb458ka58idj"))))
    (build-system meson-build-system)
    (arguments
     ;; The wrap-glib-or-gtk phase points GSETTINGS_SCHEMA_DIR and
     ;; GIO_EXTRA_MODULES at this closure, which is what lets the bar and the
     ;; launcher resolve the desktop's icon theme instead of falling back to
     ;; Adwaita.
     (list #:glib-or-gtk? #t
           #:parallel-build? #t
           #:parallel-tests? #t))
    (native-inputs
     (list (list glib "bin")
           dbus ; the integration tests can start their own private bus
           pkg-config
           wayland ; provides wayland-scanner
           gcc-toolchain))
    (inputs
     ;; libx11 is what turns a bar into a dock with EWMH struts on an X11
     ;; desktop; without it whelk still builds and runs on Wayland alone.
     ;; linux-pam enables the screen locker; without it whelk still builds but
     ;; the locker fails closed.
     (list gtk
           gtk4-layer-shell
           guile-3.0
           libx11
           linux-pam))
    ;; whelk calls wtype by name for menu shortcuts and the optional keyboard
    ;; test path; keep it in the package's profile so a desktop launch sees it.
    (propagated-inputs
     (list wtype))
    (home-page "https://github.com/jjba23/whelk")
    (synopsis "Desktop shell for Wayland and X11, configured in GNU Guile Scheme")
    (description
     "Whelk is a desktop shell built with GTK4.  Its bars, modules, launcher,
notification centre and network panel are described in GNU Guile Scheme, and its
configuration can be changed while it runs, from a REPL, without a restart.
Bars are layer surfaces with an exclusive zone where wlr-layer-shell exists
(niri, sway); on an X11 desktop they are dock windows with EWMH struts; and on a
session with neither -- GNOME's Wayland session -- they degrade to ordinary
windows instead of failing.  The shell reads the focused window and the global
menu from niri's IPC, sway's IPC or EWMH, whichever the session provides.")
    (license license:expat)))

(define-public heks-toon
  (package
    (name "heks-toon")
    (version "0.3.9")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/heks-toon.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "00q5c404i49r0gafmxflsz3sc3lxc71nrpbnscan0hvhiq11m366"))))
    (build-system meson-build-system)
    (arguments
     (list #:glib-or-gtk? #t
           #:parallel-build? #t
           ;; cargo builds and `cargo xtask' installs: the data files, the Scheme
           ;; modules and the compiled catalogues have no cargo target of their
           ;; own.
           #:phases #~(modify-phases %standard-phases
                      (delete 'configure)
                      (replace 'build
                        (lambda _
                          (invoke "cargo" "build" "--offline" "--locked"
                                  "--release")))
                      (replace 'check
                        (lambda* (#:key tests? #:allow-other-keys)
                          (when tests?
                            (invoke "cargo" "test" "--offline" "--locked"))))
                      (replace 'install
                        (lambda _
                          (invoke "cargo" "run" "--offline" "--locked"
                                  "-p" "xtask" "--" "install"
                                  "--prefix" #$output))))
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

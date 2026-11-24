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
  #:use-module (gnu packages audio)
  #:use-module (gnu packages curl)
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
    (version "2.2.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/heks-bash.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "15780snhsqwmxy6qfmwfsx7ahb4gsijqy9kyajp7nx0axd5amqa3"))))
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
    (license license:expat)))

(define-public lambdock
  (package
    (name "lambdock")
    (version "2.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jjba23/lambdock.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "076nyscw3ivpgyjmfg0wf1ramj7v59f5fmayr7mmg178qjvawanl"))))
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
                            ;; Compiled in: the dock finds its Scheme modules and
                            ;; its catalogues by path, not through a wrapper, so a
                            ;; build that leaves these unset produces a binary that
                            ;; only runs from the source tree.
                            (setenv "LAMBDOCK_SCHEME_DIR"
                                    (string-append #$output
                                                   "/share/guile/site/3.0"))
                            (setenv "LAMBDOCK_LOCALEDIR"
                                    (string-append #$output "/share/locale"))
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
     ;;
     ;; The rust here has to be at least 1.92: gtk4-rs 0.11 declares that as its
     ;; MSRV, and cargo refuses an older toolchain instead of trying. A Guix
     ;; revision that still ships rust 1.85 stops in the build phase with
     ;; "gtk4-sys@0.11.5 requires rustc 1.92" -- that is the pin, not this file,
     ;; so build the package with a newer `--channels` rather than patching it.
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
        (version "0.52.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/jjba23/whelk.git")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0srx9k8g0nzjjpldzc7g1r9igb9ripv3sdl2rx79vxzpsxsx328m"))))
    ;; The crate graph is vendored in the source, so the build runs cargo
    ;; offline and has no crate inputs to resolve.  cargo xtask install is
    ;; what puts the Scheme modules, desktop entry and icons beside the
    ;; binary; a plain cargo install would leave an installed whelk without
    ;; the files its prefix fallback looks for.
    (build-system glib-or-gtk-build-system)
    (arguments
     ;; The wrap-glib-or-gtk phase points GSETTINGS_SCHEMA_DIR and
     ;; GIO_EXTRA_MODULES at this closure, which is what lets the bar and the
     ;; launcher resolve the desktop's icon theme instead of falling back to
     ;; Adwaita.
     (list #:parallel-build? #t
           #:parallel-tests? #t
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               ;; Cargo verifies the checksum of every vendored file.  Patching
               ;; a shebang inside rust/vendor would therefore invalidate the
               ;; vendor tree before the build starts; none of those scripts is
               ;; installed or used by the crate build.
               (delete 'patch-source-shebangs)
               (delete 'patch-generated-file-shebangs)
               (replace 'build
                 (lambda _
                   (invoke "cargo" "build" "--workspace" "--locked"
                           "--offline" "--release")))
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     ;; GTK tests need a display even when they never map a
                     ;; window, and GLib must not write to the build user's
                     ;; home.
                     (setenv "HOME" (getcwd))
                     (setenv "XDG_RUNTIME_DIR" (getcwd))
                     (setenv "GTK_A11Y" "test")
                     (setenv "GDK_BACKEND" "x11")
                     (setenv "GSK_RENDERER" "cairo")
                     (invoke "xvfb-run" "-a" "cargo" "test"
                             "--workspace" "--locked" "--offline"))))
               (replace 'install
                 (lambda* (#:key outputs #:allow-other-keys)
                   (invoke "cargo" "run" "--locked" "--offline"
                           "-p" "xtask" "--" "install"
                           "--prefix" (assoc-ref outputs "out")
                           "--no-build")))
               ;; `curl`, `wtype` and `cava` are called by name at run time.
               ;; A propagated input only reaches the profile of whoever
               ;; installs the package, and a compositor starts the shell with
               ;; the PATH it inherited rather than a login shell's, so the
               ;; binary carries their store paths itself.
               (add-after 'install 'wrap-runtime-tools
                 (lambda* (#:key inputs #:allow-other-keys)
                   (let* ((path (string-append
                                 (dirname (search-input-file inputs "/bin/wtype"))
                                 ":"
                                 (dirname (search-input-file inputs "/bin/curl"))
                                 ":"
                                 (dirname (search-input-file inputs "/bin/cava")))))
                     (wrap-program (string-append #$output "/bin/whelk")
                       `("PATH" ":" prefix (,path)))))))))
    (native-inputs
     ;; cargo builds and runs the Rust and Guile suites; xvfb-run supplies
     ;; the display those GTK tests need, and dbus lets the notification
     ;; tests start a private session bus.  The rust must be at least 1.92:
     ;; gtk4-rs 0.11 declares that MSRV and cargo refuses an older toolchain.
     (list (list glib "bin")
           dbus
           guile-3.0
           pkg-config
           wayland
           rust
           (list rust "cargo")
           gcc-toolchain
           xvfb-run))
    (inputs
     ;; libx11 is what turns a bar into a dock with EWMH struts on an X11
     ;; desktop; without it whelk still builds and runs on Wayland alone.
     ;; linux-pam enables the screen locker; without it whelk still builds but
     ;; the locker fails closed.
     (list gtk
           gtk4-layer-shell
           guile-3.0
           libx11
           linux-pam
           ;; Called by name at run time; the wrap phase above puts them on the
           ;; binary's PATH, and they stay propagated for a profile's scripts.
           cava
           curl
           wtype))
    ;; whelk calls wtype by name for menu shortcuts and the optional keyboard
    ;; test path, curl to read a weather or stock card and cava for the
    ;; visualizer; keep all three in the profile so a desktop launch sees them.
    (propagated-inputs
     (list cava wtype curl))
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
     ;; The phases are meson's own.  0.3.9 is a C program with a Scheme brain
     ;; and a `meson.build' that installs everything - the binary, the data
     ;; files, the Scheme modules and the compiled catalogues - so the `cargo'
     ;; phases this package carried were a build the project no longer has, and
     ;; they failed with "cargo: not found" before the first object was
     ;; compiled.  The project's own `guix.scm' is the same list of inputs and
     ;; the same build system, which is why the two cannot drift again.
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

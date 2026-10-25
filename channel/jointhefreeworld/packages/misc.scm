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
;; A shell configuration written in Scheme, a dock written in C and GTK, the
;; window that shows the desktop's own keyboard reference, wallpapers and
;; palettes, and the icon theme that paints the desktop those programs appear
;; on.  They share nothing but their author and their home on Codeberg, so each
;; is written out in the build system it actually uses.
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
            heks-toon
            skeu-icons))

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
    (version "0.10.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/lambdock.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "04036jqj02i8s991nf74rjin8gp32h0dnqxgq3gfd6fq573hs4ry"))))
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

(define-public heks-toon
  (package
    (name "heks-toon")
    (version "0.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/heks-toon.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0whcq975mw5swnlgm9g2zdc9rjvxq13hm8gnfy0b7i2ws5fwmpkw"))))
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

(define-public skeu-icons
  (package
    (name "skeu-icons")
    (version "1.5.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/skeu-icons.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1crayf3wr23x71f996v3x2chrcl407rbl4hb06b12vi0flxxk5kg"))))
    ;; There is nothing to compile: the themes are committed artwork, and the
    ;; programmes that redraw them are not part of what a desktop installs.
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (ice-9 ftw))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'install
            (lambda _
              (let ((target (string-append #$output "/share/icons")))
                (mkdir-p target)
                ;; Every directory carrying an index.theme is one theme.  The
                ;; accent and dark variants are trees of relative symlinks into
                ;; skeu-icons, so they are copied with their links intact and
                ;; keep pointing at their parent once they sit side by side.
                (for-each
                 (lambda (name)
                   (let ((dir (string-append "." "/" name)))
                     (when (and (file-is-directory? dir)
                                (file-exists?
                                 (string-append dir "/index.theme")))
                       (copy-recursively
                        dir (string-append target "/" name)))))
                 (scandir "." (lambda (name)
                                (string-prefix? "skeu-icons" name))))))))))
    (home-page "https://codeberg.org/jjba23/skeu-icons")
    (synopsis "Skeuomorphic icon theme for Linux desktops")
    (description
     "Skeu Icons is an icon theme drawn as painted objects rather than flat
glyphs: folders with enamel, paper and cloth, devices with brushed metal and
glass, and file types that look like the thing they stand for.  Alongside the
relief bitmaps it ships a symbolic layer for the Adwaita name contract, the
same artwork without the -symbolic suffix, and accent variants that repaint the
folder enamel in fourteen colours, each with a light-ink dark sibling.  The
toolkits find every name a shell, dock or file manager asks for, because the
pack links the desktop ids, Icon= values, window classes and MIME names that
would otherwise fall back to Adwaita.")
    (license license:cc-by-sa4.0)))

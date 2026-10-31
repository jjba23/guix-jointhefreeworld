;;; manifest.scm --- every package this channel provides.

;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; Build or enter the whole collection from a checkout of this channel:
;;
;;   guix build -L channel -m manifest.scm
;;   guix shell -L channel -m manifest.scm
;;
;; `-L channel' is what makes `(jointhefreeworld packages)' resolvable before the
;; channel has been pulled.
;;
;;; Code:

(use-modules (jointhefreeworld packages)
             (guix packages))

(packages->manifest
 (list guile-kracht
       guile-scriba
       guile-veritas
       guile-bewaking
       guile-hygguile
       guile-orgwebalchemy
       guile-openapi-generator
       guile-olive-css
       maak
       sift
       ggg
       iter-vitae
       lenkesamler
       consceal
       skapa
       araneola
       mutastructura
       cask-and-cons
       emacs-maak
       emacs-modusregel
       emacs-veritas
       emacs-welkomscherm
       emacs-tekengrootte
       guile-heks-bash
       lambdock
       heks-toon
       skeu-icons
       jointhefreeworld))

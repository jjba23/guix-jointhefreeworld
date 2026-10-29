;;; packages.scm --- all jointhefreeworld packages in one module.

;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; The channel is split into modules by what a package is, so that a user can
;; import only the part they need.  This module imports all of them and
;; re-exports their packages, for the shell where one wants to see the whole
;; collection at once.
;;
;;; Code:

(define-module (jointhefreeworld packages)
  #:use-module (jointhefreeworld packages applications)
  #:use-module (jointhefreeworld packages emacs)
  #:use-module (jointhefreeworld packages guile)
  #:use-module (jointhefreeworld packages misc)
  #:use-module (jointhefreeworld packages site)
  #:re-export (guile-kracht
               guile-scriba
               guile-veritas
               guile-bewaking
               guile-hygguile
               guile-orgwebalchemy
               guile-openapi-generator
               guile-olive-css
               maak
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

;;; packages.scm --- all jointhefreeworld packages in one module.

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

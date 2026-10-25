;;; manifest.scm --- every package this channel provides.

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

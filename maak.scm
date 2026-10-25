;;; maak.scm --- the tasks of the guix-jointhefreeworld channel.

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
;; A channel is checked by building its packages, linting them, and verifying
;; that the commit history users will fetch is signed.  These tasks are those
;; three things, plus the formatting and the shell that make working on the
;; channel pleasant.
;;
;;; Code:

(define-module (maak)
  #:declarative? #t
  #:use-module (ice-9 format)
  #:use-module (maak maak))

;; ====== Maak file constants ======

;; The directory .guix-channel declares as the channel's module root.
(define channel-directory
  "channel")

;; The first signed commit and its signer: the channel introduction users put
;; in their channels.scm.  These are the same values as in channels.scm.
(define introductory-commit
  "b0ac3f05075d7959860fc9e1db5871acddea3986")

(define signing-fingerprint
  "83BC 6E1C 8726 B8C2 97F8  D16E 24F4 6738 CE11 4AF6")

;; The package names in manifest.scm, in the order they are declared there.
;; `maak lint' and `maak check' lint them all; keep this list in step when a
;; package is added.
(define %packages
  '("guile-kracht"
    "guile-scriba"
    "guile-veritas"
    "guile-bewaking"
    "guile-hygguile"
    "guile-orgwebalchemy"
    "guile-openapi-generator"
    "guile-olive-css"
    "maak"
    "ggg"
    "iter-vitae"
    "lenkesamler"
    "consceal"
    "skapa"
    "araneola"
    "mutastructura"
    "cask-and-cons"
    "emacs-maak"
    "emacs-modusregel"
    "emacs-veritas"
    "emacs-welkomscherm"
    "emacs-tekengrootte"
    "guile-heks-bash"
    "lambdock"
    "heks-toon"
    "skeu-icons"
    "jointhefreeworld"))

;; ====== Tasks ======

(define (default)
  "List the available tasks."
  (list-tasks))

(define* (build #:optional package)
  "Build PACKAGE, or every package in the channel when none is given."
  (if package
      (run (list "guix" "build" "-L" channel-directory package)
           #:verbose? #t)
      (run (list "guix" "build" "-L" channel-directory
                 "-m" "manifest.scm")
           #:verbose? #t)))

(define* (lint #:optional package)
  "Lint PACKAGE, or every package in the channel when none is given.

Linting every package reaches the network for the updater and CVE checks; use
`maak check' for the offline version."
  (run (if package
           (list "guix" "lint" "-L" channel-directory package)
           (append (list "guix" "lint" "-L" channel-directory)
                   %packages))
       #:verbose? #t))

(define (fmt)
  "Format every Scheme source with the Guix style guide."
  (run (list "find" "." "-maxdepth" "8" "-name" "*.scm" "-type" "f"
             "-exec" "guix" "style" "-f" "{}" ";")
       #:verbose? #t))

(define (authenticate)
  "Verify the channel's commit signatures from the introduction to HEAD."
  (run (list "guix" "git" "authenticate"
             introductory-commit signing-fingerprint)
       #:verbose? #t))

(define (check)
  "Lint without the network, build every package, then authenticate the history."
  (run (append (list "guix" "lint" "-L" channel-directory "--no-network")
               %packages)
       #:verbose? #t)
  (build)
  (authenticate))

(define (shell)
  "Open a shell with every package in the channel."
  (run (list "guix" "shell" "-L" channel-directory "-m" "manifest.scm")
       #:verbose? #t))

(define (show-introduction)
  "Print the channel introduction to put in a channels.scm."
  (format #t
          "(introduction~% (make-channel-introduction~%  ~s~%  (openpgp-fingerprint~%   ~s)))~%"
          introductory-commit signing-fingerprint))

(define (publish)
  "Push the authenticated trunk and the keyring branch to Codeberg.

The keyring branch is the root of trust and is not part of the channel's
authenticated history, so it is pushed with --no-verify: the pre-push hook
installed by `guix git authenticate' would otherwise try to authenticate a
commit that is not a descendant of the introduction and refuse the push."
  (git (list "push" "codeberg" "trunk") #:verbose? #t)
  (git (list "push" "--no-verify" "codeberg" "keyring") #:verbose? #t))

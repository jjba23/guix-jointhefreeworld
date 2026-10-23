;;; channels.scm --- an example channel list that includes this channel.

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
;; Copy this to ~/.config/guix/channels.scm, or cons the channel onto the list
;; you already have.  The channel provides Guile libraries, command-line
;; programs, Emacs packages, a GTK4 dock and the jointhefreeworld site builder,
;; so one pull gives the latest release of the whole collection.  It carries
;; packages only, so it is left to your own channel list to pin the Guix
;; revision everything is built with.
;;
;; The introduction below is what lets Guix authenticate every commit it
;; fetches from the channel.  Keep it in step with the channel's first signed
;; commit and the key in .guix-authorizations.
;;
;;; Code:

(cons* (channel
        (name 'jointhefreeworld)
        (url "https://codeberg.org/jjba23/guix-jointhefreeworld")
        (branch "trunk")
        (introduction
         (make-channel-introduction
          "b0ac3f05075d7959860fc9e1db5871acddea3986"
          (openpgp-fingerprint
           "83BC 6E1C 8726 B8C2 97F8  D16E 24F4 6738 CE11 4AF6"))))
       %default-channels)

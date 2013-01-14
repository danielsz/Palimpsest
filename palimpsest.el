;;; palimpsest-mode.el --- Various deletion strategies when editing
;;; text that eludes total oblivion. Implemented as a minor mode.

;; Copyright (C) 2013 Daniel Szmulewicz <http://about.me/daniel.szmulewicz>

;; Author: Daniel Szmulewicz <daniel.szmulewicz@gmail.com>

;;; Commentary:
;;
;; This file is NOT part of GNU Emacs.
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3 of the License,
;; or (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; See <http://www.gnu.org/licenses/> for a copy of the GNU General
;; Public License.


;;; Documentation:
;;
;; This minor mode provides several strategies to remove text without
;; permanently deleting it, useful to prose / fiction writers.
;; Namely, it provides the following capabilities:
;;

;; Known bugs or limitations:

;; - if several {style}, [lang] or (class) attributes are given for
;;       the same block, only the first one of each type will be
;;       highlighted.
;;
;; - some complex imbrications of inline markup and attributes are
;;       not well-rendered (for example, *strong *{something}notstrong*)
;;


;;; Code:

(defun move-region-to-rebuts (start end)
  "Move selected text to associated rebuts buffer"
  (interactive "r")
  (let (
	(rebuts-file (concat (file-name-sans-extension (buffer-file-name)) ".rebuts.txt"))
	(rebuts-buffer (concat (file-name-sans-extension (buffer-name)) ".rebuts.txt"))
	(oldbuf (current-buffer))
     )
  (save-excursion
   (if (file-exists-p rebuts-file) (find-file rebuts-file))
   (set-buffer (get-buffer-create rebuts-buffer))
   (set-visited-file-name rebuts-file)
   (goto-char (point-max))
   (insert-buffer-substring oldbuf start end)
   (newline)
   (save-buffer)
  )
   (kill-region start end)
   (switch-to-buffer oldbuf)
 ))

;; Custom move region to bottom 
(defun move-region-to-bottom (start end)
  "Move selected text to bottom of buffer"
  (interactive "r")
  (let (
	(count (count-lines-region start end))
	)
    (save-excursion
      (kill-region start end)
      (goto-char (point-max))
      (yank)
      (newline)
      )
    (push-mark (point))
    (message "Moved a %s" count)
    ))

(defgroup palimpsest nil
  "Customization group for `palimpsest-mode'.")

(defconst palimpsest-mode-keymap (make-sparse-keymap) "Keymap used in palimpsest mode")

(define-key palimpsest-mode-keymap (kbd "C-M-z") 'move-region-to-bottom)
(define-key palimpsest-mode-keymap (kbd "C-M-r") 'move-region-to-rebuts)

(define-minor-mode palimpsest-mode
  "Toggle palimpsest mode. 
Interactively with no argument, this command toggles the mode.
to show buffer size and position in mode-line.  You can customize
this minor mode, see option `nyan-mode'.

Note: If you turn this mode on then you probably want to turn off
option `scroll-bar-mode'."
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " Palimpsest"
  ;; The minor mode bindings.
  :keymap palimpsest-mode-keymap
  :global t
  :group 'palimpsest)

(provide 'palimpest-mode)
 ;;; palimpsest-mode.el ends here

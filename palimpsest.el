;;; palimpsest.el --- Various deletion strategies when editing
;;; text that should elude total oblivion. Implemented as a minor mode.

;; Copyright (C) 2013 Daniel Szmulewicz <http://about.me/daniel.szmulewicz>

;; Author: Daniel Szmulewicz <daniel.szmulewicz@gmail.com>

;; Version: 0.8

;;; Documentation:
;;
;; This minor mode provides several strategies to remove text without
;; permanently deleting it, useful to prose / fiction writers.
;; Namely, it provides the following capabilities:
;;
;; - Send selected text to the bottom of the file
;; - Send selected text to a trash file
;;

;;; Legal:
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


;;; Code:

(defgroup palimpsest nil
  "Customization group for `palimpsest-mode'."
	:group 'convenience)

(defcustom palimpsest-bottom-key ""
  "Keybinding to send selected text to bottom of the file. Defaults to C-c C-r"
  :group 'palimpsest
  :type '(restricted-sexp :match-alternatives (stringp vectorp)))

(defcustom palimpsest-trash-key "" 
  "Keybinding to send selected text to the trash. Defaults to C-c C-q"
  :group 'palimpsest
  :type '(restricted-sexp :match-alternatives (stringp vectorp)))

(defcustom palimpsest-trash-file-suffix ".trash"
  "This is the suffix for the trash filename"
  :group 'palimpsest
  :type '(string))

(defconst palimpsest-keymap (make-sparse-keymap) "Keymap used in palimpsest mode")

(define-key palimpsest-keymap palimpsest-bottom-key 'move-region-to-bottom)
(define-key palimpsest-keymap palimpsest-trash-key 'move-region-to-trash)

(defun move-region-to-trash (start end)
  "Move selected text to associated trash buffer"
  (interactive "r")
  (if (use-region-p) 
      (if buffer-file-truename 
	  (let (
		(trash-file (concat (file-name-sans-extension (buffer-file-name)) palimpsest-trash-file-suffix  "." (file-name-extension (buffer-file-name))))
		(trash-buffer (concat (file-name-sans-extension (buffer-name)) palimpsest-trash-file-suffix "." (file-name-extension (buffer-file-name))))
		(oldbuf (current-buffer)))
	    (save-excursion
	      (if (file-exists-p trash-file) (find-file trash-file))
	      (set-buffer (get-buffer-create trash-buffer))
	      (set-visited-file-name trash-file)
	      (goto-char (point-min))
	      (insert-buffer-substring oldbuf start end)
	      (newline)
	      (save-buffer)
	      (write-file buffer-file-truename))	
	    (kill-region start end)
	    (switch-to-buffer oldbuf))
	(message "Please save buffer first."))
    (message "No region selected")))

;; Custom move region to bottom 
(defun move-region-to-bottom (start end)
  "Move selected text to bottom of buffer"
  (interactive "r")
  (if (use-region-p) 
      (let ((count (count-words-region start end)))
	(save-excursion
	  (kill-region start end)
	  (goto-char (point-max))
	  (yank)
	  (newline))
	(push-mark (point))
	(message "Moved %s words" count))
    (message "No region selected")))


;;;###autoload
(define-minor-mode palimpsest-mode
  "Toggle palimpsest mode. 
Interactively with no argument, this command toggles the mode.
to show buffer size and position in mode-line.  You can customize
this minor mode, see option `palimpsest-mode'.

Note: If you turn this mode on then you probably want to turn off
option `scroll-bar-mode'."
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " Palimpsest"
  ;; The minor mode bindings.
  :keymap palimpsest-keymap
  :global nil
  :group 'palimpsest)

(provide 'palimpsest)
;;; palimpsest.el ends here

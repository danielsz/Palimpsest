;;; palimpsest.el --- Various deletion strategies when editing -*- lexical-binding: t; -*-
;;; text that should elude total oblivion. Implemented as a minor mode.

;; Copyright (C) 2013 Daniel Szmulewicz <http://about.me/daniel.szmulewicz>

;; Author: Daniel Szmulewicz <daniel.szmulewicz@gmail.com>

;; Version: 1.2

;;; Documentation:
;;
;; This minor mode provides several strategies to remove text without
;; permanently deleting it, useful to prose / fiction writers.
;; Namely, it provides the following capabilities:
;;
;; - Send selected text to the bottom of the file
;; - Send selected text to the top of the file
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

;;;;;;;;;;;;;;;;;;;
;; Customization ;;
;;;;;;;;;;;;;;;;;;;

(defconst palimpsest-keymap (make-sparse-keymap) "Keymap used in palimpsest mode.")

(defgroup palimpsest nil
  "Customization group for `palimpsest-mode'."
	:group 'convenience)

(defun palimpsest--make-key-setter (command)
  "Keybinding setter.  Return a Customize :set function that binds COMMAND to the new key in `palimpsest-keymap', unbinding the previous key first.  COMMAND should be a symbol naming an interactive function."
  (lambda (symbol value)
    (let ((old (and (boundp symbol) (symbol-value symbol))))
      (custom-set-default symbol value)
      (when (and old (not (equal old value)))
        (define-key palimpsest-keymap (kbd old) nil))
      (define-key palimpsest-keymap (kbd value) command))))

(defcustom palimpsest-send-bottom "C-c C-r"
  "Keybinding to send selected text to the bottom of the current buffer."
  :group 'palimpsest
  :set (palimpsest--make-key-setter 'palimpsest-move-region-to-bottom)
  :type 'string)

(defcustom palimpsest-send-top "C-c C-s"
  "Keybinding to send selected text to the top of the current buffer."
  :group 'palimpsest
  :set (palimpsest--make-key-setter 'palimpsest-move-region-to-top)
  :type 'string)

(defcustom palimpsest-trash-key "C-c C-q"
  "Keybinding to send selected text to the trash."
  :group 'palimpsest
  :set (palimpsest--make-key-setter 'palimpsest-move-region-to-trash)
  :type 'string)

(defcustom palimpsest-trash-file-suffix ".trash"
  "This is the suffix for the trash filename."
  :group 'palimpsest
  :type 'string)

(defcustom palimpsest-prefix ""
  "Prefix the yanked text snippet with a customizable string."
  :group 'palimpsest
  :type '(choice (string :tag "Prefix as string") (character :tag "Prefix as character")))

;;;;;;;;;;;;;;;;;
;; Move region ;;
;;;;;;;;;;;;;;;;;

(defun palimpsest-move-region-to-dest (start end dest)
  "Move text between START and END to buffer's desired position, otherwise known as DEST."
  (let ((count (count-words-region start end)))
    (save-excursion
      (kill-region start end)
      (goto-char (funcall dest))
      (insert palimpsest-prefix)
      (yank)
      (newline))
    (push-mark (point))
    (message "Moved %s words" count)))

(defun palimpsest-move-region-to-top (start end)
  "Move text between START and END to top of buffer."
  (interactive "r")
  (if (use-region-p)
      (palimpsest-move-region-to-dest start end 'point-min)
    (message "No region selected")))

;; Custom move region to bottom
(defun palimpsest-move-region-to-bottom (start end)
  "Move text between START and END to bottom of buffer."
  (interactive "r")
  (if (use-region-p)
      (palimpsest-move-region-to-dest start end 'point-max)
    (message "No region selected")))

(defun palimpsest-move-region-to-trash (start end)
  "Move text between START and END to associated trash buffer."
  (interactive "r")
  (if (use-region-p)
      (if buffer-file-truename
	  (let* ((ext (file-name-extension (buffer-file-name)))
		 (trash-buffer (concat (file-name-sans-extension (buffer-name)) palimpsest-trash-file-suffix (and ext (concat "." ext))))
		 (trash-file (expand-file-name trash-buffer))
		 (oldbuf (current-buffer)))
	    (save-excursion
	      (if (file-exists-p trash-file) (find-file trash-file))
	      (set-buffer (get-buffer-create trash-buffer))
	      (set-visited-file-name trash-file)
	      (goto-char (point-min))
	      (insert palimpsest-prefix)
	      (insert-buffer-substring oldbuf start end)
	      (newline)
	      (save-buffer))
	    (kill-region start end)
	    (switch-to-buffer oldbuf))
	(message "Please save buffer first."))
    (message "No region selected")))

;;;###autoload
(define-minor-mode palimpsest-mode
  "Toggle palimpsest mode.
Interactively with no argument, this command toggles the mode.  You can customize
this minor mode, see option `palimpsest-mode'."
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " Palimpsest"
  ;; The minor mode bindings.
  :keymap palimpsest-keymap
  :global nil
  :group 'palimpsest)

(provide 'palimpsest)
;;; palimpsest.el ends here

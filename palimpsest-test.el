;;; palimpsest-test.el --- Tests for palimpsest -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'palimpsest)

;;; Helpers

(defmacro palimpsest-test-with-temp-dir (dir-var &rest body)
  "Evaluate BODY with DIR-VAR bound to a fresh temporary directory."
  (declare (indent 1) (debug t))
  `(let ((,dir-var (make-temp-file "palimpsest-test-" t)))
     (unwind-protect
         (progn ,@body)
       (delete-directory ,dir-var t))))

(defmacro palimpsest-test-with-messages (&rest body)
  "Evaluate BODY, capturing `message' output.
Return the list of formatted messages produced (most recent first)."
  (declare (indent 0) (debug t))
  `(let ((palimpsest-test-messages nil))
     (cl-letf (((symbol-function 'message)
                (lambda (&rest args)
                  (push (apply #'format args) palimpsest-test-messages))))
       ,@body)
     palimpsest-test-messages))

(defun palimpsest-test-select-region (start end)
  "Activate the region between START and END in the current buffer."
  (setq transient-mark-mode t)
  (goto-char start)
  (set-mark end)
  (setq mark-active t))

;;; Move-to-top / move-to-bottom

(ert-deftest palimpsest-test-move-region-to-top ()
  (with-temp-buffer
    (insert "one two three")
    (let ((palimpsest-prefix ""))
      (palimpsest-move-region-to-dest (point-min) (point-max) 'point-min))
    (should (string= "one two three\n" (buffer-string)))))

(ert-deftest palimpsest-test-move-region-to-bottom ()
  (with-temp-buffer
    (insert "AAA BBB CCC")
    (goto-char (point-min))
    (let ((palimpsest-prefix ""))
      (palimpsest-move-region-to-dest (point-min) (+ (point-min) 3) 'point-max))
    (should (string= " BBB CCCAAA\n" (buffer-string)))))

(ert-deftest palimpsest-test-move-region-prefix ()
  (with-temp-buffer
    (insert "hello world")
    (let ((palimpsest-prefix "NOTE: "))
      (palimpsest-move-region-to-dest (point-min) (point-max) 'point-min))
    (should (string= "NOTE: hello world\n" (buffer-string)))))

(ert-deftest palimpsest-test-move-region-no-selection ()
  (with-temp-buffer
    (insert "hello")
    (should (member "No region selected"
                    (palimpsest-test-with-messages
                      (palimpsest-move-region-to-top (point-min) (point-max)))))))

;;; Move-to-trash

(ert-deftest palimpsest-test-trash-creates-file ()
  (palimpsest-test-with-temp-dir dir
    (let* ((src (expand-file-name "draft.org" dir))
           (trash (expand-file-name "draft.trash.org" dir)))
      (with-temp-file src (insert "hello"))
      (let ((buf (find-file-noselect src)))
        (unwind-protect
            (progn
              (with-current-buffer buf
                (palimpsest-test-select-region (point-min) (point-max))
                (palimpsest-move-region-to-trash (point-min) (point-max)))
              (should (file-exists-p trash))
              (should (string= "hello\n"
                               (with-temp-buffer
                                 (insert-file-contents trash)
                                 (buffer-string))))
              (should (string= "" (with-current-buffer buf (buffer-string)))))
          (kill-buffer buf))))))

(ert-deftest palimpsest-test-trash-unsaved-buffer ()
  (with-temp-buffer
    (insert "hello")
    (palimpsest-test-select-region (point-min) (point-max))
    (should (member "Please save buffer first."
                    (palimpsest-test-with-messages
                      (palimpsest-move-region-to-trash (point-min) (point-max)))))))

(ert-deftest palimpsest-test-trash-no-selection ()
  (with-temp-buffer
    (insert "hello")
    (should (member "No region selected"
                    (palimpsest-test-with-messages
                      (palimpsest-move-region-to-trash (point-min) (point-max)))))))

(ert-deftest palimpsest-test-trash-same-basename-different-dirs ()
  (palimpsest-test-with-temp-dir dir
    (let* ((a-dir (expand-file-name "a" dir))
           (b-dir (expand-file-name "b" dir))
           (a-src (expand-file-name "notes.org" a-dir))
           (b-src (expand-file-name "notes.org" b-dir))
           (a-trash (expand-file-name "notes.trash.org" a-dir))
           (b-trash (expand-file-name "notes.trash.org" b-dir)))
      (make-directory a-dir)
      (make-directory b-dir)
      (with-temp-file a-src (insert "alpha"))
      (with-temp-file b-src (insert "beta"))
      (let ((buf-a (find-file-noselect a-src))
            (buf-b (find-file-noselect b-src)))
        (unwind-protect
            (progn
              (with-current-buffer buf-a
                (palimpsest-test-select-region (point-min) (point-max))
                (palimpsest-move-region-to-trash (point-min) (point-max)))
              (with-current-buffer buf-b
                (palimpsest-test-select-region (point-min) (point-max))
                (palimpsest-move-region-to-trash (point-min) (point-max)))
              (should (file-exists-p a-trash))
              (should (file-exists-p b-trash))
              (should (string= "alpha\n"
                               (with-temp-buffer
                                 (insert-file-contents a-trash)
                                 (buffer-string))))
              (should (string= "beta\n"
                               (with-temp-buffer
                                 (insert-file-contents b-trash)
                                 (buffer-string)))))
          (kill-buffer buf-a)
          (kill-buffer buf-b))))))

;;; Customization

(ert-deftest palimpsest-test-key-setter ()
  (let ((orig-val palimpsest-send-bottom)
        (orig-binding (lookup-key palimpsest-keymap (kbd palimpsest-send-bottom))))
    (unwind-protect
        (let ((setter (palimpsest--make-key-setter 'palimpsest-move-region-to-bottom)))
          (funcall setter 'palimpsest-send-bottom "C-c C-x")
          (should (eq (lookup-key palimpsest-keymap (kbd "C-c C-x"))
                      'palimpsest-move-region-to-bottom))
          (should-not (lookup-key palimpsest-keymap (kbd "C-c C-r"))))
      (custom-set-default 'palimpsest-send-bottom orig-val)
      (define-key palimpsest-keymap (kbd "C-c C-x") nil)
      (define-key palimpsest-keymap (kbd "C-c C-r") orig-binding))))

(provide 'palimpsest-test)
;;; palimpsest-test.el ends here

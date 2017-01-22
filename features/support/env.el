(require 'f)

(defvar Palimpsest-support-path
  (f-dirname load-file-name))

(defvar Palimpsest-features-path
  (f-parent Palimpsest-support-path))

(defvar Palimpsest-root-path
  (f-parent Palimpsest-features-path))

(add-to-list 'load-path Palimpsest-root-path)

;; Ensure that we don't load old byte-compiled versions
(let ((load-prefer-newer t))
  (require 'palimpsest)
  (require 'espuds)
  (require 'ert))

(Setup
 ;; Before anything has run
 )

(Before
 ;; Before each scenario is run
 (switch-to-buffer
  (get-buffer-create "*palimpsest*"))
 (erase-buffer)
 (transient-mark-mode 1)
 (deactivate-mark)
 )

(After
 ;; After each scenario is run
 )

(Teardown
 ;; After when everything has been run
 )

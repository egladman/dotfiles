(use-package emacs
  :init
  (defalias 'yes-or-no-p 'y-or-n-p) ;; life is too short

  (setq indent-tabs-mode nil) ;; no tabs

  (setq make-backup-files nil) ;; keep everything under vc 
  (setq auto-save-default nil)

  ;; keep backup and save files in a dedicated directory
  (setq backup-directory-alist
        `((".*" . ,(concat user-emacs-directory "backups")))
        auto-save-file-name-transforms
        `((".*" ,(concat user-emacs-directory "backups") t)))

  ;; no need to create lockfiles
  (setq create-lockfiles nil))

(setq window-resize-pixelwise t)
(setq frame-resize-pixelwise t)

;; Mouse Support in Terminal
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; Set default font face
(set-face-attribute 'default nil :font "Source Code Pro")

;; Load theme
(load-theme 'modus-vivendi t)

;; Disable package.el in favor of straight.el
(setq package-enable-at-startup nil)

;; Disable splash screen
(setq inhibit-startup-screen t)

;; Disable sounds
(setq ring-bell-function 'ignore)

;; Install vertico
(use-package vertico
  :straight t
  :ensure t
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

;; Configure vertico directory extension.
(use-package vertico-directory
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Install savehist
(use-package savehist
  :straight t
  :init
  (savehist-mode))

;; Install marginalia
(use-package marginalia
  :straight t
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

;; Install golden-ratio
(use-package golden-ratio
  :straight t
  :init
  (golden-ratio-mode 1))

;; Install consult
(use-package consult
  :straight t)

;; FIXME
(global-set-key [rebind switch-to-buffer] #'consult-buffer)
(global-set-key (kbd "C-c j") #'consult-line)
(global-set-key (kbd "C-c i") #'consult-imenu)
(setq read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      completion-ignore-case t)

;; Install corfu

(use-package orderless
  :straight t)

(defun orderless-fast-dispatch (word index total)
  (and (= index 0) (= total 1) (length< word 4)
       `(orderless-regexp . ,(concat "^" (regexp-quote word)))))

(orderless-define-completion-style orderless-fast
  (orderless-style-dispatchers '(orderless-fast-dispatch))
  (orderless-matching-styles '(orderless-literal orderless-regexp)))

(use-package corfu-terminal
  :straight t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.0)
  (completion-styles '(orderless-fast))
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert) ; Do not preview current candidate
  (corfu-preselect-first nil)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets

  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC"      . corfu-insert-separator)
              ("TAB"        . corfu-next)
              ([tab]        . corfu-next)
              ("S-TAB"      . corfu-previous)
              ([backtab]    . corfu-previous)
              ("RET" . corfu-insert))
  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-excluded-modes'.
  :init
  (global-corfu-mode)
  (unless (display-graphic-p)
    (corfu-terminal-mode +1))

  :config
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t
                              corfu-quit-no-match t
                              corfu-auto nil)
              (corfu-mode))))

(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

;; Install lsp-mode
;; https://github.com/minad/corfu/wiki#configuring-corfu-for-lsp-mode

(use-package orderless
  :straight t
  :init
  ;; Tune the global completion style settings to your liking!
  ;; This affects the minibuffer and non-lsp completion at point.
  (setq completion-styles '(orderless partial-completion basic)
        completion-category-defaults nil
        completion-category-overrides nil))

(use-package lsp-mode
  :straight t
  :custom
  (lsp-completion-provider :none) ;; we use Corfu!
  :init
  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(flex))) ;; Configure flex
  :hook
  (lsp-completion-mode . my/lsp-mode-setup-completion))

;; Install cape
(use-package cape
  :straight t
  :init
  ;;(add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-ispell)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  (add-to-list 'completion-at-point-functions #'cape-symbol)
  (add-to-list 'completion-at-point-functions #'cape-line))

;; Install magit -  Git client
(use-package magit
  :straight t)

;; Bind the `magit-status' command to a convenient key.
(global-set-key (kbd "C-c g") #'magit-status)

;; Install diff-hl - Indication of local VCS changes
(use-package diff-hl
  :straight t)

;; Install wind-move - Select window with Shift+<arrow>
(use-package windmove
  :straight t)

(windmove-default-keybindings 'ctrl)

;; Enable `diff-hl' support by default in programming buffers
(add-hook 'prog-mode-hook #'diff-hl-mode)


;; Install expand-region
(use-package expand-region
  :straight t)
(global-set-key (kbd "M-2") 'er/expand-region)

;;; Install undo-tree
(use-package undo-tree
  :straight t)
(global-undo-tree-mode 1)

;; Install go-mode - Golang Support
(use-package go-mode
  :straight t)

;; Set up before-save hooks to format buffer and add/delete imports.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Enable lsp-mode for go buffers
(add-hook 'go-mode-hook 'lsp-deferred)

;; FIXME
;; Compile on save
(add-hook 'after-save-hook
      (lambda ()
        (if (eq major-mode 'go-mode)
            (flycheck-compile 'go-build))))

;; Install flycheck - Syntax Checking
(use-package flycheck
  :straight t
  :defer 2
  :diminish
  :ensure t
  :custom
  (flycheck-display-errors-delay .3)
  :init
  (global-flycheck-mode))

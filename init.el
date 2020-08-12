;; init.el --- Kate the Lazy Developer's Emacs Startup

;;; Commentary:

;; This is basically baby's first (or maybe second) Emacs startup
;; file.  It's like maybe one step up from copying random LISP from
;; the internet and pasting it in.

;;; Code:

;; Stolen from https://blog.d46.us/advanced-emacs-startup/
;; Reduce garbage collection frequency during startup
(setq gc-cons-threshold (* 50 1000 1000))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

;; Set up package install
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

;; Is use-package installed? If not, please install it.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; THEME SETUP
;; ============

(use-package one-themes
  :ensure t
  :init
  (load-theme 'one-light t)
  (setq current-theme "light"))

(defun toggle-theme ()
  "Switch between light and dark themes."
  (interactive)
  (if (string= current-theme "light")
      (progn
        (setq current-theme "dark")
        (load-theme 'one-dark t)
        (spaceline-compile))
    (progn
      (setq current-theme "light")
      (load-theme 'one-light t)
      (spaceline-compile))))

(defun set-os-specific-options ()
  "Set options that differ by OS."
  (interactive)
  (cond
   ((string-equal system-type "darwin")
    (progn
      (setq ispell-program-name "/usr/local/bin/aspell")
      (setq preferred-typeface "Fira Code 14")))
   ((string-equal system-type "gnu/linux")
    (progn
      (setq ispell-program-name "/usr/bin/aspell")
      (setq preferred-typeface "Fira Code 10")))))

(set-os-specific-options)

;; Make Fira Code ligatures work
(when (window-system)
  (set-frame-font 'preferred-typeface))
  (add-to-list 'default-frame-alist (cons 'font preferred-typeface))
(let ((alist '((33 . ".\\(?:\\(?:==\\|!!\\)\\|[!=]\\)")
               (35 . ".\\(?:###\\|##\\|_(\\|[#(?[_{]\\)")
               (36 . ".\\(?:>\\)")
               (37 . ".\\(?:\\(?:%%\\)\\|%\\)")
               (38 . ".\\(?:\\(?:&&\\)\\|&\\)")
               (42 . ".\\(?:\\(?:\\*\\*/\\)\\|\\(?:\\*[*/]\\)\\|[*/>]\\)")
               (43 . ".\\(?:\\(?:\\+\\+\\)\\|[+>]\\)")
               (45 . ".\\(?:\\(?:-[>-]\\|<<\\|>>\\)\\|[<>}~-]\\)")
               (46 . ".\\(?:\\(?:\\.[.<]\\)\\|[.=-]\\)")
               (47 . ".\\(?:\\(?:\\*\\*\\|//\\|==\\)\\|[*/=>]\\)")
               (48 . ".\\(?:x[a-zA-Z]\\)")
               (58 . ".\\(?:::\\|[:=]\\)")
               (59 . ".\\(?:;;\\|;\\)")
               (60 . ".\\(?:\\(?:!--\\)\\|\\(?:~~\\|->\\|\\$>\\|\\*>\\|\\+>\\|--\\|<[<=-]\\|=[<=>]\\||>\\)\\|[*$+~/<=>|-]\\)")
               (61 . ".\\(?:\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\)\\|[<=>~]\\)")
               (62 . ".\\(?:\\(?:=>\\|>[=>-]\\)\\|[=>-]\\)")
               (63 . ".\\(?:\\(\\?\\?\\)\\|[:=?]\\)")
               (91 . ".\\(?:]\\)")
               (92 . ".\\(?:\\(?:\\\\\\\\\\)\\|\\\\\\)")
               (94 . ".\\(?:=\\)")
               (119 . ".\\(?:ww\\)")
               (123 . ".\\(?:-\\)")
               (124 . ".\\(?:\\(?:|[=|]\\)\\|[=>|]\\)")
               (126 . ".\\(?:~>\\|~~\\|[>=@~-]\\)")
               )
             ))
  (dolist (char-regexp alist)
    (set-char-table-range composition-function-table (car char-regexp)
                          `([,(cdr char-regexp) 0 font-shape-gstring]))))

;; Highlight current line
(global-hl-line-mode 1)
;; (set-face-background 'hl-line "#EEEEEE")
(set-face-foreground 'highlight nil)
(set-cursor-color "#808080")

;; Enable line numbers in the sidebar
(global-linum-mode t)

(defun turn-off-linum ()
  "Turn off linum mode for performance reasons."
  (interactive)
  (message "Deactivated linum mode")
  (global-linum-mode 0)
  (linum-mode 0))

;; Allow selected text to be replaced by typing
(delete-selection-mode 1)

;; auto close bracket insertion. New in emacs 24
(electric-pair-mode 1)

;; I like to up- and down-case.
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; Set up recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)

;; Make backups go to a single directory
;; Stolen from https://www.emacswiki.org/emacs/BackupDirectory#toc2
(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

(setq python-shell-interpreter "python3")

;; KEYBOARD SHORTCUTS
;; ==================

;; Generic
(global-set-key (kbd "C-c b b") 'switch-to-buffer)
(global-set-key (kbd "C-c s h") 'eshell)
(global-set-key (kbd "C-.") 'call-last-kbd-macro)

;; Make Emacs behave more like a Mac application
(setq default-input-method "MacOSX")
(setq mac-allow-anti-aliasing t)
;; For when I want Emacs meta to be in the same place on Linux and MacOS
;; (setq mac-command-modifier 'meta)
;; (setq mac-option-modifier 'super
;;       mac-right-option-modifier 'nil)
(setq mac-option-modifier 'meta
      mac-right-option-modifier 'nil)
(global-set-key (kbd "<C-s-268632070>") 'toggle-frame-fullscreen)
(global-set-key (kbd "C-s-f") 'toggle-frame-fullscreen)
(setq-default cursor-type 'bar)

;; Needed because my Bluetooth keyboard is weird
(defun toggle-option-key ()
  "Function to toggle between right option behavior on the Mac."
  (interactive)
  (setq mac-right-option-modifier (if mac-right-option-modifier 'nil 'meta)))
(global-set-key (kbd "C-s-o") 'toggle-option-key)
(global-set-key (kbd "<C-268632079>") 'toggle-option-key)

;; Enable Atom-like copy/cut line

(defun xah-cut-line-or-region ()
  "Cut current line, or text selection.
When `universal-argument' is called first, cut whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2015-06-10"
  (interactive)
  (if current-prefix-arg
      (progn ; not using kill-region because we don't want to include previous kill
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (progn (if (use-region-p)
               (kill-region (region-beginning) (region-end) t)
             (kill-region (line-beginning-position) (line-beginning-position 2))))))

(defun xah-copy-line-or-region ()
  "Cut current line, or text selection.
When `universal-argument' is called first, cut whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2015-06-10"
  (interactive)
  (if current-prefix-arg
      (progn ; not using kill-region because we don't want to include previous kill
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (progn (if (use-region-p)
               (kill-ring-save (region-beginning) (region-end) t)
             (kill-ring-save (line-beginning-position) (line-beginning-position 2))))))

(global-set-key (kbd "s-c") 'xah-copy-line-or-region)
(global-set-key (kbd "s-x") 'xah-cut-line-or-region)

;; Set up kill-whole-line shortcut to mimic Atom
;; Stolen from https://stackoverflow.com/questions/3958528/how-can-i-delete-the-current-line-in-emacs
(defun delete-current-line ()
  "Delete (not kill) the current line."
  (interactive)
  (save-excursion
    (delete-region
     (progn (forward-visible-line 0) (point))
     (progn (forward-visible-line 1) (point)))))
(global-set-key (kbd "C-S-k") 'delete-current-line)

;; Join line keybind
(defun concat-lines ()
  "Join next line and current line."
  (interactive)
  (save-excursion (forward-line)
  (join-line)))
(global-set-key (kbd "s-j") 'concat-lines)

;; Enable soft word wrapping at window boundary
(global-visual-line-mode t)

;; Remove trailing whitespace before save.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Specify an explicit shell
;; (setq explicit-shell-file-name "/bin/bash")
(eval-after-load "term"
  '(define-key term-raw-map (kbd "C-c C-y") 'term-paste))

;; Trying to get idents working and failing.
;; I clearly don't understand Emacs indenting.
;; (setq-default indent-tabs-mode nil)
;; Disabled this because I'm test-driving tabs
(setq-default tab-width 2)

;; Make Tramp use SSH by default
(setq tramp-default-method "ssh")

;; Remove toolbar
(tool-bar-mode -1)

;; Get rid of startup screen
(setq inhibit-startup-screen t)

;; CONVENIENT KEYBOARD SHORTCUTS

;; Enable Mac generic key shortcuts
(global-set-key (kbd "s-<down>") 'end-of-buffer)
(global-set-key (kbd "s-<up>") 'beginning-of-buffer)
(global-set-key (kbd "s-<right>") 'move-end-of-line)
(global-set-key (kbd "s-<left>") 'move-beginning-of-line)

;; Key bind recommendations from Steve Yegge
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)

(defun open-startup-file ()
  "Open Emacs startup file for editing."
  (interactive)
  (find-file user-init-file))

(global-set-key (kbd "C-c f e d") 'open-startup-file)

;; Allow inserting a line above or below current line regardless of where you are in the line
(defun smart-open-line ()
  "Insert an empty line after the current line.
Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline))

(defun smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key [(super shift return)] 'smart-open-line-above)
(global-set-key [(super return)] 'smart-open-line)

;; Setting up code formatter utils

(defun make-error-buffer-name (formatter)
  "Output a generic error buffer name based on FORMATTER."
  (concat "*" formatter " Error Buffer*"))

(defun run-formatter-on-current-buffer (formatter-name formatter-command)
  "Run formatter named FORMATTER-NAME on current buffer using FORMATTER-COMMAND."
   (shell-command-on-region
   (point-min)
   (point-max)
   formatter-command
   ;; where to output
   (current-buffer)
   t ;; replace?
   (make-error-buffer-name formatter-name)
   ;; show error buffer
   t))

(defun escape-file-path-spaces (filepath)
  "Escape spaces in FILEPATH with backslashes."
  (replace-regexp-in-string "\s" "\\ " filepath))

(defun format-with-prettier ()
  "Format the current buffer using prettier."
  (interactive)
  (run-formatter-on-current-buffer "Prettier"
                                   (concat "prettier --stdin --stdin-filepath "
                                           (escape-file-path-spaces (buffer-file-name)))))

(defun format-with-standard ()
  "Format the current buffer in StanardJS format."
  (interactive)
  (run-formatter-on-current-buffer "Standard"
                                   (concat "prettier --no-semi --single-quote --stdin --stdin-filepath "
                                           (escape-file-path-spaces (buffer-file-name)))))

(defun format-with-brittany ()
  "Format the current buffer using brittany."
  (interactive)
  (run-formatter-on-current-buffer "Brittany" "brittany"))

(with-eval-after-load 'haskell-mode
  (define-key haskell-mode-map (kbd "C-c f m t") 'format-with-brittany))

(with-eval-after-load 'rjsx-mode
  (define-key rjsx-mode-map (kbd "C-c f m t") 'format-with-standard))

;; Tabs and such
(setq-default indent-tabs-mode nil)

(defun insert-timestamp ()
  "Insert ISO-8601 timestamp."
  (interactive)
  (insert (format-time-string "%Y-%m-%d %H:%M")))

(global-set-key (kbd "C-c t s") #'insert-timestamp)

;; Markdown

(use-package markdown-mode
  :ensure t
  :defer t)
(use-package typo
  :ensure t
  :defer t)

;; Turn on typography when I'm writing markdown
(add-hook 'markdown-mode-hook 'typo-mode)
;; (add-hook 'markdown-mode-hook (lambda () (variable-pitch-mode t)))
(add-hook 'markdown-mode-hook 'flyspell-mode)
;; (add-hook 'markdown-mode-hook 'turn-off-linum)

(defun set-text-margins ()
  "Set margins in current buffer."
  (interactive)
  (setq left-margin-width 100)
  (setq right-margin-width 100))

;; This is weird when you have multiple buffers side-by-side.
;; (add-hook 'markdown-mode-hook 'set-text-margins)

;; Haskell

(use-package haskell-mode
  :ensure t
  :defer t)
;; (use-package haskell-process
;;   :ensure t
;;   :defer t)

(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)

;; JavaScript
(use-package rjsx-mode
  :ensure t
  :defer t)

(add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))
(add-hook 'rjsx-mode #'yas-minor-mode)
(setq js-indent-level 2)
(setq js2-basic-offset 2)
(setq js2-strict-missing-semi-warning nil)

;; All the Lisps

(use-package cider
  :ensure t
  :defer t)
(use-package clojure-mode
  :ensure t
  :defer t)
(use-package slime
  :ensure t
  :defer t
  :config (setq inferior-lisp-program "/usr/local/bin/sbcl"))

;; Enable GUI Emacs to get PATH on MacOS

(use-package exec-path-from-shell
  :ensure t
  :config (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

;; Other packages we love to see

(use-package atom-one-dark-theme
  :ensure t
  :defer t)
(use-package company
  :ensure t
  :defer t
  :init (global-company-mode))
(use-package diminish
  :ensure t
  :config
  (diminish 'flycheck-mode)
  (diminish 'auto-complete-mode)
  (diminish 'company-mode)
  (diminish 'helm-mode)
  (diminish 'which-key-mode)
  (diminish 'eldoc-mode)
  (diminish 'yas-minor-mode)
  (diminish 'visual-line-mode))
(use-package elm-mode
  :ensure t
  :defer t
  :config (setq elm-format-on-save t))
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode)
  (setq flycheck-eslintrc "~/.eslintrc")
  (setq flycheck-stylelintrc "~/.stylelintrc"))
(use-package helm
  :ensure t
  :defer t
  :init (helm-mode 1)
  :config
  (setq helm-ff-file-name-history-use-recentf t)
  (customize-set-variable 'helm-ff-lynx-style-map t)
  (helm-adaptive-mode 1)
  :bind (("C-x C-r" . 'helm-recentf)
         ("M-x" . 'helm-M-x)
         ("C-x C-m" . 'helm-M-x)
         ("C-c C-m" . 'helm-M-x)
         ("C-x r b" . 'helm-filtered-bookmarks)
         ("C-x C-f" . 'helm-find-files)
         ("C-c f f" . 'helm-find-files)
         ("C-c f n" . 'helm-semantic-or-imenu)))
(use-package helm-files
  :bind (:map helm-find-files-map
              ("<tab>" . 'helm-execute-persistent-action)
              ("C-z" . 'helm-select-action)))
(use-package helm-projectile
  :ensure t
  :defer t
  :config
  :init (helm-projectile-on))
(use-package magit
  :ensure t
  :defer t
  :bind ("C-x g" . 'magit-status))
(use-package neotree
  :ensure t
  :defer t
  :bind ("s-\\" . neotree-toggle)
  :config
  (setq neo-smart-open t)
  (setq neo-theme 'arrow))
(use-package pdf-tools
  :ensure t
  :defer t)
(use-package powerline
  :ensure t
  :defer t)
(use-package projectile
  :ensure t
  :defer t
  :init (projectile-mode)
  :config
  (setq projectile-completion-system 'helm)
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  (add-to-list 'projectile-globally-ignored-directories "dist")
  :bind (("s-p" . 'projectile-find-file)
         ("C-c p" . 'projectile-command-map)))
(use-package spaceline
  :ensure t
  :defer t
  :init (progn
          (spaceline-emacs-theme)
          (setq-default
           powerline-height 24
           powerline-default-separator 'wave)
          (spaceline-toggle-flycheck-error-off)
          (spaceline-toggle-flycheck-warning-off)
          (spaceline-toggle-flycheck-info-off)
          (spaceline-compile)))
(use-package which-key
  :ensure t
  :defer t
  :init (which-key-mode))
(use-package yasnippet
  :ensure t
  :defer t
  :init (yas-global-mode 1)
  :bind ("C-c C-c" . 'yas-load-snippet-buffer-and-close))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#eee8d5" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#839496"])
 '(compilation-message-face (quote default))
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#657b83")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-safe-themes
   (quote
    ("57f95012730e3a03ebddb7f2925861ade87f53d5bbb255398357731a7b1ac0e0" "6a23db7bccf6288fd7c80475dc35804c73f9c9769ad527306d2e0eada1f8b466" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default)))
 '(fci-rule-color "#eee8d5")
 '(haskell-stylish-on-save nil)
 '(helm-ff-lynx-style-map t)
 '(highlight-changes-colors (quote ("#d33682" "#6c71c4")))
 '(highlight-symbol-colors
   (quote
    ("#efe4da49afb1" "#cfc4e1acd08b" "#fe52c9e6b34e" "#dbb6d3c2dcf3" "#e183dee0b053" "#f944cc6dae47" "#d35fdac4e069")))
 '(highlight-symbol-foreground-color "#586e75")
 '(highlight-tail-colors
   (quote
    (("#eee8d5" . 0)
     ("#b3c34d" . 20)
     ("#6ccec0" . 30)
     ("#74adf5" . 50)
     ("#e1af4b" . 60)
     ("#fb7640" . 70)
     ("#ff699e" . 85)
     ("#eee8d5" . 100))))
 '(hl-bg-colors
   (quote
    ("#e1af4b" "#fb7640" "#ff6849" "#ff699e" "#8d85e7" "#74adf5" "#6ccec0" "#b3c34d")))
 '(hl-fg-colors
   (quote
    ("#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3")))
 '(hl-paren-colors (quote ("#2aa198" "#b58900" "#268bd2" "#6c71c4" "#859900")))
 '(magit-diff-use-overlays nil)
 '(nrepl-message-colors
   (quote
    ("#dc322f" "#cb4b16" "#b58900" "#5b7300" "#b3c34d" "#0061a8" "#2aa198" "#d33682" "#6c71c4")))
 '(package-selected-packages
   (quote
    (one-themes evil-leader evil spaceline-config esup js-comint cider clojure-mode yasnippet diminish spaceline rjsx-mode company flycheck typo solarized-theme elm-mode which-key slime helm-projectile helm projectile helm-ebdb pdf-tools neotree atom-one-dark-theme markdown-mode powerline exec-path-from-shell magit js2-mode use-package auto-complete haskell-mode)))
 '(pos-tip-background-color "#eee8d5")
 '(pos-tip-foreground-color "#586e75")
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#eee8d5" 0.2))
 '(term-default-bg-color "#fdf6e3")
 '(term-default-fg-color "#657b83")
 '(vc-annotate-background nil)
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#dc322f")
     (40 . "#cb4366eb20b4")
     (60 . "#c1167942154f")
     (80 . "#b58900")
     (100 . "#a6ae8f7c0000")
     (120 . "#9ed892380000")
     (140 . "#96be94cf0000")
     (160 . "#8e5397440000")
     (180 . "#859900")
     (200 . "#77679bfc4635")
     (220 . "#6d449d465bfd")
     (240 . "#5fc09ea47092")
     (260 . "#4c68a01784aa")
     (280 . "#2aa198")
     (300 . "#303498e7affc")
     (320 . "#2fa1947cbb9b")
     (340 . "#2c879008c736")
     (360 . "#268bd2"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   (quote
    (unspecified "#fdf6e3" "#eee8d5" "#a7020a" "#dc322f" "#5b7300" "#859900" "#866300" "#b58900" "#0061a8" "#268bd2" "#a00559" "#d33682" "#007d76" "#2aa198" "#657b83" "#839496")))
 '(xterm-color-names
   ["#eee8d5" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#073642"])
 '(xterm-color-names-bright
   ["#fdf6e3" "#cb4b16" "#93a1a1" "#839496" "#657b83" "#6c71c4" "#586e75" "#002b36"]))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(linum ((t (:inherit (shadow default) :family "Helvetica Neue"))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.5))))
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.3))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :underline t :height 1.2))))
 '(markdown-header-face-4 ((t (:inherit markdown-header-face :underline t :height 1.1))))
 '(markdown-header-face-5 ((t (:inherit markdown-header-face :underline t))))
 '(markdown-header-face-6 ((t (:inherit markdown-header-face :underline t))))
 '(minibuffer-prompt ((t (:family "Helvetica Neue"))))
 '(mode-line ((t (:underline nil :box nil))))
 '(mode-line-buffer-id-inactive ((t (:inherit mode-line-buffer-id :family "Helvetica Neue"))))
 '(mode-line-inactive ((t (:underline nil :box nil))))
 '(powerline-active0 ((t (:inherit mode-line :family "Helvetica Neue"))))
 '(powerline-active1 ((t (:inherit mode-line :family "Helvetica Neue"))))
 '(powerline-active2 ((t (:inherit mode-line :family "Helvetica Neue"))))
 '(powerline-inactive0 ((t (:inherit mode-line-inactive :family "Helvetica Neue"))))
 '(powerline-inactive1 ((t (:inherit mode-line-inactive :family "Helvetica Neue"))))
 '(powerline-inactive2 ((t (:inherit mode-line-inactive :family "Helvetica Neue"))))
 '(variable-pitch ((t (:family "Helvetica Neue")))))

;; Stolen from https://blog.d46.us/advanced-emacs-startup/
;; Restore garbage collection
(setq gc-cons-threshold (* 2 1000 1000))

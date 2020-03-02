;; UTF-8 support
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; Init
;;----------------------------------------------------------------------------------------
(require 'cl) ;; (loop for ...)
(require 'dired-x)

;; Debugging
;;----------------------------------------------------------------------------------------
;;(setq debug-on-error t)

;; Global Prefs
;;----------------------------------------------------------------------------------------
(global-unset-key (kbd "C-z"))
(setq vc-follow-symlinks t)
(setq inhibit-startup-screen t)
(global-visual-line-mode 1)
;;(global-hl-line-mode 1)
(setq ring-bell-function 'ignore)
(setq tramp-mode nil)
(setq indent-tabs-mode nil)
(setq case-fold-search t)
(setq echo-keystrokes 0.1)
(setq line-move-visual nil)
(menu-bar-mode -1)
(setq perl-indent-level 4)
(setq lua-indent-level 2)
(setq sh-basic-offset 4)
(setq sh-indentation 4)
(setq standard-indent 4)
(setq js-indent-level 4)
(setq tab-width 4)

;; remove trailing white space from lines
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; region highlighting
(transient-mark-mode t)

;; Custom Path / Sudo Support
;;----------------------------------------------------------------------------------------
(setq my-home (expand-file-name (concat "~" (or (getenv "SUDO_USER") (getenv "USER")))))
(setq my-emacsd (concat my-home "/.emacs.d/"))
(setq auto-save-list-file-prefix my-emacsd)
(setq user-emacs-directory my-emacsd)
(setq load-path (cons (concat my-emacsd "/lisp") load-path))
(loop for file in (directory-files my-emacsd t ".*.el$")
      do (load-file file))

;; Macros
;;----------------------------------------------------------------------------------------
(defmacro make-interactive-fun (fn args)
  `(lambda () (interactive) (funcall ,fn ,args)))

(defmacro make-fun (fn args)
  `(lambda () (funcall ,fn ,args)))

(defmacro bol-with-prefix (function)
  "Define a new function which calls FUNCTION.
Except it moves to beginning of line before calling FUNCTION when
called with a prefix argument. The FUNCTION still receives the
prefix argument."
  (let ((name (intern (format "endless/%s-BOL" function))))
    `(progn
       (defun ,name (p)
         ,(format
           "Call `%s', but move to BOL when called with a prefix argument."
           function)
         (interactive "P")
         (when p
           (forward-line 0))
         (call-interactively ',function))
       ',name)))

;; Functions
;;----------------------------------------------------------------------------------------
(defun volatile-kill-buffer ()
   "Kill current buffer unconditionally."
   (interactive)
   (let ((buffer-modified-p nil))
     (kill-buffer (current-buffer))))
(global-set-key (kbd "C-x k") 'volatile-kill-buffer)

(defun save-current-kbd-macro-to-dot-emacs (name)
  "Save the current macro as named function definition inside your
   initialization file so you can reuse it anytime in the future."
  (interactive "SSave Macro as: ")
  (name-last-kbd-macro name)
  (save-excursion
    (find-file-literally user-init-file)
    (goto-char (point-max))
    (insert "\n\n;; Saved macro\n")
    (insert-kbd-macro name)
    (insert "\n")))

(defun file-change-too-close-for-comfort ()
  (let* ((file-time-raw (nth 5 (file-attributes (buffer-file-name))))
         (file-time (+ (lsh (nth 0 file-time-raw) 16) (nth 1 file-time-raw)))
         (current-time (+ (lsh (nth 0 (current-time)) 16) (nth 1 (current-time)))))
    (and (eq current-time file-time)
         (message "%s: postpone revert" (buffer-name))
         t)))

;; Kill *everything* after the cursor (EOF)
(defun kill-to-eof ()
  (interactive)
  (kill-region (point) (point-max)))
(global-set-key "\C-ck" 'kill-to-eof)

(defun show-file-name ()
  "Show the full path file name in the minibuffer"
  (interactive)
  (message (buffer-file-name))
  (kill-new (file-truename buffer-file-name)))
(global-set-key "\C-cz" 'show-file-name)

(defun my-autoload (&rest modes)
  "Autoload each mode listed in MODES."
  (loop for mode in modes do (autoload (intern mode) mode nil t)))
(my-autoload "id" "ace-jump-mode" "align"
	     "multi-mode" "org" "time-stamp" "pf-mode"
	     "gtags" "outdent" "vcl-mode")

(defun add-function-to-hooks (fun modes-hooks)
  "Add a call to FUN to each mode-hook listed in MODES-HOOKS."
  (loop for mode-hook in modes-hooks do
	(add-hook mode-hook fun)))
(add-function-to-hooks (make-fun 'set-fill-column 78) '(c-mode-hook lisp-mode-hook
                                                        emacs-lisp-mode-hook
                                                        html-mode-hook))
(add-function-to-hooks (make-fun 'set-fill-column 72) '(text-mode-hook))

;; Save files starting with #! as executable
;;----------------------------------------------------------------------------------------
;; (from https://github.com/baron42bba/.emacs.d/blob/master/bba.org#safe-hash-bang-files-executable)
(defun make-buffer-executable-if-hashbang ()
  (if (and (save-excursion
             (save-restriction
               (widen)
               (goto-char (point-min))
               (save-match-data
                 (looking-at "^#!"))))
           (not (file-executable-p buffer-file-name)))
      (progn
        (shell-command (concat "chmod ugo+x " buffer-file-name))
        (message (concat "Saved " buffer-file-name " with +x")))))
(add-hook 'after-save-hook 'make-buffer-executable-if-hashbang)


;; Customize Backup Files
;;----------------------------------------------------------------------------------------
(setq backup-inhibited t)
(setq make-backup-files nil)
;(setq make-backup-files t)
(setq auto-save-default nil)
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
 backup-by-copying t    ; Don't delink hardlinks
 version-control t      ; Use version numbers on backups
 delete-old-versions t  ; Automatically delete excess backups
 kept-new-versions 20   ; how many of the newest versions to keep
 kept-old-versions 5    ; and how many of the old
)

;; ELPA / MELPA
;;----------------------------------------------------------------------------------------
(if (>= emacs-major-version 24)
    (require 'package)
  (load-file (concat my-emacsd "/23/package.el")))
(setq tls-checktrust t)
(setq gnutls-verify-error t)
(let ((trustfile "/etc/ssl/certs/ca-certificates.crt"))
  (setq gnutls-trustfiles (list trustfile))
  (setq tls-program
        (list
         (format "gnutls-cli --x509cafile %s -p %%p %%h" trustfile))))
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
;;			 ("marmalade" . "http://marmalade-repo.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")))
(setq package-archive-priorities '(("melpa-stable" . 10)
				   ("gnu"          . 5)
				   ("melpa"        . 1)))

(let ((package-list '(ace-window
		      ag
		      aggressive-indent
		      async
		      avy
		      crontab-mode
		      dash
		      enh-ruby-mode
		      epl
		      exec-path-from-shell
		      expand-region
		      git-gutter
		      go-mode
		      ht
		      json-mode
		      lua-mode
		      markdown-mode
		      multiple-cursors
		      neotree
		      org-bullets
		      php-mode
		      pkg-info
		      puppet-mode
		      python-mode
		      ruby-mode
		      smartparens
		      smex
		      use-package
		      use-package-chords
		      which-key
		      yaml-mode
		      )))
  (package-initialize)
  ;; fetch the list of packages available
  (unless package-archive-contents
    (package-refresh-contents))
  ;; install the missing packages
  (dolist (package package-list)
    (unless (package-installed-p package)
      (package-install package))))

;; use-package
(require 'use-package)
(setq use-package-always-ensure t)
;;(setq use-package-always-pin "melpa-stable")

;; use-package extensions
(use-package use-package-chords
  :ensure t
  :config (key-chord-mode 1))

;; Column mode, Line number formatting, Prompt y/n
;;----------------------------------------------------------------------------------------
(column-number-mode t)

(add-hook 'prog-mode-hook 'global-linum-mode)
(custom-set-faces
 '(linum ((t (:background "black" :foreground "cyan" :slant oblique :weight thin)))))
(setq linum-format "%4d \u2502 ")

;; Always ask for y/n keypress instead of typing out 'yes' or 'no'
(defalias 'yes-or-no-p 'y-or-n-p)

;; Global Hot Key Defs
;;----------------------------------------------------------------------------------------
(global-set-key (kbd "M-r") 'replace-string) ;; bind "M-r" to command 'replace-string'
(global-set-key (kbd "M-l") 'goto-line) ;; bind "M-l" to command 'goto-line'
(global-set-key (kbd "M-e") 'end-of-buffer) ;; bind "M-e" to command 'end-of-buffer'
(global-set-key (kbd "M-b") 'beginning-of-buffer) ;; bind "M-s" to command 'beginning-of-buffer'


;; Initialize / configure packages
;;----------------------------------------------------------------------------------------

;; mode-line
(defvar my-mode-line-coding-format
  '(:eval
    (let* ((code (symbol-name buffer-file-coding-system))
           (eol-type (coding-system-eol-type buffer-file-coding-system))
           (eol (cond ((eq 0 eol-type) "UNIX")
                      ((eq 1 eol-type) "DOS")
                      ((eq 2 eol-type) "MAC")
                      (t "???"))))
      (concat code ":" eol " "))))
(put 'my-mode-line-coding-format 'risky-local-variable t)
(setq-default mode-line-format (substitute
                                'my-mode-line-coding-format
                                'mode-line-mule-info
                                mode-line-format))

(use-package gitconfig-mode
    :ensure t)

(use-package gitignore-mode
    :ensure t)

(require 'git-gutter)
(global-git-gutter-mode t)
(setq git-gutter:disabled-modes '(org-mode))
(setq git-gutter:update-hooks '(after-save-hook after-revert-hook))
(setq git-gutter:modified-sign "↯")
(setq git-gutter:separator-sign "|")
(set-face-foreground 'git-gutter:modified "yellow")

(use-package smex
    :ensure t)

(use-package use-package-chords
  :ensure t
  :config (key-chord-mode 1))

(use-package which-key
    :ensure t
    :diminish which-key-mode
    :config
    (add-hook 'after-init-hook 'which-key-mode))

(use-package avy
    :ensure t
    :chords (("jj" . avy-goto-char-2)
             ("jl" . avy-goto-line)))

(use-package expand-region
    :ensure t
    :bind ("C-=" . er/expand-region))

;; NeoTree - file browser
(use-package neotree
    :ensure t
    :config
    (global-set-key (kbd "C-c t") 'neotree-toggle))
(setq neo-smart-open t)
(setq neo-theme 'arrow)

;; Delimiters
(use-package rainbow-delimiters
    :ensure t
    :config
    (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package aggressive-indent
      :ensure t)

(use-package exec-path-from-shell
    :ensure t
    :config
    (exec-path-from-shell-initialize))

(use-package org-bullets
    :ensure t
    :config
    (setq org-bullets-bullet-list '("∙"))
    (add-hook 'org-mode-hook 'org-bullets-mode))

;; Attempt to get the following from elpa intead of melpa
(use-package vcl-mode
    :pin gnu
    :ensure t)



;; Packages not managed by elpa/melpa located in .emacs.d/lisp
;;----------------------------------------------------------------------------------------
(add-to-list 'load-path "~/.emacs.d/lisp")


;; Custom set variabes - autogenerated
;;----------------------------------------------------------------------------------------

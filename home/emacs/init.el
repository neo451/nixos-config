;;; init.el --- Small Vim-like Emacs for learning Org -*- lexical-binding: t; -*-

;; Home Manager links this config from the Nix store, so put mutable Emacs
;; state under ~/.local/state/emacs instead of next to init.el.
(defvar my/state-dir
  (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME") "~/.local/state/")))
(make-directory my/state-dir t)

(setq custom-file (expand-file-name "custom.el" my/state-dir)
      recentf-save-file (expand-file-name "recentf" my/state-dir)
      savehist-file (expand-file-name "history" my/state-dir)
      save-place-file (expand-file-name "places" my/state-dir)
      bookmark-default-file (expand-file-name "bookmarks" my/state-dir)
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" my/state-dir))
(make-directory (expand-file-name "auto-save-list/" my/state-dir) t)
(when (file-exists-p custom-file)
  (load custom-file))

;; Sensible editing defaults.
(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      use-short-answers t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      require-final-newline t
      sentence-end-double-space nil
      indent-tabs-mode nil)

(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(column-number-mode 1)
(global-auto-revert-mode 1)
(global-display-line-numbers-mode 1)
(delete-selection-mode 1)
(which-key-mode 1)

;; Do not show line numbers in prose/special buffers.
(dolist (hook '(org-mode-hook
                text-mode-hook
                help-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode 0))))

;; Vim emulation.  Set these before Evil is loaded.
(setq evil-want-integration t
      evil-want-keybinding nil
      evil-want-C-u-scroll t
      evil-want-C-i-jump nil
      evil-respect-visual-line-mode nil
      evil-undo-system 'undo-redo)

(require 'evil)
(evil-mode 1)
(setq evil-default-state 'normal)

;; Make Emacs side modes (help, dired, buffers, etc.) use Vim-like keys too.
(require 'evil-collection)
(evil-collection-init)

(require 'evil-surround)
(global-evil-surround-mode 1)

;; Make common Vim muscle memory behave as expected.
(evil-set-leader 'normal (kbd "SPC"))
(evil-define-key 'normal global-map
  (kbd "<leader>w") #'save-buffer
  (kbd "<leader>q") #'quit-window
  (kbd "<leader>b") #'switch-to-buffer
  (kbd "<leader>f") #'find-file)

;; Org mode: keep it close to stock, just nicer for reading/writing notes.
(require 'evil-org)
(add-hook 'org-mode-hook #'evil-org-mode)
(add-hook 'evil-org-mode-hook
          (lambda ()
            (evil-org-set-key-theme '(navigation insert textobjects additional calendar))))
(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

(setq org-directory "~/orgfiles"
      org-default-notes-file (expand-file-name "agenda.org" org-directory)
      org-startup-indented t
      org-hide-emphasis-markers t
      org-return-follows-link t
      org-src-window-setup 'current-window
      org-edit-src-content-indentation 0
      org-log-done 'time
      org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@)" "|" "DONE(d!)" "CANCELLED(c@)")))
(make-directory org-directory t)

(add-hook 'org-mode-hook #'visual-line-mode)

;; Useful starting points for Org exploration.
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c a") #'org-agenda)
(setq org-agenda-files (directory-files-recursively org-directory "\\.org$"))
(setq org-capture-templates
      '(("t" "Task" entry
         (file+headline org-default-notes-file "Inbox")
         "* TODO %?\n  %U")
        ("n" "Note" entry
         (file+headline org-default-notes-file "Notes")
         "* %?\n  %U")))

(evil-define-key 'normal global-map
  (kbd "<leader>oa") #'org-agenda
  (kbd "<leader>oc") #'org-capture
  (kbd "<leader>oo") (lambda ()
                         (interactive)
                         (find-file org-default-notes-file)))

(when (member 'tokyo-night (custom-available-themes))
  (load-theme 'tokyo-night t))

(provide 'init)
;;; init.el ends here

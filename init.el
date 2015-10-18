; Remove welcome screen
(setq inhibit-startup-message t)

; Make sure required plugins are available.
(require 'cc-mode)
(require 'ido)
(require 'compile)
(load-library "view")

; Function to load a local todo file
(defun load-todo ()
  (interactive)
  (find-file "todo.txt"))

; Build file used for c++
(setq my-build-file "build.bat")
(setq compilation-directory-locked nil)

; Navigation
(defun previous-blank-line ()
  "Moves to the previous line containing nothing but whitespace."
  (interactive)
  (search-backward-regexp "^[ \t]*\n"))

(defun next-blank-line ()
  "Moves to the next line containing nothing but whitespace."
  (interactive)
  (forward-line)
  (search-forward-regexp "^[ \t]*\n")
  (forward-line -1))

(defun save-current-buffer ()
  "Untabify and save the current buffer."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (untabify (point-min) (point-max))))
  (save-buffer))

(defun start-of-indented-line ()
  (interactive)
  (beginning-of-line)
  (indent-for-tab-command))

(defun append-as-kill ()
  (interactive)
  (append-next-kill)
  (copy-region-as-kill (mark) (point)))

(defun maximize-frame ()
  (interactive)
  (w32-send-sys-command 61488))

(defun select-current-line ()
  (interactive)
  (end-of-line)
  (set-mark (line-beginning-position))) 

(defun smart-comment ()
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))

(defun append-as-kill ()
  "Performs copy-region-as-kill as an append."
  (interactive)
  ;(append-next-kill) 
  (copy-region-as-kill (mark) (point))
)

; Smarter functionfor moving to the start of a line
(defun smarter-move-beginning-of-line (arg)
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1)))
)

(defun find-build-file ()
  (interactive)
  (message "Current Directory: %s" default-directory)
  (if (not(file-exists-p my-build-file))
      (progn (cd "..") (find-build-file))
    (concat default-directory "/" my-build-file)))

; Compilation func take one
(defun build-project ()
  (interactive)
  (switch-to-buffer-other-window "*compilation*")
  (let ((temp-dir default-directory))
    (find-build-file)
    (compile my-build-file)
    (setq default-directory temp-dir)))


; Config 
(defun my-config ()
  "Function wrapping my basic settings"
  ; Lean window
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)

  (global-subword-mode)
  
  ; Undo history
  (setq undo-limit 20000000)
  (setq undo-strong-limit 40000000)
  
  (display-time)
  (setq scroll-step 3)
  
  ; Line highlight                
  (global-hl-line-mode 1)
  (set-face-background 'hl-line "midnight blue")
  
  ; Always use ido-mode                  
  (ido-mode t)
  
  ; Global tab settings
  (setq tab-width 4
        indent-tabs-mode nil)
  
  ; Word-based completion always on
  (abbrev-mode t)
  
  ; Use line numbers
  (global-linum-mode t)

  ; Disable line wrapping
  (set-default 'truncate-lines t)
  
  ; Disable the "pling" sound that some errors cause
  (setq visible-bell t)
  
  ; Set file extensions and their correct modes
  (setq auto-mode-alist
        (append
         '(("\\.cpp$" . c++-mode)
           ("\\.h$" . c++-mode)
           ("\\.inl" . c++-mode)) auto-mode-alist))
  
  ; Always match braces, parantheses, etc
  (electric-pair-mode t)
)

; Global keybindings
(defun my-global-keybinds ()
  ; Buffers and windows
  (global-set-key (read-kbd-macro "\eb") 'ido-switch-buffer)
  (global-set-key (read-kbd-macro "\eB") 'ido-switch-buffer-other-window)
  (define-key global-map "\ef" 'find-file)
  (define-key global-map "\eF" 'find-file-other-window)
  (define-key global-map "\ew" 'other-window)
  (define-key global-map "\es" 'save-current-buffer)
  (define-key global-map "\ek" 'kill-this-buffer)
  
  ; Navigation
  (define-key global-map [C-right] 'forward-word)
  (define-key global-map [C-left] 'backward-word)
  (define-key global-map [C-up] 'previous-blank-line)
  (define-key global-map [C-down] 'next-blank-line)
  (define-key global-map [home] 'smarter-move-beginning-of-line)
  (define-key global-map "\C-a" 'smarter-move-beginning-of-line)
  (define-key global-map [end] 'end-of-line)
  (define-key global-map [pgup] 'forward-page)
  (define-key global-map [pgdown] 'backward-page)
  (define-key global-map [C-next] 'scroll-other-window)
  (define-key global-map [C-prior] 'scroll-other-window-down)
  (define-key global-map [M-up] 'previous-blank-line)
  (define-key global-map [M-down] 'next-blank-line)
  (define-key global-map [M-right] 'forward-word)
  (define-key global-map [M-left] 'backward-word)
  (define-key global-map "\eg" 'goto-line)
  (define-key global-map "\ej" 'imenu)
  (define-key global-map "\eu" 'undo)
  (define-key global-map [S-tab] 'indent-for-tab-command)

  ; Compilation
  (define-key global-map "\em" 'build-project)
  (define-key global-map [f9] 'first-error)
  (define-key global-map [f10] 'previous-error)
  (define-key global-map [f11] 'next-error)
  
  ; Marks, copy & paste
  (define-key global-map "\e " 'set-mark-command)
  ;(define-key global-map (kbd "M-SPC") 'exchange-point-and-mark)
  (define-key global-map "\eq" 'append-as-kill)
  (define-key global-map "\ea" 'yank)
  (define-key global-map "\ez" 'kill-region)
  
  ; Misc
  (define-key global-map "\e6" 'upcase-word)
  (define-key global-map "\e7" 'capitilize-word)
  (define-key global-map "\et" 'load-todo)
      
  ;; Remove a few annoying keybinds
  (global-unset-key [mouse-2])

  ; Disable transient mark mode
  (transient-mark-mode nil)
)


; Bright-red TODOs
 (setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
 (make-face 'font-lock-fixme-face)
 (make-face 'font-lock-note-face)
 (mapc (lambda (mode)
         (font-lock-add-keywords
          mode
          '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
            ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
        fixme-modes)
 (modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
 (modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)

; C++ Style
(defconst my-cpp-style 
  '((c-electric-pound-behavior . nil)
    (c-tab-always-indent . t)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist . ((class-open)
                               (class-close)
                               (defun-open)
                               (defun-close)
                               (inline-open)
                               (inline-close)
                               (brace-list-open)
                               (brace-list-close)
                               (brace-list-intro)
                               (brace-list-entry)
                               (block-open)
                               (block-close)
                               (substatement-open)
                               (statement-case-open)))
    (c-hanging-colons-alist . ((inher-intro)
                               (case-label)
                               (label)
                               (access-label)
                               (access-key)
                               (member-init-intro)))
    (c-cleanup-list . (scope-operator
                       list-close-comma
                       defun-close-semi))
    (c-offsets-alist . ((arglist-close . 0)
                        (label . -4)
                        (access-label . -4)
                        (substatement-open . 0)
                        (statement-case-intro . 4)
                        ;(statement-block-intro . c-lineup-arglist-intro-after-paren)
                        (case-label . 4)
                        (block-open . 0)
                        (inline-open . 0)
                        (topmost-intro-cont . 0)
                        (knr-argdecl-intro . -4)
                        (brace-list-open . 0)
                        (brace-list-intro . 4)))
    (c-echo-syntactic-information-p . t))
  )

; C++ Hook
(defun my-cpp-hook ()
  (c-add-style "MyCpp" my-cpp-style t)
  (c-set-style "MyCpp")

  
  
  ; Keybindings
  (define-key c++-mode-map "\es" 'save-current-buffer)
  (define-key c++-mode-map "\C-x\C-s" 'save-current-buffer)
  (define-key c++-mode-map "\t" 'dabbrev-expand)
  (define-key c++-mode-map [S-tab] 'indent-for-tab-command)
  (define-key c++-mode-map [C-tab] 'indent-region)
  (define-key c++-mode-map [C-S-tab] 'align-current)
  (define-key c++-mode-map "\ej" 'imenu) ; Jump to synbol
  (define-key c++-mode-map "\e." 'c-fill-paragraph)
  (define-key c++-mode-map (kbd "C-5") 'c-mark-function)
  (define-key c++-mode-map "\eq" 'append-as-kill)
  (define-key c++-mode-map "\ea" 'yank)
  (define-key c++-mode-map "\ez" 'kill-region)
  (define-key c++-mode-map "\C-a" 'smarter-move-beginning-of-line)
  (define-key c++-mode-map [home] 'smarter-move-beginning-of-line)
  (define-key c++-mode-map "\ec" 'smart-comment)

)

(add-hook 'c-mode-common-hook 'my-cpp-hook)

(add-to-list 'default-frame-alist '(font . "Courier New-12.0"))
(set-face-attribute 'default t :font "Courier New-12.0")
(set-face-attribute 'font-lock-builtin-face nil :foreground "#EBCA9F")
(set-face-attribute 'font-lock-comment-face nil :foreground "gray50")
(set-face-attribute 'font-lock-constant-face nil :foreground "olive drab")
(set-face-attribute 'font-lock-doc-face nil :foreground "olive drab")
(set-face-attribute 'font-lock-function-name-face nil :foreground "burlywood3")
(set-face-attribute 'font-lock-keyword-face nil :foreground "DarkGoldenrod3")
(set-face-attribute 'font-lock-string-face nil :foreground "olive drab")
(set-face-attribute 'font-lock-type-face nil :foreground "burlywood3")
(set-face-attribute 'font-lock-variable-name-face nil :foreground "burlywood3")
;(set-face-attribute 'font-lock-preprocessor-face nil :foreground "firebrick3")

(defun my-startup-hook ()
  (interactive)
  (my-config)
  (my-global-keybinds)
  (set-foreground-color "burlywood3")
  (set-background-color "#161616")
  (set-cursor-color "#40FF40")
  (split-window-horizontally)
  (maximize-frame)
  )

(add-hook 'window-setup-hook 'my-startup-hook t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(make-backup-files nil))

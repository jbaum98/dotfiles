;;; packages.el --- ocaml Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq myocaml-packages
  '(
    ;; auto-complete
    company
    flycheck
    flycheck-ocaml
    ggtags
    helm-gtags
    merlin
    ocp-indent
    smartparens
    tuareg
    utop
    ))

(defun myocaml/post-init-company ()
  (spacemacs|add-company-hook merlin-mode))

(when (configuration-layer/layer-usedp 'syntax-checking)
  (defun myocaml/post-init-flycheck ()
    (spacemacs/add-flycheck-hook 'merlin-mode))
  (defun myocaml/init-flycheck-ocaml ()
    (use-package flycheck-ocaml
      :if (configuration-layer/package-usedp 'flycheck)
      :defer t
      :init
      (progn
        (with-eval-after-load 'merlin
          (setq merlin-error-after-save nil)
          (flycheck-ocaml-setup))))))

(defun myocaml/post-init-ggtags ()
  (add-hook 'ocaml-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun myocaml/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'ocaml-mode))

(defun myocaml/init-merlin ()
  (use-package merlin
    :defer t
    :init
    (progn
      (setq merlin-command "ocamlmerlin")
      (add-to-list 'spacemacs-jump-handlers-tuareg-mode
                'spacemacs/merlin-locate)
      (add-hook 'tuareg-mode-hook 'merlin-mode)
      (setq merlin-completion-with-doc t)
      (push 'merlin-company-backend company-backends-merlin-mode)
      (spacemacs/set-leader-keys-for-major-mode 'tuareg-mode
        "cp" 'merlin-project-check
        "cv" 'merlin-goto-project-file
        "eC" 'merlin-error-check
        "en" 'merlin-error-next
        "eN" 'merlin-error-prev
        "gb" 'merlin-pop-stack
        "gG" 'spacemacs/merlin-locate-other-window
        "gl" 'merlin-locate-ident
        "gi" 'merlin-switch-to-ml
        "gI" 'merlin-switch-to-mli
        "go" 'merlin-occurrences
        "hh" 'merlin-document
        "ht" 'merlin-type-enclosing
        "hT" 'merlin-type-expr
        "rd" 'merlin-destruct)
      (spacemacs/declare-prefix-for-mode 'tuareg-mode "mc" "compile/check")
      (spacemacs/declare-prefix-for-mode 'tuareg-mode "me" "errors")
      (spacemacs/declare-prefix-for-mode 'tuareg-mode "mg" "goto")
      (spacemacs/declare-prefix-for-mode 'tuareg-mode "mh" "help")
      (spacemacs/declare-prefix-for-mode 'tuareg-mode "mr" "refactor")
      )))

(defun myocaml/init-ocp-indent ()
  (use-package ocp-indent
    :defer t
    :init
    (add-hook 'tuareg-mode-hook 'ocp-indent-caml-mode-setup)
    (spacemacs/set-leader-keys-for-major-mode 'tuareg-mode
      "=" 'ocp-indent-buffer)))

(defun myocaml/post-init-smartparens ()
  (with-eval-after-load 'smartparens
    ;; don't auto-close apostrophes (type 'a = foo) and backticks (`Foo)
    (sp-local-pair 'tuareg-mode "'" nil :actions nil)
    (sp-local-pair 'tuareg-mode "`" nil :actions nil)))

(defun myocaml/init-tuareg ()
  (use-package tuareg
    :mode (("\\.ml[ily]?$" . tuareg-mode)
           ("\\.topml$" . tuareg-mode))
    :defer t
    :init
    (progn
      (spacemacs/set-leader-keys-for-major-mode 'tuareg-mode
        "ga" 'tuareg-find-alternate-file
        "cc" 'compile)
      ;; Make OCaml-generated files invisible to filename completion
      (dolist (ext '(".cmo" ".cmx" ".cma" ".cmxa" ".cmi" ".cmxs" ".cmt" ".cmti" ".annot"))
        (add-to-list 'completion-ignored-extensions ext)))))

(defun myocaml/init-utop ()
  (use-package utop
    :defer t
    :init
    (progn
      (add-hook 'tuareg-mode-hook 'utop-minor-mode)
      (spacemacs/register-repl 'utop 'utop "ocaml"))
    :config
    (progn
      (setq utop-command "utop -emacs")

      (defun spacemacs/utop-eval-phrase-and-go ()
        "Send phrase to REPL and evaluate it and switch to the REPL in
`insert state'"
        (interactive)
        (utop-eval-phrase)
        (utop)
        (evil-insert-state))

      (defun spacemacs/utop-eval-buffer-and-go ()
        "Send buffer to REPL and evaluate it and switch to the REPL in
`insert state'"
        (interactive)
        (utop-eval-buffer)
        (utop)
        (evil-insert-state))

      (defun spacemacs/utop-eval-region-and-go (start end)
        "Send region to REPL and evaluate it and switch to the REPL in
`insert state'"
        (interactive "r")
        (utop-eval-region start end)
        (utop)
        (evil-insert-state))

      (spacemacs/set-leader-keys-for-major-mode 'tuareg-mode
        "'"  'utop
        "sb" 'utop-eval-buffer
        "sB" 'spacemacs/utop-eval-buffer-and-go
        "si" 'utop
        "sp" 'utop-eval-phrase
        "sP" 'spacemacs/utop-eval-phrase-and-go
        "sr" 'utop-eval-region
        "sR" 'spacemacs/utop-eval-region-and-go)
      (spacemacs/declare-prefix-for-mode 'tuareg-mode "ms" "send"))
    (define-key utop-mode-map (kbd "C-j") 'utop-history-goto-next)
    (define-key utop-mode-map (kbd "C-k") 'utop-history-goto-prev)))

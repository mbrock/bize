(defvar bize-time-re
  "\\(0[0-9]:[0-5][0-9]:[0-5][0-9],[0-9][0-9][0-9]\\)")

(defun bize-next-time ()
  (re-search-forward bize-time-re)
  (re-search-forward bize-time-re)
  (re-search-forward bize-time-re)
  (re-search-backward bize-time-re))

(defun bize-prev-time ()
  (re-search-backward bize-time-re)
  (beginning-of-line))

(defun bize (wish)
  (unless (= 2 (length (window-list)))
    (error "You should have two windows."))
  (let* ((dst-window (car (window-list)))
         (src-window (cadr (window-list)))
         (dst-buffer (window-buffer dst-window))
         (src-buffer (window-buffer src-window))
         )
    (unless
        (and (looking-at bize-time-re)
             (with-selected-window dst-window
               (looking-at bize-time-re)))
      (error "You should be standing on two times."))

    (let ((inhibit-read-only t))
      (pcase wish
        ('a-next
         (with-selected-window src-window
           (bize-next-time)))
        ('b-next
         (bize-next-time))
        ('a-prev
         (with-selected-window src-window
           (bize-prev-time)))
        ('b-prev
         (bize-prev-time))
        ('copy
         (kill-whole-line)
         (insert
          (with-selected-window src-window
            (thing-at-point 'line)))
         (forward-line -1)
         (bize-next-time)
         (with-selected-window src-window
           (bize-next-time)))
        ('xxx
         (re-search-backward bize-time-re)
         (re-search-backward bize-time-re)
         (let ((it (thing-at-point 'line)))
           (bize-next-time)
           (kill-whole-line)
           (insert it)
           (forward-line -1))
         (bize-next-time)
         ))
      (hl-line-highlight)
      (recenter)
      (with-selected-window src-window
        (hl-line-highlight)
        (recenter)))))

(defun bize-copy () (interactive) (bize 'copy))
(defun bize-xxx () (interactive) (bize 'xxx))
(defun bize-a-next () (interactive) (bize 'a-next))
(defun bize-a-prev () (interactive) (bize 'a-prev))
(defun bize-b-next () (interactive) (bize 'b-next))
(defun bize-b-prev () (interactive) (bize 'b-prev))

(defvar bize-font-lock-keywords
  `((,bize-time-re (1 font-lock-function-name-face))))

(define-derived-mode bize-mode
  fundamental-mode "BIZE"
  "Kino Bize special hacking mode"
  (require 'hl-line)
  (hl-line-mode)
  (setq-local font-lock-defaults '(bize-font-lock-keywords)))

(define-key bize-mode-map (kbd "c") 'bize-copy)
(define-key bize-mode-map (kbd "x") 'bize-xxx)
(define-key bize-mode-map (kbd "a") 'bize-a-next)
(define-key bize-mode-map (kbd "A") 'bize-a-prev)
(define-key bize-mode-map (kbd "b") 'bize-b-next)
(define-key bize-mode-map (kbd "B") 'bize-b-prev)

(defun bize-start ()
  (interactive)
  (unless (= 2 (length (window-list)))
    (error "You should have two windows."))
  (let ((dst-window (car (window-list)))
        (src-window (cadr (window-list))))
    (bize-mode)
    (with-selected-window src-window
      (bize-mode))))

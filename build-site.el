;;; packages
;;;; Initialize the package system
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(package-refresh-contents)

;; Check and install dependencies
(dolist (package '(htmlize ox-rss webfeeder esxml))
  (unless (package-installed-p package)
    (package-install package)))

;; Load publishing system
(require 'ox-publish)
(require 'ox-rss)
(require 'webfeeder)
(require 'esxml)

;;; Sitemap preprocessing
;;;; Get Preview

;; modify with an "if error skip" logic
;; still need conditional
(defun my/get-preview (file)
  "get preview text from a file

Uses the function here as a starting point:
https://ogbe.net/blog/blogging_with_org.html"
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (re-search-forward "^#\\+BEGIN_PREVIEW$" nil 1)
      (goto-char (point-min))
      (let ((beg (+ 1 (re-search-forward "^#\\+BEGIN_PREVIEW$" nil 1)))
            (end (progn (re-search-forward "^#\\+END_PREVIEW$" nil 1)
                        (match-beginning 0))))
        (buffer-substring beg end)))))

;;;; Format Sitemap
(defun my/org-publish-org-sitemap (title list)
  "Sitemap generation function."
  (concat "#+OPTIONS: toc:nil")
  (org-list-to-subtree list))

(defun my/org-publish-org-sitemap-format (entry style project)
  "Custom sitemap entry formatting: add date"
  (cond ((not (directory-name-p entry))
         (let ((preview (if (my/get-preview (concat "content/" entry))
                            (my/get-preview (concat "content/" entry))
                          "(No preview)")))
         (format "[[file:%s][(%s) %s]]\n%s"
                 entry
                 (format-time-string "%Y-%m-%d"
                                     (org-publish-find-date entry project))
                 (org-publish-find-title entry project)
                 preview)))
        ((eq style 'tree)
         ;; Return only last subdir.
         ;; ends up as a headline at higher level than the posts
         ;; it contains
         (file-name-nondirectory (directory-file-name entry)))
        (t entry)))

(defun file-contents (file)
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

;;; define publishing project
(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory "/home/javier/repos/jpacheco.xyz/content"
             :publishing-directory "./"
             :publishing-function 'org-html-publish-to-html
             :html-preamble (file-contents "/home/javier/repos/jpacheco.xyz/assets/html_preamble.html")
             :with-author nil
             :with-creator t
             :with-toc t
             :section-numbers nil
             :time-stamp-file nil
             :auto-sitemap t
             :sitemap-title nil
             :sitemap-format-entry 'my/org-publish-org-sitemap-format
             :sitemap-function 'my/org-publish-org-sitemap
             :sitemap-sort-files 'anti-chronologically
             :sitemap-filename "sitemap.org"
             :sitemap-style 'tree
             :html-doctype "html5"
             :html-html5-fancy t
             :htmlized-source t
             :exclude "/home/javier/repos/jpacheco.xyz/posts/drafts/.*"  ; Exclude drafts directory from publishing
             )
       (list "org-site:static"
             :base-directory "/home/javier/repos/jpacheco.xyz/content/"
             :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|svg"
             :publishing-directory "./"
             :recursive t
             :publishing-function 'org-publish-attachment
             :exclude "/home/javier/repos/jpacheco.xyz/posts/drafts/.*"  ; Exclude drafts directory from publishing
             )
        ))

;;; additional settings
(setq org-html-validation-link nil
      org-html-htmlize-output-type 'css
      org-html-style-default (file-contents "/home/javier/repos/jpacheco.xyz/assets/head.html")
      org-export-use-babel nil)

;;; generate site output
(org-publish-all t)

(message "Build Complete!")

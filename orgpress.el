(setq exec-path (split-string (getenv "PATH") ":"))
(require 'package) ;; You might already have this line
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(package-initialize) ;; You might already have this line
(package-refresh-contents)

(package-install 'org-plus-contrib)
(package-install 'scala-mode)
(package-install 'haskell-mode)
(package-install 'ox-tufte)
(package-install 'htmlize)
(package-install 'color-theme-modern)
(package-install 'clojure-mode)

(deftheme gtk-ide "gtk-ide theme")
(load-theme 'gtk-ide t t)
(enable-theme 'gtk-ide)
(require 'org)
(require 'scala-mode)
(require 'haskell-mode)
(require 'clojure-mode)
(require 'ob-shell)
(require 'ob-ruby)
(require 'htmlize)
(require 'ox-rss)

(load-file "config.el")
(setq make-backup-files nil)
(setq debug-on-error t)
(setq blog-path (expand-file-name "org"))
(setq assets-path (expand-file-name "assets"))
(setq org-html-validation-link nil)
(setq org-confirm-babel-evaluate nil)

(setq user-mail-address "oyanglulu@gmail.com")
;;(setq org-export-babel-evaluate nil)
(custom-set-variables
  '(org-publish-timestamp-directory
     (convert-standard-filename "public/.org-timestamps/")))
(setq postamble (with-temp-buffer
                  (insert-file-contents "html/postamble.html")
                  (buffer-string)))
(setq preamble (with-temp-buffer
                  (insert-file-contents "html/preamble.html")
                  (buffer-string)))
(setq header (with-temp-buffer
                  (insert-file-contents "html/header.html")
               (buffer-string)))

(defun my-publish-sitemap (title list)
  "Default site map, as a string.
TITLE is the the title of the site map.  LIST is an internal
representation for the files to include, as returned by
`org-list-to-lisp'.  PROJECT is the current project."
  (concat "#+TITLE:" config-blog-title "\n" "#+OPTIONS: toc:nil\n\n"
	  (org-list-to-subtree (rest list))))

(defun my-sitemap-format (entry style project)
  "Custom sitemap entry formatting"
  (if (not (directory-name-p entry))
    (format-spec "
[[%l][%t]]
:PROPERTIES:
:HTML_CONTAINER_CLASS: blogentry
:RSS_PERMALINK: %L
:PUBDATE: %D
:END:
" `((?t . ,(org-publish-find-title entry project))
                 (?D . ,(format-time-string "<%Y-%m-%d %a>" (org-publish-find-date entry project)))
                 (?c . ,(org-publish-find-property entry :subtitle project))
                 (?l . ,(concat "file:" entry))
                 (?L . ,(replace-regexp-in-string "\.org" "\.html" entry))
                 ))
    "--- Oops ---"))

(defun set-org-publish-project-alist ()
  "Set publishing projects for Orgweb and Worg."
  (interactive)
  (setq org-publish-project-alist
    `(("blog-notes"
       ;; Directory for source files in org format
        :language "zh"
        :base-directory ,blog-path
        :base-extension "org"
        :html-doctype "html5"
        :html-head ,header
        :html-html5-fancy t
        :html-preamble ,preamble
        :html-postamble ,postamble
        ;; HTML directory
        :publishing-directory "public"
        :publishing-function org-html-publish-to-tufte-html
        :recursive t
        :headline-levels 4
        :with-sub-superscript nil
        :section-numbers nil
        :auto-preamble nil
        :auto-sitemap t
        :sitemap-style list
        :sitemap-sort-folders ignore
        :sitemap-sort-files anti-chronologically
        :sitemap-format-entry my-sitemap-format
        :sitemap-function my-publish-sitemap
        :sitemap-filename "index.org"
        :exclude "\!.*\.org"
        :sitemap-date-format ,config-date-format
        :makeindex nil
        :html-head-include-default-style nil
        )

       ("blog-static"
         :base-directory ,blog-path
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|svg\\|pdf\\|mp3\\|woff2\\|woff"
         :publishing-directory "public"
         :recursive t
         :publishing-function org-publish-attachment
         )
       ("assets"
         :base-directory ,assets-path
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|svg\\|pdf\\|mp3\\|woff2\\|woff\\|html\\|md\\|ico"
         :publishing-directory "public"
         :recursive t
         :publishing-function org-publish-attachment
         )
       ("rss"
         :base-directory ,blog-path
         :base-extension "org"
         :html-link-home ,config-base-url
         :html-link-use-abs-url t
         :rss-extension "xml"
         :publishing-directory "public"
         :publishing-function (org-rss-publish-to-rss)
         :section-numbers nil
         :exclude ".*"            ;; To exclude all files...
         :include ("index.org")   ;; ... except index.org.
         :table-of-contents nil)
       ("blog" :components ("blog-notes" "assets" "blog-static" "rss"))
       )))
(set-org-publish-project-alist)

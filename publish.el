;; User data
(setq user-full-name "Fabian Brosda"
      user-mail-address "fabian.brosda@gmail.com"
      user-home-address "Missener Str. 7 1/2, 87509 Immenstadt, Deutschland"
      user-blog-domain "http://fbrosda.github.io")

;; Org publish configuration
(add-to-list 'load-path "./bin")

(require 'project)
(require 'ox-publish)
(require 'ox-rss)
(require 'htmlize)

(set-language-environment 'German)
(prefer-coding-system 'utf-8)

(defun file-to-string (filename root-dir)
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name filename root-dir))
    (buffer-string)))

(defun org-rss-publish-feed (plist filename pub-dir)
  (if (equal "rss.org" (file-name-nondirectory filename))
      (org-rss-publish-to-rss plist filename pub-dir)))

(defun org-rss-format-entry (entry style project)
  "Format ENTRY for the RSS feed. ENTRY is a file name.  STYLE is
either 'list' or 'tree'. PROJECT is the current project."
  (cond ((not (directory-name-p entry))
         (let* ((file (org-publish--expand-file-name entry project))
                (title (org-publish-find-title entry project))
                (date (format-time-string "%Y-%m-%d" (org-publish-find-date entry project)))
                (link (concat "posts/" (file-name-sans-extension entry) ".html")))
           (with-temp-buffer
             (org-mode)
             (insert (format "* %s\n" title))

             (org-set-property "ID" link)
             (org-set-property "RSS_PERMALINK" link)
             (org-set-property "PUBDATE" date)
             (buffer-string))))
        (t entry)))

(defun org-rss-format-feed (title list)
  "Generate RSS feed, as a string. TITLE is the title of the RSS
feed.  LIST is an internal representation for the files to
include, as returned by `org-list-to-lisp'.  PROJECT is the
current project."
  (concat "#+TITLE: " title "\n\n"
          (org-list-to-subtree list 1 '(:icount "" :istart ""))))

(defun sitemap-function (title list)
  (concat "#+TITLE: " title "\n"
          "#+HTML_CONTENT_CLASS: sitemap\n"
          "Eine alphabetisch sortierte Liste aller verfasster Artikel:\n\n"
	      (org-list-to-org
           (org-remove-if
            (lambda (elem)
              (and (listp elem) (null (car elem))))
            list))))

(defun sitemap-format-entry (filename style project)
  (if (string-prefix-p "posts/" filename)
      (let ((title (org-publish-find-title filename project))
            (date (format-time-string "%a %d %B %Y"
                                      (org-publish-find-date filename project))))
        (format "[[file:%s][%s]] %s" filename  title date))
    nil))

(let* ((project-root-dir (project-root (project-current)))
       (publishing-dir (expand-file-name "publish/" project-root-dir))
       (content-dir (expand-file-name "org/" project-root-dir))
       (posts-dir (expand-file-name "posts/" content-dir))
       (css-source "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/style.css\" />")
       (preamble-format (file-to-string "tmpl/header.html" project-root-dir))
       (postamble-format (file-to-string "tmpl/footer.html" project-root-dir)))
  (setq make-backup-files nil
        org-html-doctype "html5"
        org-html-htmlize-output-type 'inline-css
        org-confirm-babel-evaluate nil
        org-export-global-macros `(("author" . ,user-full-name)
                                   ("address" . ,(string-replace "," "@@html:<br>@@" user-home-address))
                                   ("email" . ,(concat "[[mailto:" user-mail-address "][" user-mail-address "]]"))
                                   ("host" . ,user-blog-domain))
        org-publish-project-alist
        `(("content"
           :language "de"
           :base-directory ,content-dir
           :htmlized-source t
           :base-extension "org"
           :exclude "rss.org"
           :publishing-directory ,publishing-dir
           :publishing-function org-html-publish-to-html
           :recursive t
           :auto-preamble t
           :auto-sitemap t
           :sitemap-title "Inhaltsverzeichnis"
           :sitemap-style list
           :sitemap-function sitemap-function
           :sitemap-format-entry sitemap-format-entry
           :html-head ,css-source
           :html-head-include-default-style nil
           :with-toc nil
           :section-numbers nil
           :html-postamble t
           :html-postamble-format
           (("de" ,postamble-format))
           :html-preamble t
           :html-preamble-format
           (("de" ,preamble-format)))
          ("rss"
           :language "de"
           :base-directory ,posts-dir
           :base-extension "org"
           :html-link-home ,user-blog-domain
           :html-link-use-abs-url t
           :publishing-directory ,publishing-dir
           :publishing-function org-rss-publish-feed
           :auto-sitemap t
           :rss-extension "xml"
           :rss-image-url ,(concat user-blog-domain "/favicon.ico")
           :section-numbers nil
           :sitemap-title ,(concat (user-full-name) "'s Feed")
           :sitemap-filename "rss.org"
           :sitemap-style list
           :sitemap-sort-files anti-chronologically
           :sitemap-function org-rss-format-feed
           :sitemap-format-entry org-rss-format-entry)
          ("all" :components ("content" "rss")))))

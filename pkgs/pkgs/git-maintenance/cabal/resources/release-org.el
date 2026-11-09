;;; release-org.el --- Org export for git-gm -*- lexical-binding: t; -*-

(require 'org)
(require 'ox-gfm)
(require 'subr-x)

(defun git-gm-release-org-render (source)
  "Export Org SOURCE as a GitHub Markdown release body."
  (let ((org-export-use-babel nil)
        (org-export-with-title nil)
        (org-export-with-author nil)
        (org-export-with-date nil)
        (org-export-with-toc nil))
    (let ((markdown
           (string-trim
            (org-export-string-as
             source 'gfm t
             '(:with-title
               nil
               :with-author nil
               :with-date nil
               :with-toc nil)))))
      (when (string-empty-p markdown)
        (error "Org export produced empty Markdown"))
      (concat markdown "\n"))))

(defun git-gm-release-org-export ()
  "Read Org from stdin and write GitHub Markdown to stdout."
  (let ((coding-system-for-read 'utf-8)
        (coding-system-for-write 'utf-8))
    (with-temp-buffer
      (insert-file-contents "/dev/stdin")
      (princ (git-gm-release-org-render (buffer-string))))))

(provide 'release-org)
;;; release-org.el ends here

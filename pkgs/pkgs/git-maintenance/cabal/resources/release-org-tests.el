;;; release-org-tests.el --- Tests for git-gm Org export -*- lexical-binding: t; -*-
(require 'ert)
(require 'release-org)

(ert-deftest git-gm-org-renders-headlines ()
  (let ((result
         (git-gm-release-org-render
          "#+TITLE: Test\n* Overview\nHello.\n")))
    (should (string-match-p "# Overview" result))
    (should (string-match-p "Hello\\." result))
    (should-not (string-match-p "# Test" result))))

(ert-deftest git-gm-org-rejects-empty ()
  (should-error (git-gm-release-org-render "")))

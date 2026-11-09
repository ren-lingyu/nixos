module Main (main) where

import System.Process (callProcess)

main :: IO ()
main =
    callProcess
        "emacs"
        [ "--batch"
        , "--load"
        , "resources/release-org.el"
        , "--load"
        , "resources/release-org-tests.el"
        , "--funcall"
        , "ert-run-tests-batch-and-exit"
        ]

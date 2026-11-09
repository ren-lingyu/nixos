{-# LANGUAGE TemplateHaskell #-}

module GitGM.System.ExternalTools (
    gitExecutable,
    ghExecutable,
    emacsExecutable,
) where

import Data.Maybe (fromMaybe)
import Language.Haskell.TH.Syntax (lift, runIO)
import System.Environment (lookupEnv)

gitExecutable :: FilePath
gitExecutable =
    $( do
        executable <- runIO (fromMaybe "git" <$> lookupEnv "GIT")
        lift executable
     )

ghExecutable :: FilePath
ghExecutable =
    $( do
        executable <- runIO (fromMaybe "gh" <$> lookupEnv "GH")
        lift executable
     )

emacsExecutable :: FilePath
emacsExecutable =
    $( do
        executable <- runIO (fromMaybe "emacs" <$> lookupEnv "EMACS")
        lift executable
     )

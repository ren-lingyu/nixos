module Main (main) where

import GitGM.Release (runRelease)
import System.Environment (getArgs)

main :: IO ()
main = getArgs >>= runRelease

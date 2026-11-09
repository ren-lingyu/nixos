module Main (main) where

import Control.Exception (bracket)
import Control.Monad (unless)
import Data.List (isInfixOf)
import GitGM.Release (runRelease)
import System.Directory (createDirectory, createDirectoryIfMissing, getTemporaryDirectory, removeFile, removePathForcibly)
import System.Environment (getArgs, getEnvironment, getExecutablePath, lookupEnv)
import System.Exit (ExitCode (..))
import System.FilePath ((</>))
import System.IO (hClose, openTempFile)
import System.Process (CreateProcess (cwd, env), callProcess, proc, readCreateProcessWithExitCode)

main :: IO ()
main = do
    arguments <- getArgs
    case arguments of
        "--run-git-gm" : command -> runRelease command
        [] -> testRender
        _ -> fail "Unexpected render test arguments"

-- Use the same command entry point as app/Main.hs.  Spawning the test
-- executable avoids assuming that Cabal installs git-gm into PATH.
testRender :: IO ()
testRender = withTemporaryDirectory $ \repo -> do
    gitExecutable <- maybe "git" id <$> lookupEnv "GIT"
    let git args = callProcess gitExecutable (["-C", repo] ++ args)
        manuscript version = repo </> "CHANGELOGS" </> (version ++ ".org")
    callProcess gitExecutable ["init", "--initial-branch=main", repo]
    git ["remote", "add", "origin", "git@github.com:example/repo.git"]
    git ["config", "user.name", "git-gm test"]
    git ["config", "user.email", "git-gm@example.invalid"]
    createDirectoryIfMissing True (repo </> "CHANGELOGS")

    writeFile (manuscript "v0.1.0") "#+TITLE: First release\n* Initial\nFirst release notes.\n"
    git ["add", "CHANGELOGS"]
    git ["-c", "commit.gpgSign=false", "commit", "-m", "first release"]
    git ["tag", "v0.1.0"]

    writeFile (manuscript "v0.2.0") "#+TITLE: Second release\n* Changes\nOriginal second release notes.\n"
    git ["add", "CHANGELOGS"]
    git ["-c", "commit.gpgSign=false", "commit", "-m", "second release"]
    git ["tag", "v0.2.0"]

    -- The origin is deliberately unreachable: previews must use only local Git data.
    first <- render repo ["release", "render", "create", "v0.1.0"]
    assert "first release source" ("**Source**: https://github.com/example/repo/tree/v0.1.0" `isInfixOf` first)
    assert "first release history" ("**Full Changelog**: https://github.com/example/repo/commits/v0.1.0" `isInfixOf` first)
    assert "first release has no comparison" (not ("/compare/" `isInfixOf` first))
    assert "first release manuscript" ("First release notes." `isInfixOf` first)

    second <- render repo ["release", "render", "create", "v0.2.0"]
    assert "second release comparison" ("**Full Changelog**: https://github.com/example/repo/compare/v0.1.0...v0.2.0" `isInfixOf` second)
    assert "create reads tag" ("Original second release notes." `isInfixOf` second)

    writeFile (manuscript "v0.2.0") "#+TITLE: Second release\n* Changes\nCorrected second release notes.\n"
    git ["add", "CHANGELOGS"]
    git ["-c", "commit.gpgSign=false", "commit", "-m", "correct release notes"]
    updated <- render repo ["release", "render", "update", "v0.2.0"]
    assert "update reads local HEAD" ("Corrected second release notes." `isInfixOf` updated)
    assert "update comparison" ("**Full Changelog**: https://github.com/example/repo/compare/v0.1.0...v0.2.0" `isInfixOf` updated)
    firstUpdated <- render repo ["release", "render", "update", "v0.1.0"]
    assert "first release update history" ("**Full Changelog**: https://github.com/example/repo/commits/v0.1.0" `isInfixOf` firstUpdated)
    tagged <- render repo ["release", "render", "create", "v0.2.0"]
    assert "create still reads tag" ("Original second release notes." `isInfixOf` tagged)

render :: FilePath -> [String] -> IO String
render directory args = do
    executable <- getExecutablePath
    inherited <- getEnvironment
    let environment = ("GIT_SSH_COMMAND", "false") : filter ((/= "GIT_SSH_COMMAND") . fst) inherited
    (status, output, diagnostics) <-
        readCreateProcessWithExitCode
            ((proc executable ("--run-git-gm" : args)){cwd = Just directory, env = Just environment})
            ""
    case status of
        ExitSuccess -> pure output
        ExitFailure code -> fail ("git-gm render exited " ++ show code ++ ": " ++ diagnostics)

withTemporaryDirectory :: (FilePath -> IO a) -> IO a
withTemporaryDirectory action = bracket create removePathForcibly action
  where
    create = do
        temporary <- getTemporaryDirectory
        (path, handle) <- openTempFile temporary "git-gm-render-"
        hClose handle
        removeFile path
        createDirectory path
        pure path

assert :: String -> Bool -> IO ()
assert description condition = unless condition (fail ("Failed: " ++ description))

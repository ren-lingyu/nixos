{-# LANGUAGE OverloadedStrings #-}

module GitGM.Release (
    runRelease,
    githubRepository,
    RemoteSnapshot (..),
    parseRemoteSnapshot,
) where

import Control.Exception (IOException, displayException, try)
import Control.Monad (forM, unless, when)
import Data.Aeson (encode, object, (.=))
import qualified Data.ByteString.Lazy as BL
import Data.Char (isSpace)
import Data.List (find, intercalate, isSuffixOf, nub, stripPrefix)
import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import GitGM.System.ExternalTools (emacsExecutable, ghExecutable, gitExecutable)
import GitGM.Version (Version, parseVersion, previousVersion)
import Paths_git_maintenance (getDataFileName)
import System.Exit (ExitCode (..), die)
import System.Process (proc, readCreateProcessWithExitCode)

data Mode = Create | Update deriving (Eq, Show)

-- Rendering is a local preview; publishing verifies origin before writing.
data Verification = LocalPreview | CheckOrigin

data Command = Publish Mode [String] | Render Mode String
    deriving (Show)

data RemoteSnapshot = RemoteSnapshot
    { remoteDefaultBranch :: String
    , remoteDefaultSha :: String
    , remoteTags :: [(String, String)]
    }
    deriving (Eq, Show)

data Context = Context
    { repository :: String
    , updateSourceSha :: String
    , versions :: [(String, Version)]
    , remoteSnapshot :: Maybe RemoteSnapshot
    }

data Plan = Plan
    { planTag :: String
    , planBody :: String
    }

runRelease :: [String] -> IO ()
runRelease arguments = case parseCommand arguments of
    Left problem -> die ("git-gm: " ++ problem ++ "\n" ++ usage)
    Right Nothing -> putStr usage
    Right (Just command) ->
        case command of
            Render mode tag -> do
                context <- inspectRepository LocalPreview
                plan <- prepare context mode tag
                putStr (planBody plan)
            Publish mode tags -> do
                context <- inspectRepository CheckOrigin
                -- Complete all local and remote preflight work before any write.
                plans <- mapM (prepare context mode) tags
                releases <- forM plans $ \plan -> do
                    identifier <- findRelease (repository context) (planTag plan)
                    case (mode, identifier) of
                        (Create, Just _) -> die ("Release already exists: " ++ planTag plan)
                        (Update, Nothing) -> die ("Release does not exist: " ++ planTag plan)
                        _ -> pure (plan, identifier)
                failures <- forM releases $ \(plan, identifier) -> do
                    outcome <- try (publish mode (repository context) plan identifier)
                    case outcome of
                        Right () -> do
                            putStrLn ("Succeeded: " ++ show mode ++ " " ++ planTag plan)
                            pure Nothing
                        Left err -> do
                            let problem = planTag plan ++ ": " ++ displayException (err :: IOException)
                            putStrLn ("Failed: " ++ problem)
                            pure (Just problem)
                let errors = [problem | Just problem <- failures]
                unless (null errors) $ die ("Release operations failed: " ++ intercalate "; " errors)

usage :: String
usage =
    unlines
        [ "Usage: git gm release create <vX.Y.Z> [--backend github]"
        , "       git gm release update <vX.Y.Z>... [--backend github]"
        , "       git gm release render create <vX.Y.Z> [--backend github]"
        , "       git gm release render update <vX.Y.Z> [--backend github]"
        ]

parseCommand :: [String] -> Either String (Maybe Command)
parseCommand args = do
    commandArgs <- case break (== "--backend") args of
        (before, []) -> Right before
        (before, ["--backend", "github"]) -> Right before
        _ -> Left "Only the GitHub backend is currently supported"
    case commandArgs of
        ["--help"] -> Right Nothing
        ["release", "--help"] -> Right Nothing
        ["release", "create", tag] -> do
            versionTag <- valid tag
            pure (Just (Publish Create [versionTag]))
        "release" : "update" : tags@(_ : _) -> do
            when (length (nub tags) /= length tags) (Left "Duplicate release versions")
            versionTags <- mapM valid tags
            pure (Just (Publish Update versionTags))
        ["release", "render", "create", tag] -> do
            versionTag <- valid tag
            pure (Just (Render Create versionTag))
        ["release", "render", "update", tag] -> do
            versionTag <- valid tag
            pure (Just (Render Update versionTag))
        _ -> Left "Invalid release command"
  where
    valid tag = case parseVersion tag of
        Nothing -> Left ("Invalid stable release tag: " ++ tag)
        Just _ -> Right tag

runTool :: FilePath -> [String] -> String -> IO String
runTool tool args input = do
    (status, output, diagnostics) <- readCreateProcessWithExitCode (proc tool args) input
    case status of
        ExitSuccess -> pure output
        ExitFailure code ->
            ioError (userError (tool ++ " exited " ++ show code ++ ": " ++ diagnostics))

git :: [String] -> IO String
git args = runTool gitExecutable args ""

gh :: [String] -> String -> IO String
gh args input = runTool ghExecutable args input

inspectRepository :: Verification -> IO Context
inspectRepository verification = do
    inside <- trim <$> git ["rev-parse", "--is-inside-work-tree"]
    unless (inside == "true") $ die "Not inside a Git worktree"
    remoteUrl <- trim <$> git ["remote", "get-url", "origin"]
    repo <- either die pure (githubRepository remoteUrl)
    snapshot <- case verification of
        LocalPreview -> pure Nothing
        CheckOrigin -> do
            output <- git ["ls-remote", "--symref", "origin"]
            Just <$> either die pure (parseRemoteSnapshot output)
    -- Preview update reads the checked-out commit, not the working tree.
    sha <- case snapshot of
        Nothing -> trim <$> git ["rev-parse", "--verify", "HEAD^{commit}"]
        Just value -> synchronizedDefaultSha value
    names <- lines <$> git ["for-each-ref", "--format=%(refname:strip=2)", "refs/tags"]
    pure (Context repo sha (mapMaybe (\name -> fmap ((,) name) (parseVersion name)) names) snapshot)

-- Verify the checked-out default branch against one complete remote ref snapshot.
synchronizedDefaultSha :: RemoteSnapshot -> IO String
synchronizedDefaultSha snapshot = do
    let branch = remoteDefaultBranch snapshot
    localSha <- trim <$> git ["rev-parse", "--verify", "refs/heads/" ++ branch ++ "^{commit}"]
    unless (remoteDefaultSha snapshot == localSha) $
        die ("Local " ++ branch ++ " is not synchronized with origin/" ++ branch)
    pure localSha

-- Parse the complete output of `git ls-remote --symref origin`.
-- Peeled annotated-tag records are deliberately excluded: the direct tag ref
-- is the value compared with `git rev-parse refs/tags/<tag>`.
parseRemoteSnapshot :: String -> Either String RemoteSnapshot
parseRemoteSnapshot output = do
    branch <-
        exactlyOne
            "origin's default branch"
            [ name
            | line <- lines output
            , ["ref:", ref, "HEAD"] <- [words line]
            , Just name <- [stripPrefix "refs/heads/" ref]
            , not (null name)
            ]
    headSha <-
        exactlyOne
            "origin's default branch HEAD"
            [ sha
            | line <- lines output
            , [sha, "HEAD"] <- [words line]
            ]
    branchSha <-
        exactlyOne
            "origin's default branch ref"
            [ sha
            | line <- lines output
            , [sha, ref] <- [words line]
            , ref == "refs/heads/" ++ branch
            ]
    unlessEither
        (headSha == branchSha)
        "origin's symbolic HEAD does not match its default branch ref"
    let tags =
            [ (name, sha)
            | line <- lines output
            , [sha, ref] <- [words line]
            , Just name <- [stripPrefix "refs/tags/" ref]
            , not ("^{}" `isSuffixOf` name)
            ]
    unlessEither
        (length tags == length (nub (map fst tags)))
        "origin returned duplicate tag refs"
    pure (RemoteSnapshot branch headSha tags)
  where
    exactlyOne description values = case values of
        [value] -> Right value
        _ -> Left ("Cannot identify " ++ description)

    unlessEither condition problem
        | condition = Right ()
        | otherwise = Left problem

-- Explicitly identify the repository from origin, never from gh's ambient default.
githubRepository :: String -> Either String String
githubRepository remote =
    case mapMaybe
        (`stripPrefix` remote)
        [ "https://github.com/"
        , "git@github.com:"
        , "ssh://git@github.com/"
        ] of
        [path] ->
            let name = if ".git" `isSuffixOf` path then take (length path - 4) path else path
                parts = splitSlash name
             in case parts of
                    [owner, repo]
                        | all validPart [owner, repo] -> Right (owner ++ "/" ++ repo)
                    _ -> Left "origin must be a github.com OWNER/REPO URL"
        _ -> Left "GitHub backend requires a github.com origin remote"
  where
    validPart value =
        not (null value)
            && all
                ( \c ->
                    c >= 'A' && c <= 'Z'
                        || c >= 'a' && c <= 'z'
                        || c >= '0' && c <= '9'
                        || c == '-'
                        || c == '_'
                        || c == '.'
                )
                value
    splitSlash input = case break (== '/') input of
        (part, []) -> [part]
        (part, _ : rest) -> part : splitSlash rest

trim :: String -> String
trim = reverse . dropWhile isSpace . reverse

requireTag :: Context -> String -> IO String
requireTag context tag = do
    let ref = "refs/tags/" ++ tag
    local <- trim <$> git ["rev-parse", "--verify", ref]
    case remoteSnapshot context of
        Nothing -> pure local
        Just snapshot ->
            case lookup tag (remoteTags snapshot) of
                Just remote | remote == local -> pure local
                Nothing -> die ("Tag is not present on origin: " ++ tag)
                _ -> die ("Local and remote tag differ: " ++ tag)

prepare :: Context -> Mode -> String -> IO Plan
prepare context mode tag = do
    version <- case lookup tag (versions context) of
        Just value -> pure value
        Nothing -> die ("Missing local release tag: " ++ tag)
    tagOid <- requireTag context tag
    let previous = previousVersion version (map snd (versions context))
        previousTag = case previous of
            Nothing -> Nothing
            Just value -> fmap fst (find ((== value) . snd) (versions context))
    case previousTag of
        Nothing -> pure ()
        Just name -> do
            _ <- requireTag context name
            pure ()
    sha <- case mode of
        Create -> trim <$> git ["rev-parse", "--verify", tagOid ++ "^{commit}"]
        Update -> pure (updateSourceSha context)
    manuscript <- git ["show", sha ++ ":CHANGELOGS/" ++ tag ++ ".org"]
    when (all isSpace manuscript) $ die ("Empty manuscript: " ++ tag)
    exported <- renderOrg manuscript
    let base = "https://github.com/" ++ repository context
        source = "**Source**: " ++ base ++ "/tree/" ++ tag ++ "\n\n"
        comparison = case previousTag of
            Nothing -> "**Full Changelog**: " ++ base ++ "/commits/" ++ tag ++ "\n\n"
            Just previousName ->
                "**Full Changelog**: " ++ base ++ "/compare/" ++ previousName ++ "..." ++ tag ++ "\n\n"
    pure (Plan tag (source ++ comparison ++ exported))

renderOrg :: String -> IO String
renderOrg source = do
    path <- getDataFileName "resources/release-org.el"
    runTool emacsExecutable ["--batch", "--load", path, "--funcall", "git-gm-release-org-export"] source

findRelease :: String -> String -> IO (Maybe String)
findRelease repo tag = do
    let query = ".[] | select(.tag_name == \"" ++ tag ++ "\") | .id"
    response <- gh ["api", "--hostname", "github.com", "repos/" ++ repo ++ "/releases?per_page=100", "--paginate", "--jq", query] ""
    case lines (trim response) of
        [] -> pure Nothing
        [value] | not (null value) && all (\c -> c >= '0' && c <= '9') value -> pure (Just value)
        _ -> die ("Unexpected release lookup result: " ++ tag)

publish :: Mode -> String -> Plan -> Maybe String -> IO ()
publish Create repo plan Nothing = do
    _ <-
        gh
            [ "release"
            , "create"
            , planTag plan
            , "--repo"
            , "github.com/" ++ repo
            , "--verify-tag"
            , "--title"
            , planTag plan
            , "--latest"
            , "--notes-file"
            , "-"
            ]
            (planBody plan)
    pure ()
publish Update repo plan (Just identifier) = do
    let body = T.pack (planBody plan)
        payload = T.unpack (TE.decodeUtf8 (BL.toStrict (encode (object ["body" .= body]))))
    _ <- gh ["api", "--hostname", "github.com", "-X", "PATCH", "repos/" ++ repo ++ "/releases/" ++ identifier, "--input", "-"] payload
    pure ()
publish _ _ _ _ = die "Internal release state mismatch"

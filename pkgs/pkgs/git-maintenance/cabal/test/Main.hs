module Main (main) where

import Control.Monad (unless)
import GitGM.Release (RemoteSnapshot (..), githubRepository, parseRemoteSnapshot)
import GitGM.Version (parseVersion, previousVersion)

main :: IO ()
main = do
    let versions = map parseVersion ["v0.1.0", "v0.9.0", "v0.10.0", "v1.0.0"]
    assert "valid versions" (all (/= Nothing) versions)
    assert "numeric version ordering" (parseVersion "v0.9.0" < parseVersion "v0.10.0")
    assert "first release" (previousVersion (expect "v0.1.0") values == Nothing)
    assert "middle predecessor" (previousVersion (expect "v0.10.0") values == Just (expect "v0.9.0"))
    assert "major predecessor" (previousVersion (expect "v1.0.0") values == Just (expect "v0.10.0"))
    assert "https remote" (githubRepository "https://github.com/owner/repo.git" == Right "owner/repo")
    assert "SSH remote" (githubRepository "git@github.com:owner/repo.git" == Right "owner/repo")
    assert "reject other host" (either (const True) (const False) (githubRepository "https://gitlab.com/owner/repo"))
    let branchSha = replicate 40 'a'
        firstTagSha = replicate 40 'b'
        secondTagSha = replicate 40 'c'
        peeledTagSha = replicate 40 'd'
        remoteOutput =
            unlines
                [ "ref: refs/heads/main\tHEAD"
                , branchSha ++ "\tHEAD"
                , branchSha ++ "\trefs/heads/main"
                , firstTagSha ++ "\trefs/tags/v0.1.0"
                , secondTagSha ++ "\trefs/tags/v0.2.0"
                , peeledTagSha ++ "\trefs/tags/v0.2.0^{}"
                ]
    snapshot <- case parseRemoteSnapshot remoteOutput of
        Right value -> pure value
        Left problem -> error ("Cannot parse remote snapshot: " ++ problem)
    assert
        "remote snapshot includes default branch and direct tag refs"
        ( snapshot
            == RemoteSnapshot
                "main"
                branchSha
                [("v0.1.0", firstTagSha), ("v0.2.0", secondTagSha)]
        )
    let missingHead =
            unlines
                [ branchSha ++ "\tHEAD"
                , branchSha ++ "\trefs/heads/main"
                ]
        duplicateTag = remoteOutput ++ firstTagSha ++ "\trefs/tags/v0.1.0\n"
    assert
        "remote snapshot rejects missing symbolic HEAD"
        (either (const True) (const False) (parseRemoteSnapshot missingHead))
    assert
        "remote snapshot rejects inconsistent default branch"
        (either (const True) (const False) (parseRemoteSnapshot (replaceBranchSha remoteOutput)))
    assert
        "remote snapshot rejects duplicate tag refs"
        (either (const True) (const False) (parseRemoteSnapshot duplicateTag))
    mapM_
        (\invalid -> assert ("reject " ++ invalid) (parseVersion invalid == Nothing))
        ["0.1.0", "v00.1.0", "v0.01.0", "v0.0.01", "v1.2", "v1.2.3-rc.1", "v1.2.3+build", "v1.2.3.4", "v-1.2.3", "v1.2.3x"]
  where
    values = [expect "v0.1.0", expect "v0.9.0", expect "v0.10.0", expect "v1.0.0"]
    expect input = case parseVersion input of
        Just version -> version
        Nothing -> error ("Invalid test version: " ++ input)
    assert title passed = unless passed (error ("Failed: " ++ title))
    replaceBranchSha output =
        case lines output of
            first : headLine : _ : rest ->
                unlines (first : headLine : (replicate 40 'e' ++ "\trefs/heads/main") : rest)
            _ -> output

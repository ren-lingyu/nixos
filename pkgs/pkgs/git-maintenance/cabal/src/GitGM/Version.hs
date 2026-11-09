module GitGM.Version (
    Version,
    parseVersion,
    previousVersion,
) where

import Data.List (stripPrefix)
import Text.Read (readMaybe)

data Version = Version Integer Integer Integer
    deriving (Eq, Ord, Show)

-- Only canonical, stable vX.Y.Z tags participate in the local release order.
parseVersion :: String -> Maybe Version
parseVersion value = do
    body <- stripPrefix "v" value
    case splitDots body of
        [major, minor, patch] ->
            Version <$> decimal major <*> decimal minor <*> decimal patch
        _ -> Nothing
  where
    decimal [] = Nothing
    decimal ('0' : _ : _) = Nothing
    decimal digits
        | all (\c -> c >= '0' && c <= '9') digits = readMaybe digits
        | otherwise = Nothing

    splitDots input = case break (== '.') input of
        (part, []) -> [part]
        (part, _ : rest) -> part : splitDots rest

previousVersion :: Version -> [Version] -> Maybe Version
previousVersion target versions = case filter (< target) versions of
    [] -> Nothing
    earlier -> Just (maximum earlier)

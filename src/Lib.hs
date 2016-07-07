{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( tweet
    , tweetWithMedia
    , printLatestHaskellTweets
    , createFontPreview
    ) where

import TwitterUtilities

import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as Text
import qualified Data.Yaml as Yaml
import Codec.Picture (PixelRGBA8(..), writePng)
import Control.Lens
import Graphics.Rasterific
import Graphics.Rasterific.Texture
import Graphics.Text.TrueType (loadFontFile)
import Text.Regex.Posix
import Web.Twitter.Conduit
import Web.Twitter.Types

tweet :: IO ()
tweet = do
  let status = Text.pack "Hello World from Haskell using twitter-conduit!\nhttps://github.com/himura/twitter-conduit"
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ update status
  S8.putStrLn $ Yaml.encode result

tweetWithMedia :: IO ()
tweetWithMedia = do
  let status = Text.pack ""
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ updateWithMedia status (MediaFromFile ".\\font_preview.png")
  S8.putStrLn $ Yaml.encode result

printLatestHaskellTweets :: IO ()
printLatestHaskellTweets = do
  let phrase = Text.pack "Haskell"
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ searchTweets "Haskell" & lang ?~ "en" & count ?~ 10
  parseResult result

parseResult :: SearchResult [SearchStatus] -> IO ()
parseResult (SearchResult statuses metadata) = do
  parseMetadata metadata
  parseStatuses statuses

parseMetadata :: SearchMetadata -> IO ()
parseMetadata
  (SearchMetadata
    searchMetadataMaxId
    searchMetadataSinceId
    searchMetadataRefreshURL
    searchMetadataNextResults
    searchMetadataCount
    searchMetadataCompletedIn
    searchMetadataSinceIdStr
    searchMetadataQuery
    searchMetadataMaxIdStr) = do
  putStrLn "search metadata:"
  putStrLn $ "- query: " ++ (show searchMetadataQuery)

parseStatuses :: [SearchStatus] -> IO ()
parseStatuses [] = do return ()
parseStatuses (x:xs) = do
  let extractedStatus = extractStatus x
  let firstInterestingWord = extractedStatus =~ ("[ \t\r\n\v\f]+[a-zA-Z]{7,10}[ \t\r\n\v\f!?.,-]+" :: String)
  putStrLn "status:"
  putStrLn extractedStatus
  putStrLn "first interesting word:"
  if firstInterestingWord == "" then (parseStatuses xs) else (putStrLn firstInterestingWord)

extractStatus :: SearchStatus -> String
extractStatus
  (SearchStatus
    searchStatusCreatedAt
    searchStatusId
    searchStatusText
    searchStatusSource
    searchStatusUser
    searchStatusCoordinates) = show searchStatusText

createFontPreview :: IO ()
createFontPreview = do
  fontErr <- loadFontFile ".\\fonts\\Exo-Thin.ttf"
  case fontErr of
    Left err -> putStrLn err
    Right font ->
      writePng "font_preview.png" .
          renderDrawing 1024 512 (PixelRGBA8 255 255 255 255)
              . withTexture (uniformTexture $ PixelRGBA8 0 0 0 255) $
                      printTextAt font (PointSize 100) (V2 150 300)
                           "resonates"

{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( tweet
    , printLatestHaskellTweets
    , createPDF
    ) where

import TwitterUtilities

import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as Text
import qualified Data.Yaml as Yaml
import Codec.Picture (PixelRGBA8(..), writePng)
import Control.Lens
import Graphics.Rasterific
import Graphics.Rasterific.Texture
import Graphics.Text.TrueType (loadFontFile )
import Web.Twitter.Conduit
import Web.Twitter.Types

createPDF :: IO ()
createPDF = do
  fontErr <- loadFontFile "C:\\Windows\\Fonts\\segoeui.ttf"
  case fontErr of
    Left err -> putStrLn err
    Right font ->
      writePng "font_preview.png" .
          renderDrawing 300 70 (PixelRGBA8 255 255 255 255)
              . withTexture (uniformTexture $ PixelRGBA8 0 0 0 255) $
                      printTextAt font (PointSize 30) (V2 20 50)
                           "Haskell"

tweet :: IO ()
tweet = do
  let status = Text.pack "Hello World from Haskell using twitter-conduit!\nhttps://github.com/himura/twitter-conduit"
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ update status
  S8.putStrLn $ Yaml.encode result

printLatestHaskellTweets :: IO ()
printLatestHaskellTweets = do
  let phrase = Text.pack "Haskell"
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ searchTweets "Haskell" & lang ?~ "en" & count ?~ 3
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
  putStrLn "status:"
  putStrLn $ (parseStatus x)
  putStrLn "---"
  parseStatuses xs

parseStatus :: SearchStatus -> String
parseStatus
  (SearchStatus
    searchStatusCreatedAt
    searchStatusId
    searchStatusText
    searchStatusSource
    searchStatusUser
    searchStatusCoordinates) = show searchStatusText

{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( tweetWithMedia
    , printLatestHaskellTweets
    , createFontPreview
    ) where

import TwitterUtilities

import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as Text
import qualified Data.Yaml as Yaml
import Codec.Picture (PixelRGBA8(..), writePng)
import Control.Lens
import Data.String.Conv
import Graphics.Rasterific
import Graphics.Rasterific.Texture
import Graphics.Text.TrueType (loadFontFile)
import Text.Regex.Posix
import Web.Twitter.Conduit
import Web.Twitter.Types

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
  result <- call twitterInfo manager $ searchTweets "a" & lang ?~ "en" & count ?~ 10
  parseResult result

parseResult :: SearchResult [SearchStatus] -> IO ()
parseResult (SearchResult statuses metadata) = do
  parseStatuses statuses

parseStatuses :: [SearchStatus] -> IO ()
parseStatuses [] = do return ()
parseStatuses (x:xs) = do
  let expression = "[ \t\r\n\v\f]+[a-zA-Z]{7,10}[ \t\r\n\v\f]+" :: String
  let extractedStatus = extractStatus x
  let firstInterestingWord = extractedStatus =~ expression
  let strippedFirstInterestingWord = toS . Text.strip $ Text.pack firstInterestingWord
  putStrLn $ "status:\n\n" ++ extractedStatus ++ "\n\nfirst interesting word:"
  if firstInterestingWord == "" then (parseStatuses xs) else do
    putStrLn strippedFirstInterestingWord
    createFontPreview strippedFirstInterestingWord
    tweetWithMedia

extractStatus :: SearchStatus -> String
extractStatus
  (SearchStatus
    searchStatusCreatedAt
    searchStatusId
    searchStatusText
    searchStatusSource
    searchStatusUser
    searchStatusCoordinates) = show searchStatusText

createFontPreview :: String -> IO ()
createFontPreview textToRender = do
  fontErr <- loadFontFile ".\\fonts\\Chunkfive.ttf"
  case fontErr of
    Left err -> putStrLn err
    Right font ->
      writePng "font_preview.png" .
          renderDrawing 1024 512 (PixelRGBA8 255 255 255 255)
              . withTexture (uniformTexture $ PixelRGBA8 0 0 0 255) $
                      printTextAt font (PointSize 100) (V2 150 300)
                           textToRender

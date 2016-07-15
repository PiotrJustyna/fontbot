{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( tweetWithMedia
    , printLatestHaskellTweets
    , createFontPreview
    , chooseRandomFont
    ) where

import TwitterUtilities

import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as Text
import qualified Data.Yaml as Yaml
import Codec.Picture (PixelRGBA8(..), writePng)
import Control.Lens
import Data.List
import Data.String.Conv
import Graphics.Rasterific
import Graphics.Rasterific.Texture
import Graphics.Text.TrueType (loadFontFile)
import System.Directory
import System.Random
import Text.Regex.Posix
import Web.Twitter.Conduit
import Web.Twitter.Types

fontPreviewPath = "font_preview.png"

chooseRandomFont :: IO String
chooseRandomFont = do
  paths <- getDirectoryContents ".\\fonts\\"
  let foundFonts = filter (isSuffixOf ".ttf") paths
  randomIndex <- randomRIO (0, (length foundFonts) - 1)
  return $ foundFonts !! randomIndex

tweetWithMedia :: IO ()
tweetWithMedia = do
  let status = Text.pack ""
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ updateWithMedia status (MediaFromFile ".\\font_preview.png")
  S8.putStrLn $ Yaml.encode result

printLatestHaskellTweets :: IO ()
printLatestHaskellTweets = do
  let phrase = Text.pack "a"
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ searchTweets phrase & lang ?~ "en" & count ?~ 10
  parseResult result

parseResult :: SearchResult [SearchStatus] -> IO ()
parseResult (SearchResult statuses metadata) = parseStatuses statuses

parseStatuses :: [SearchStatus] -> IO ()
parseStatuses [] = do return ()
parseStatuses (x:xs) = do
  let expression = "[ \t\r\n\v\f]+[a-zA-Z]{7,10}[ \t\r\n\v\f]+" :: String
  let extractedStatus = extractStatus x
  let firstInterestingWord = extractedStatus =~ expression
  let strippedFirstInterestingWord = toS . Text.strip $ Text.pack firstInterestingWord
  if strippedFirstInterestingWord == "" then (parseStatuses xs) else do
    createFontPreview strippedFirstInterestingWord
    fontPreviewResult <- doesFileExist fontPreviewPath
    if (fontPreviewResult)
      then tweetWithMedia
      else putStrLn "Cannot tweet - did not find font preview file."

extractStatus :: SearchStatus -> String
extractStatus (SearchStatus searchStatusCreatedAt searchStatusId searchStatusText searchStatusSource searchStatusUser searchStatusCoordinates) = toS searchStatusText

createFontPreview :: String -> IO ()
createFontPreview textToRender = do
  fontName <- chooseRandomFont
  fontLoadResult <- loadFontFile $ ".\\fonts\\" ++ fontName
  case fontLoadResult of
    Left errorDescription -> do
      isFileFound <- doesFileExist fontPreviewPath
      if (isFileFound)
        then do
          removeFile fontPreviewPath
          putStrLn ("Cannot load font \"" ++ fontName ++ "\". Reason: " ++ errorDescription)
        else putStrLn "Cannot delete - dit not find font preview file."
    Right font ->
      writePng "font_preview.png" .
      renderDrawing 1024 512 (PixelRGBA8 255 255 255 255) .
      withTexture (uniformTexture $ PixelRGBA8 0 0 0 255) $
      printTextAt font (PointSize 100) (V2 150 300) textToRender

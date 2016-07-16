{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( workYourMagic
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

workYourMagic :: IO ()
workYourMagic = do
  let phrase = Text.pack "a"
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ searchTweets phrase & lang ?~ "en" & count ?~ 10
  let interestingWord = chooseFirstInterestingWordFromSearchResult result
  if interestingWord == ""
    then putStrLn "Cannot find any interesting words."
    else do
      fontName <- chooseRandomFont
      createFontPreview interestingWord fontName
      fontPreviewResult <- doesFileExist fontPreviewPath
      if fontPreviewResult
        then tweetWithMedia
        else putStrLn "Cannot tweet - did not find font preview file."

chooseFirstInterestingWordFromSearchResult :: SearchResult [SearchStatus] -> String
chooseFirstInterestingWordFromSearchResult (SearchResult statuses metadata) = chooseFirstInterestingWordFromSearchStatuses statuses

chooseFirstInterestingWordFromSearchStatuses :: [SearchStatus] -> String
chooseFirstInterestingWordFromSearchStatuses [] = ""
chooseFirstInterestingWordFromSearchStatuses (x:xs) =
  if strippedFirstInterestingWord == ""
    then chooseFirstInterestingWordFromSearchStatuses xs
    else strippedFirstInterestingWord
  where
    expression = "[ \t\r\n\v\f]+[a-zA-Z]{7,10}[ \t\r\n\v\f]+" :: String
    extractedStatus = extractStatusText x
    firstInterestingWord = extractedStatus =~ expression
    strippedFirstInterestingWord = toS . Text.strip $ Text.pack firstInterestingWord

chooseRandomFont :: IO String
chooseRandomFont = do
  paths <- getDirectoryContents ".\\fonts\\"
  let foundFonts = filter (isSuffixOf ".ttf") paths
  randomIndex <- randomRIO (0, (length foundFonts) - 1)
  return $ foundFonts !! randomIndex

createFontPreview :: String -> String -> IO ()
createFontPreview textToRender fontName = do
  fontLoadResult <- loadFontFile $ ".\\fonts\\" ++ fontName
  case fontLoadResult of
    Left errorDescription -> do
      isFileFound <- doesFileExist fontPreviewPath
      if isFileFound
        then do
          removeFile fontPreviewPath
          putStrLn ("Cannot load font \"" ++ fontName ++ "\". Reason: " ++ errorDescription)
        else putStrLn "Cannot delete - dit not find font preview file."
    Right font ->
      writePng fontPreviewPath .
      renderDrawing 1024 512 (PixelRGBA8 255 255 255 255) .
      withTexture (uniformTexture $ PixelRGBA8 0 0 0 255) $
      printTextAt font (PointSize 100) (V2 150 300) textToRender

tweetWithMedia :: IO ()
tweetWithMedia = do
  let status = Text.pack ""
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  status <- call twitterInfo manager $ updateWithMedia status (MediaFromFile fontPreviewPath)
  putStrLn $ extractTweetWithMediaSummary status

{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( greet
    ) where

import qualified Data.ByteString.Char8 as S8
import qualified Network.HTTP.Simple as Conduit
import qualified Data.Yaml as Yaml
import Data.Aeson (Value)
import Data.ByteString.Char8 (pack)
import System.IO

greet :: IO ()
greet = do
  handle <- openFile "c:\\temp\\fontbotauth.txt" ReadMode
  contents <- hGetContents handle
  let request = Conduit.setRequestHeader "Authorization" [pack contents] "POST https://api.twitter.com/1.1/statuses/update.json?status=Hello%20World%20From%20Haskell%20with%20OAuth%20header%20value%20taken%20from%20external%20file%21"
  response <- Conduit.httpJSON request
  S8.putStrLn $ Yaml.encode (Conduit.getResponseBody response :: Value)
  hClose handle

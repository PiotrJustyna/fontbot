module Lib
    ( tweet
    ) where

import TwitterUtilities

import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as Text
import qualified Data.Yaml as Yaml
import Web.Twitter.Conduit

tweet :: IO ()
tweet = do
  twitterInfo <- getTwitterInfoFromEnvironment
  manager <- newManager tlsManagerSettings
  result <- call twitterInfo manager $ update $ Text.pack "Hello World from Haskell using twitter-conduit!\nhttps://github.com/himura/twitter-conduit"
  S8.putStrLn $ Yaml.encode result

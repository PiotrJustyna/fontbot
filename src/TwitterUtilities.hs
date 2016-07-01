{-# LANGUAGE OverloadedStrings #-}

module TwitterUtilities
    ( getTwitterInfoFromEnvironment
    ) where

import qualified Data.ByteString.Char8 as S8
import System.Environment
import Web.Twitter.Conduit

getOAuthTokens :: IO (OAuth, Credential)
getOAuthTokens = do
    consumerKey <- getEnv' "TWITTER_OAUTH_CONSUMER_KEY"
    consumerSecret <- getEnv' "TWITTER_OAUTH_CONSUMER_SECRET"
    accessToken <- getEnv' "TWITTER_OAUTH_ACCESS_TOKEN"
    accessSecret <- getEnv' "TWITTER_OAUTH_ACCESS_SECRET"
    let oauth = twitterOAuth
            { oauthConsumerKey = consumerKey
            , oauthConsumerSecret = consumerSecret
            }
        cred = Credential
            [ ("oauth_token", accessToken)
            , ("oauth_token_secret", accessSecret)
            ]
    return (oauth, cred)
  where
    getEnv' = (S8.pack <$>) . getEnv

getTwitterInfoFromEnvironment :: IO TWInfo
getTwitterInfoFromEnvironment = do
    (oa, cred) <- getOAuthTokens
    return $ setCredential oa cred def

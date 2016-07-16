{-# LANGUAGE OverloadedStrings #-}

module TwitterUtilities
    ( getTwitterInfoFromEnvironment
    , extractStatusText
    , extractTweetWithMediaSummary
    ) where

import qualified Data.ByteString.Char8 as S8
import Data.String.Conv
import System.Environment
import Web.Twitter.Conduit
import Web.Twitter.Types

getTwitterInfoFromEnvironment :: IO TWInfo
getTwitterInfoFromEnvironment = do
    (oa, cred) <- getOAuthTokens
    return $ setCredential oa cred def

extractStatusText :: SearchStatus -> String
extractStatusText
  (SearchStatus
    searchStatusCreatedAt
    searchStatusId
    searchStatusText
    searchStatusSource
    searchStatusUser
    searchStatusCoordinates) = toS searchStatusText

extractTweetWithMediaSummary :: Status -> String
extractTweetWithMediaSummary
  (Status
    statusContributors
    statusCoordinates
    statusCreatedAt
    statusCurrentUserRetwee
    statusEntities
    statusExtendedEntities
    statusFavoriteCount
    statusFavorited
    statusFilterLevel
    statusId
    statusInReplyToScreenName
    statusInReplyToStatusId
    statusInReplyToUserId
    statusLang
    statusPlace
    statusPossiblySensitive
    statusScopes
    statusQuotedStatusId
    statusQuotedStatus
    statusRetweetCount
    statusRetweeted
    statusRetweetedStatus
    statusSource
    statusText
    statusTruncated
    statusUser
    statusWithheldCopyright
    statusWithheldInCountries
    statusWithheldScope) =
      "Status ID: " ++ (show statusId) ++ "\n" ++
      "Created at: " ++ (show statusCreatedAt) ++ "\n" ++
      "URL: " ++ (toS statusText)

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

{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE ScopedTypeVariables        #-}

module Lib where

import           Database.PostgreSQL.Simple
import           Database.PostgreSQL.Simple.Migration
import           GHC.Generics
import           System.Envy

------------------------------------------------------------------------------
data PGConnect = PGConnect {
      pgUser :: String
    , pgPass :: String
    , pgDB   :: String
    , pgPort :: Integer
  } deriving (Generic, Show)

instance FromEnv PGConnect where
  fromEnv =
     PGConnect  <$> env "POSTGRES_USER"
        <*> env "POSTGRES_PASSWORD"
        <*> env "POSTGRES_DB"
        <*> env "POSTGRES_PORT"

mapConInfo :: PGConnect -> ConnectInfo
mapConInfo (PGConnect _ pgPass pgDB pgPort) =
  defaultConnectInfo { connectPassword = pgPass, connectDatabase=pgDB, connectPort = fromInteger pgPort }

getConnInfo :: IO (ConnectInfo)
getConnInfo = do
  env <- decodeEnv
  let asPGS = fmap mapConInfo env
  case asPGS of
    Left e        -> error $ show e
    Right conInfo -> return conInfo

initialize :: IO (MigrationResult String)
initialize = do
  conInfo <- getConnInfo
  con <- connect conInfo
  withTransaction con $ runMigration $
        MigrationContext MigrationInitialization True con


simpleMigration :: IO (MigrationResult String)
simpleMigration = do
    let dir = "./migrations"
    conInfo <- getConnInfo
    con <- connect conInfo
    withTransaction con $ runMigration $
        MigrationContext (MigrationDirectory dir) True con

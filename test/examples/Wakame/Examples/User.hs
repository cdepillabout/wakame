{-# LANGUAGE DuplicateRecordFields #-}
module Wakame.Examples.User where

import Prelude

import Control.Arrow (first, (***))
import Data.Kind
import Data.Proxy
import Data.Text (Text, pack)
import Data.Time (UTCTime, getCurrentTime)
import GHC.Generics
import GHC.TypeLits
import Wakame
import Wakame.Utils (Append)



newtype UserId = UserId Int
  deriving (Eq, Show, Generic)


data User =
  User
  { id    :: UserId
  -- , email :: String
  , password   :: String
  , created_at :: UTCTime
  , updated_at :: UTCTime
  }
  deriving Generic

data UpdatingUser =
  UpdatingUser
  { email    :: String
  -- , password :: String
  }
  deriving Generic

updateUser :: UpdatingUser -> User -> User
updateUser updating user = fromRec $ nub u
  where
    u :: Rec '[ '("email", String), '("password", String)
              , '("id", UserId), '("email", String), '("password", String)
              , '("created_at", UTCTime)
              ]
    u = union (toRec updating) (toRec user)

-- data UpdatedAt = UpdatedAt { updated_at :: UTCTime } deriving Generic

-- touchUser :: UTCTime -> User -> User
-- touchUser time user = fromRec $ nub $ union (toRec $ UpdatedAt time) (toRec user)

-- updateAndTouchUser :: UpdatingUser -> UTCTime -> User -> User
-- updateAndTouchUser updating time user =
--   fromRec $ nub $ union (toRec updating) fields'
--   where
--     fields' = union (toRec $ UpdatedAt time) (toRec user)

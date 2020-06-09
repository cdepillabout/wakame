{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE UndecidableSuperClasses #-}
module Wakame.Union where

import Prelude

import Control.Arrow (first)
import Data.SOP.NP
import Data.SOP.Constraint (All)
import Wakame.Row (Row)
import Wakame.Nub (HasField)


-- $setup
-- >>> import GHC.Generics
-- >>> import Wakame
-- >>> data Point = Point { x :: Double, y :: Double } deriving (Show, Generic)
-- >>> pt = Point 1.2 8.3


-- | Typeclass for composing fields
--
-- >>> union (toRow pt) (toRow (keyed @"z" 42.0))
-- (x: 1.2) :* (y: 8.3) :* (z: 42.0) :* Nil
--
-- >>> ununion (toRow pt) :: (Row '[ '("x", Double)], Row '[ '("y", Double)])
-- ((x: 1.2) :* Nil,(y: 8.3) :* Nil)
-- >>> ununion (toRow pt) :: (Row '[], Row '[ '("x", Double), '("y", Double)])
-- (Nil,(x: 1.2) :* (y: 8.3) :* Nil)
class (All (HasField u) l, All (HasField u) r) => Union l r u | l r -> u where
  union :: Row l -> Row r -> Row u
  ununion :: Row u -> (Row l, Row r)

instance All (HasField r) r => Union '[] r r where
  union _ r = r
  ununion x = (Nil, x)

instance (All (HasField (x ': u)) l, All (HasField (x ': u)) r, Union l r u) => Union (x ': l) r (x ': u) where
  union (x :* xs) r = x :* union xs r
  ununion (x :* xs) = first (x :*) $ ununion xs

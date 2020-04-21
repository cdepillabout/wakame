module Wakame.Rec where

import Prelude

import Data.Kind
import Data.Proxy
import GHC.Generics
import GHC.TypeLits
import Wakame.Utils (Append (..))


-- $setup
-- >>> import Wakame


type FIELD = (Symbol, Type)


-- * Value tagged by @Symbol@

-- |
-- >>> x = Keyed @"x" @Double 3.5
-- >>> y = Keyed @"y" @Double 4.8
-- >>> :t RCons x (RCons y RNil)
-- RCons x (RCons y RNil) :: Rec '[ '("x", Double), '("y", Double)]
--
-- >>> (x, y)
-- (x: 3.5,y: 4.8)
--
-- >>> toRec $ from (x, y)
-- x: 3.5, y: 4.8, _
--
-- >>> keys x
-- ["x"]
--
-- >>> keys (x, y)
-- ["x","y"]
--

newtype Keyed (k :: Symbol) (a :: Type) = Keyed a
  deriving (Eq)

instance (KnownSymbol k, Show a) => Show (Keyed k a) where
  show (Keyed x) = symbolVal (Proxy @k) <> ": " <> show x

instance Generic (Keyed k a) where
  type Rep (Keyed k a) = S1 ('MetaSel ('Just k) 'NoSourceUnpackedness 'NoSourceStrictness 'DecidedLazy) (Rec0 a)
  from (Keyed x) = M1 (K1 x)
  to (M1 (K1 x)) = Keyed x


-- * Heterogeneous associated list

data Rec (row :: [FIELD]) where
  RNil :: Rec '[]
  RCons :: Keyed k a -> Rec xs -> Rec ('(k, a) ': xs)

instance Show (Rec '[]) where
  show _ = "_"

instance (KnownSymbol k, Show a, Show (Rec xs)) => Show (Rec ('(k, a) ': xs)) where
  show (RCons x xs) = show x <> ", " <> show xs
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE TemplateHaskell    #-}
module Protocol where

import           Control.Distributed.Process
import           Data.Binary
import           Data.Typeable
import           GHC.Generics

type Timestamp = Int

data Event = Event Int
  deriving (Typeable, Generic, Show)

data Protocol = InitWorker ProcessId [ProcessId] |
                Done
  deriving (Typeable, Generic, Show)

instance Binary Event
instance Binary Protocol

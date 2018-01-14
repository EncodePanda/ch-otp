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

data Msg = Internal Event | External Event Timestamp ProcessId
  deriving (Typeable, Generic, Show)

data Protocol = InitWorker ProcessId [ProcessId] |
                Stop                             |
                Done                             |
                Results                          |
                Fired Msg
  deriving (Typeable, Generic, Show)

instance Binary Event
instance Binary Msg
instance Binary Protocol

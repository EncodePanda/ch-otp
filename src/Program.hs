module Program
    ( run
    ) where


import           Control.Distributed.Process
import           Control.Distributed.Process.Backend.SimpleLocalnet
import           Control.Distributed.Process.Closure
import           Control.Distributed.Process.Node
import           Master
import           System.Environment                                 (getArgs)

run :: IO ()
run = do
  args <- getArgs

  let rtable    = __remoteTable initRemoteTable
      mode      = (argsValue args "--mode")    ?? "master"
      host      = (argsValue args "--host")    ?? "127.0.0.1"
      port      = (argsValue args "--port")    ?? "10000"
      sendFor   = (argsValue args "--sendFor") ?? "1"
      waitFor   = (argsValue args "--waitFor") ?? "1"
      -- TODO other arguments

  case mode of
    "slave" -> do
      backend <- initializeBackend host port rtable
      startSlave backend
    "master" -> do
      backend <- initializeBackend host port rtable
      startMaster backend (runMaster backend (MasterConfig (read sendFor) (read waitFor)))

  where

      argsValue :: [String] -> String -> Maybe String
      argsValue [] key = Nothing
      argsValue (k:[]) key = Nothing
      argsValue (k:v:other) key
        | k == key = Just v
        | otherwise = argsValue other key

      (??) :: Maybe a -> a -> a
      (??) (Just a) df = a
      (??) Nothing df  = df


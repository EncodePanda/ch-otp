module Utils (logInfo, sendTo, sleep) where

import           Control.Concurrent          (threadDelay)
import           Control.Distributed.Process
import           Control.Monad               (forM)
import           Data.Binary
import           Data.Typeable

logInfo :: [Char] -> Process ()
logInfo msg = liftIO $ putStrLn msg

sendTo :: (Binary a, Typeable a) => [ProcessId] -> a -> Process [()]
sendTo bsPids protocol = forM bsPids $ \pid -> send pid protocol

sleep :: Int -> Process ()
sleep n = liftIO $ threadDelay (n * second)
  where
    second = 10^6


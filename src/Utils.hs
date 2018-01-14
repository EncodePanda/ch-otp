module Utils (logInfo, sendTo) where

import           Control.Distributed.Process
import           Control.Monad               (forM)
import           Data.Binary
import           Data.Typeable

logInfo :: [Char] -> Process ()
logInfo msg = liftIO . putStrLn $ msg

sendTo :: (Binary a, Typeable a) => [ProcessId] -> a -> Process [()]
sendTo bsPids protocol = forM bsPids $ \pid -> send pid protocol

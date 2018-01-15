{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE TemplateHaskell    #-}
module Master(runMaster) where

import           Control.Concurrent                                 (threadDelay)
import           Control.Distributed.Process
import           Control.Distributed.Process.Backend.SimpleLocalnet
import           Control.Distributed.Process.Closure
import           Control.Distributed.Process.Node
import           Control.Monad                                      (forM)
import           Protocol
import           Utils
import           Worker

remotable ['runWorker]

data MasterConfig = MasterConfig { sendFor :: Int, waitFor :: Int }

runMaster :: Backend -> [NodeId] -> MasterConfig -> Process ()
runMaster backend nodes config = do
  masterPid  <- getSelfPid
  workerPids <- spawnFor nodes $(mkStaticClosure 'runWorker)
  forM (zip workerPids [1..(length workerPids)]) $ initWorker masterPid workerPids
  sleep $ sendFor config
  sendTo workerPids Stop
  sleep $ waitFor config
  sendTo workerPids Results
  waitForWorkers (length workerPids)
  terminateAllSlaves backend

  where

    initWorker :: ProcessId -> [ProcessId] -> (ProcessId, Int) -> Process ()
    initWorker masterPid workerPids (pid, seed) = do
      let others = filter (/= pid) workerPids
      send pid (InitWorker masterPid others seed)
    
    waitForWorkers :: Int -> Process ()
    waitForWorkers 0 = return ()
    waitForWorkers n = do
      Done <- expect
      waitForWorkers (n-1)

    spawnFor :: [NodeId] -> Closure (Process ()) -> Process [ProcessId]
    spawnFor nodes c = forM nodes $ \nid -> spawn nid c

    sleep :: Int -> Process ()
    sleep n = liftIO $ threadDelay (n * second)

    second = 10^6

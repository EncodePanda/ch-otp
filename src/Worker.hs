module Worker(run) where

import Protocol
import           Control.Distributed.Process

-- stored events with both logical timestamp and process id for total ordering
data StoredEvent = StoredEvent Event Timestamp ProcessId

run :: Process ()
run = do
  workerPid                   <- getSelfPid
  InitWorker masterPid others <- expect
  events                      <- workUntilStopped workerPid others []
  send masterPid Done

workUntilStopped :: ProcessId -> [ProcessId] -> [StoredEvent] -> Process [StoredEvent]
workUntilStopped workerPid others events = undefined -- TODO 

module Worker(run) where

import Protocol
import           Control.Distributed.Process

{-|
Stored events with both logical timestamp and process id for total ordering
-}
data StoredEvent = StoredEvent Event Timestamp ProcessId

run :: Process ()
run = do
  workerPid                   <- getSelfPid
  InitWorker masterPid others <- expect
  events                      <- workUntilStopped workerPid others []
  send masterPid Done

{-|
Receives messages from external process and from internal generator then
stores them with timestamp and process id. Handles logical clock ticks.
-}
workUntilStopped :: ProcessId -> [ProcessId] -> [StoredEvent] -> Process [StoredEvent]
workUntilStopped workerPid others events = do
  generatorId <- spawnLocal (generator workerPid)
  cmd         <- expect :: Process Protocol
  handle cmd generatorId

  where
    handle :: Protocol -> ProcessId -> Process [StoredEvent]
    handle protocol generatorId = undefined

generator :: ProcessId -> Process ()
generator workerPid = return ()



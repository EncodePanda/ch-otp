module Worker(run) where

import           Protocol
import           Utils
import           Control.Distributed.Process

{-|
Stored events with both logical timestamp and process id for total ordering
-}
data StoredEvent = StoredEvent Event Timestamp ProcessId
data Result = Result Int Int deriving Show

run :: Process ()
run = do
  workerPid                   <- getSelfPid
  InitWorker masterPid others <- expect
  events                      <- workUntilStopped workerPid others []
  logInfo $ show $ result $ sortEvents events
  send masterPid Done

  where
    result :: [StoredEvent] -> Result
    result events = undefined -- TODO

    sortEvents :: [StoredEvent] -> [StoredEvent]
    sortEvents events = undefined -- TODO
    
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

    handle Stop generatorId        = do
      _ <- send generatorId Stop
      workUntilStopped workerPid others events

    handle Results generatorId     = return events

    handle (Fired msg) generatorId = undefined -- TODO store events

    -- TODO considered smell, should be resolved if typed channels introduced to the solution
    handle command _               = die $ "Received incorrect command " ++ (show command)

{-|
Generates internal events for given worker
-}
generator :: ProcessId -> Process ()
generator workerPid = return ()



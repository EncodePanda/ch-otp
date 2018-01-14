module Worker(run) where

import           Protocol
import           Utils
import           Control.Distributed.Process

{-|
Stored events with both logical timestamp and process id for total ordering
-}
data StoredEvent = StoredEvent Event Timestamp ProcessId
data Result = Result Int Int deriving Show

data Clock = Clock Timestamp

run :: Process ()
run = do
  InitWorker masterPid others <- expect
  workerPid                   <- getSelfPid
  generatorPid                <- spawnLocal (generator workerPid)
  events                      <- workUntilStopped [] (Clock 0) generatorPid others
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
workUntilStopped :: [StoredEvent] -> Clock -> ProcessId -> [ProcessId] -> Process [StoredEvent]
workUntilStopped events clock generatorPid others = do
  cmd  <- expect :: Process Protocol
  handle cmd clock

  where

    handle :: Protocol -> Clock -> Process [StoredEvent]

    handle Stop clock        = do
      _ <- send generatorPid Stop
      workUntilStopped events clock generatorPid others

    handle Results _  = return events

    -- Lamport's IR1
    handle (Fired (Internal event)) (Clock n) = do
      let ts    = n + 1
      workerPid <- getSelfPid
      sendTo others (Fired (External event ts workerPid))
      workUntilStopped ((StoredEvent event ts workerPid) : events) (Clock ts) generatorPid others

    -- Lamport's IR2
    handle (Fired (External event ets pid)) (Clock n) = do
      let ts = if(ets >= n) then ets + 1 else (n+1)
      workUntilStopped ((StoredEvent event ts pid) : events) (Clock ts) generatorPid others

    -- TODO considered code smell, should be resolved if typed channels introduced to the solution
    handle command _               = die $ "Received incorrect command " ++ (show command)

{-|
Generates internal events for given worker
-}
generator :: ProcessId -> Process ()
generator workerPid = return ()

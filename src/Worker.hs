module Worker(runWorker) where

import           Control.Distributed.Process
import           Data.List                   (sort)
import           Protocol
import           System.Random
import           Utils
import           Control.Distributed.Process.Closure

{-|
Stored events with both logical timestamp and process id for total ordering
-}
data StoredEvent = StoredEvent Event Timestamp ProcessId
  deriving Show

instance Eq StoredEvent where
  (==) (StoredEvent _ t1 p1) (StoredEvent _ t2 p2) = t1 == t2 && p1 == p2

instance Ord StoredEvent where
  (<=) (StoredEvent _ ts1 pid1) (StoredEvent _ ts2 pid2) =
    if (ts1 == ts2) then pid1 <= pid2 else ts1 <= ts2


data Result = Result Int Int deriving Show
data Clock = Clock Timestamp

runWorker :: Process ()
runWorker = do
  InitWorker masterPid others seed <- expect
  workerPid                        <- getSelfPid
  generatorPid                     <- spawnLocal (generator workerPid (mkStdGen seed))
  events                           <- workUntilStopped [] (Clock 0) generatorPid others
  logInfo $ show $ result $ sort events
  send masterPid Done

  where
    result :: [StoredEvent] -> Result
    result events = Result len val
      where
        vals = map (\ (StoredEvent (Event n) _ _) -> n) events
        len  = length events
        val  = sum $ zipWith (*) [1..len] vals

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
      let ts = if(ets >= n) then ets + 1 else n + 1
      workUntilStopped ((StoredEvent event ets pid) : events) (Clock ts) generatorPid others

    -- TODO considered code smell, should be resolved if typed channels introduced to the solution
    handle command _               = die $ "Received incorrect command " ++ (show command)

{-|
Generates internal events for given worker
-}
generator :: RandomGen r => ProcessId -> r -> Process ()
generator workerPid rand = do
  m <- expectTimeout (10 * mili) :: Process (Maybe Protocol)
  case m of
    Just Stop -> return ()
    Nothing   -> gen

  where
    mili = 10 ^ 3
    sec  = 10 ^ 6

    gen :: Process ()
    gen = do
      let (n, nextRand) = next rand
      let event = Event n
      send workerPid (Fired (Internal event))
      generator workerPid nextRand


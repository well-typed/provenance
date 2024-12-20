module Demo.Scope (Example(..), demo) where

import Control.Concurrent
import Control.Concurrent.Async

import Debug.NonInterleavedIO.Scoped qualified as Scoped
import Debug.Provenance.Scope

{-------------------------------------------------------------------------------
  Top-level
-------------------------------------------------------------------------------}

data Example =
    Example1
  | Example2
  | Example3
  | Example4
  deriving (Show)

demo :: Example -> IO ()
demo Example1 = g4
demo Example2 = g1
demo Example3 = concurrent
demo Example4 = h1

{-------------------------------------------------------------------------------
  Using the library
-------------------------------------------------------------------------------}

g1 :: IO ()
g1 = g2

g2 :: HasCallStack => IO ()
g2 = scoped g3

g3 :: HasCallStack => IO ()
g3 = scoped g4

g4 :: HasCallStack => IO ()
g4 = do
    Scoped.putStrLn "start"
    -- f4 does something ..
    Scoped.putStrLn "middle"
    -- f4 does something else ..
    Scoped.putStrLn "end"

concurrent :: IO ()
concurrent = concurrently_ g4 g4

h1 :: IO ()
h1 = h2

h2 :: HasCallStack => IO ()
h2 = scoped h3

h3 :: HasCallStack => IO ()
h3 = scoped $ do
    tid <- myThreadId
    concurrently_
      (inheritScope tid >> g4)
      (inheritScope tid >> g4)

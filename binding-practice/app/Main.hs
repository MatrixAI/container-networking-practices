module Main where

import Lib

main :: IO ()
main = do
  a <- readLn
  print . Lib.sin $ a
  time <- Lib.getTime
  print time
  print $ add 1 2
  print getPi
  print $ add 1 2
  print getPi

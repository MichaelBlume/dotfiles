#!/usr/bin/env runhaskell
module Main (main) where

-- When you copy a conversation out of your google chat logs, it looks like
-- this
--
-- Alice
-- hi
-- how are you
-- Bob Smith
-- pretty well
-- I made the most amazing sandwich
--
-- but if you were going to paste the same conversation into tumblr (and you're
-- alice) you'd want something like
--
-- Me: hi
-- Me: how are you
-- Bob: pretty well
-- Bob: I made the most amazing sandwich
--
-- This script manages the conversion! Call it like so
--
-- cat chat_log | ./Chat Alice Me "Bob Smith" Bob 

import Data.Map as Map
import System.Environment as Env

type Names = Map.Map String String

translateLines :: Names -> String -> [String] -> [String]
translateLines names = f where
  f _ [] = []
  f currentName (l : ls) = case Map.lookup l names of
    Just newName -> f newName ls
    Nothing -> (currentName ++ ": " ++ l) : (f currentName ls)

translateChat :: Names -> String -> String
translateChat names = unlines . translateLines names defName . lines where
  defName = error "top line must be a name"

packNames :: [String] -> Names
packNames [] = empty
packNames (k:v:ns) = insert k v $ packNames ns

main = interact . translateChat . packNames =<< Env.getArgs

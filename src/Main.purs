module Main where

import Prelude

import Effect (Effect)

foreign import mylog :: String -> Effect Unit

main :: Effect Unit
main = do
  mylog "Purs v1"

port module Ports exposing (..)


port saveToken : String -> Cmd msg


port receiveToken : (String -> msg) -> Sub msg

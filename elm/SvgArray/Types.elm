module SvgArray.Types exposing (..)


type Animator a b
    = Animator ( a, List b )


type ArrayAnimation
    = Exchange Int Int
    | LookAt Int
    | UnlookAt Int

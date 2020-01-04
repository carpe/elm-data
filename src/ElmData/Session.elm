module ElmData.Session exposing (Session(..), SessionData, checkSessionExpiration, checkError, SessionFailure(..))

{-| Sessions exist to hold all state associated with your requests.

Right now that's just Auth data, but I think this could also be a great place for cached data to live as well.

@docs Session, SessionData, checkSessionExpiration, checkError, SessionFailure
-}

import Http exposing (..)
import Jwt exposing (JwtError(..))

import Time exposing (..)


{-| The Session
-}
type Session
    = Unauthenticated
    | Active SessionData

{-| Data related to an authenticated session
-}
type alias SessionData =
  { authToken : String
  , expiration : Int
  , permissions : List String
  }

-- Session Creation --

{-| Result of the Creation of a Session
-}
type SessionFailure
    = Failure String
    | Corrupt
    | ExpiredSession


{-| Check if session is expired
-}
checkSessionExpiration : Posix -> SessionData -> Result SessionFailure SessionData
checkSessionExpiration now session =
    let
        secondsRemainingForSession =
            (Time.posixToMillis now) - (session.expiration * 1000)
    in
        case secondsRemainingForSession > 0 of
            -- expired session
            True ->
                Err ExpiredSession

            -- session valid
            False ->
                Ok session


{-| Check if a request failure was caused by the session
-}
checkError : Http.Error -> Maybe (SessionFailure)
checkError err =
    case err of
        BadUrl _ ->
            Nothing
        Timeout ->
            Nothing
        NetworkError ->
            Nothing
        BadStatus badResponse ->
            case badResponse.status.code of
                403 ->
                    Just <| Failure "Unable to authenticate with the provided credentials!"
                _ ->
                    Nothing
        BadPayload _ _ ->
            Nothing
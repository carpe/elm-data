module ElmData.Jwt exposing (JwtClaims, checkToken, scheduleExpiration)

{-| Jwt module is a collection of helpers used to derive sessions from JWTs.

@docs JwtClaims, checkToken, scheduleExpiration
-}

import Basics as Integer
import Jwt exposing (..)

import ElmData.Session exposing (SessionData, SessionFailure(..), checkSessionExpiration)

import Process
import Task exposing (Task, andThen)
import Time exposing (..)

import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Pipeline exposing (required, optional)


{-| Basic Jwt Claims. In the future this should be configurable.
-}
type alias JwtClaims =
    { issuer : String
    , expiration : Int
    , permissions : List String
    }

-- helper used to map jwt claims into session data
sessionFromClaims : String -> JwtClaims -> SessionData
sessionFromClaims authToken claims =
    { authToken = authToken
    , expiration = claims.expiration
    , permissions = claims.permissions
    }

{-| Schedule a message to be sent any number of milliseconds BEFORE the JWT expires. You can use this to remind users
that they may need to re-login soon, or to simply expire the session.
-}
scheduleExpiration : SessionData -> Int -> msg -> Cmd msg
scheduleExpiration session millisBeforeExpiration expirationMsg =
    let
        millisUntilExpiration now =
            (session.expiration * 1000) - (Time.posixToMillis now + millisBeforeExpiration)
    in
        Time.now
            |> andThen (\now -> Process.sleep <| Integer.toFloat <| millisUntilExpiration now)
            |> andThen (\_ -> Task.succeed expirationMsg)
            |> Task.perform identity

{-| Decoder for JwtClaims
-}
jwtClaimsDecoder : Decoder JwtClaims
jwtClaimsDecoder =
    Decode.succeed JwtClaims
        |> required "iss" Decode.string
        |> required "exp" Decode.int
        |> optional "permissions" (Decode.list Decode.string) []


{-| Checks a token for Expiry. Returns expiry or any errors that occurred in decoding.
-}
checkToken : String -> (Result SessionFailure SessionData -> msg) -> Cmd msg
checkToken token toMessage =
    Time.now
        |> Task.andThen (finalTokenCheck token >> Task.succeed)
        |> (Task.perform toMessage)


{-| Checks whether a token has expired, and returns the Session, or
any error that occurred while decoding the token.
-}
finalTokenCheck : String -> Posix -> Result SessionFailure SessionData
finalTokenCheck token now =
    decodeToken jwtClaimsDecoder token
        |> Result.map (sessionFromClaims token)
        |> Result.mapError simplifyJwtError
        |> Result.andThen (checkSessionExpiration now)



simplifyJwtError : JwtError -> SessionFailure
simplifyJwtError jwtErr =
    case jwtErr of
        TokenExpired ->
            ExpiredSession
        _ ->
            Corrupt
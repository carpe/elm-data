module ElmData.Jwt exposing (JwtClaims, checkToken)

{-| Jwt module is a collection of helpers used to derive sessions from JWTs.

@docs JwtClaims, checkToken
-}

import Jwt exposing (..)

import ElmData.Session exposing (SessionData, SessionFailure(..), checkSessionExpiration)

import Task exposing (Task)
import Time exposing (..)

import Json.Decode as Decode exposing (Decoder, Value, field)
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
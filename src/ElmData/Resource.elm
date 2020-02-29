module ElmData.Resource exposing (Resource, ResourceMsg(..), resource)

{-| Resource allows you to make requests on behalf of a DAO, without having to think about the state of the DAO

@docs Resource, ResourceMsg, resource
-}

import ElmData.DAO exposing (..)
import ElmData.Data exposing (..)
import ElmData.Messages exposing (..)

import ElmData.QueryParam exposing (QueryParam)
import ElmData.Session exposing (Session(..))


{-| A Resource that can be used to make requests that target a single record. (i.e. SHOW/CREATE/UPDATE)
-}
type alias Resource recordType msg =
    -- CREATE
    { create : Session -> recordType -> Cmd msg
    -- READ
    , fetch : Session -> String -> Cmd msg
    , fetchAll : Session -> Cmd msg
    , query : Session -> List QueryParam -> Cmd msg
    -- UPDATE
    , update : Session -> recordType -> String -> Cmd msg
    -- DELETE
    , delete : msg -> Session -> String -> Cmd msg
    }

{-| A message that contains the results of a request
-}
type ResourceMsg recordType
    = Success recordType
    | Failure RequestError


{-| Convenience function for creating a Resource
-}
resource : DAO recordType -> (ResourceMsg recordType -> msg) -> Resource recordType msg
resource dao translate =
    { create = curryPost dao (resourceTranslation translate)
    , fetch = curryFetch dao (resourceTranslation translate)
    , update = curryPut dao (resourceTranslation translate)
    , fetchAll = curryFetchAll dao (resourceTranslation translate)
    , query = curryQuery dao (resourceTranslation translate)
    , delete = curryDelete dao (emptyResponseTranslation translate)
    }

resourceTranslation : (ResourceMsg recordType -> msg) -> (RequestResult recordType -> msg)
resourceTranslation resourceToLocal =
    \requestResults ->
        case requestResults of
            Result.Ok response ->
                Success response.body |> resourceToLocal
            Result.Err error ->
                Failure error |> resourceToLocal

emptyResponseTranslation : (ResourceMsg recordType -> msg) -> (Result RequestError msg -> msg)
emptyResponseTranslation resourceToLocal =
    \requestResults ->
        case requestResults of
            Result.Ok msg ->
                msg
            Result.Err error ->
                Failure error |> resourceToLocal
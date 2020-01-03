module ElmData.Resource exposing (Resource, ResourceMsg(..), resource)

{-|
Resource allows you to make requests on behalf of a DAO, without having to think about the state of the DAO

@docs Resource, ResourceMsg, resource
-}

import ElmData.DAO exposing (..)
import ElmData.Data exposing (..)
import ElmData.Messages exposing (..)

import ElmData.Session exposing (Session(..))


{-|
A Resource that can be used to make requests that target a single record. (i.e. SHOW/CREATE/UPDATE)
-}
type alias Resource recordType externalMsg =
    { create : Session -> recordType -> Cmd externalMsg
    , fetch : Session -> String -> Cmd externalMsg
    , update : Session -> recordType -> Cmd externalMsg
    }

{-|
A message that contains the results of a request
-}
type ResourceMsg recordType
    = Success recordType
    | Failure RequestError


{-|
Convenience function for creating a Resource
-}
resource : DAO recordType -> (ResourceMsg recordType -> localMsg) -> (localMsg -> externalMsg) -> Resource recordType externalMsg
resource dao resourceToLocal localToExternal =
    { create = curryPost dao (createResourceToExternalMsgTranslation resourceToLocal localToExternal)
    , fetch = curryFetch dao (createResourceToExternalMsgTranslation resourceToLocal localToExternal)
    , update = curryPut dao (createResourceToExternalMsgTranslation resourceToLocal localToExternal)
    }

createResourceToExternalMsgTranslation : (ResourceMsg recordType -> localMsg) -> (localMsg -> externalMsg) -> (RequestResult recordType -> externalMsg)
createResourceToExternalMsgTranslation resourceToLocal localToExternal =
    \requestResults ->
        case requestResults of
            Result.Ok response ->
                Success response.body |> resourceToLocal |> localToExternal
            Result.Err error ->
                Failure error |> resourceToLocal |> localToExternal
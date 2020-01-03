module ElmData.ListResource exposing (ListResource, ListResourceMsg(..), listResource)

{-|
    Resource allows you to make requests on behalf of a DAO, without having to think about the state of the DAO

    @docs ListResource, ListResourceMsg, listResource
-}

import ElmData.DAO exposing (..)
import ElmData.Data exposing (..)
import ElmData.Messages exposing (..)
import ElmData.QueryParam exposing (..)

import ElmData.Session exposing (Session(..))

type alias ListResource externalMsg =
    { fetchAll : Session -> Cmd externalMsg
    , query : Session -> List QueryParam -> Cmd externalMsg
    , delete : Session -> String -> Cmd externalMsg
    }

type ListResourceMsg recordType
    = Success (List recordType)
    | Failure RequestError

--curryFetchAll : DAO recordType msg -> (RequestResults recordType -> msg) -> Cmd msg
listResource : DAO recordType -> (ListResourceMsg recordType -> localMsg) -> (localMsg -> externalMsg) -> ListResource externalMsg
listResource dao listResourceToLocal localToExternal =
    { fetchAll = curryFetchAll dao (createResourceToExternalMsgTranslation listResourceToLocal localToExternal)
    , query = curryQuery dao (createResourceToExternalMsgTranslation listResourceToLocal localToExternal)
    , delete = curryDelete dao (createResourceToExternalMsgTranslation listResourceToLocal localToExternal)
    }

createResourceToExternalMsgTranslation : (ListResourceMsg recordType -> localMsg) -> (localMsg -> externalMsg) -> (RequestResults recordType -> externalMsg)
createResourceToExternalMsgTranslation listResourceToLocal localToExternal =
    \requestResults ->
        case requestResults of
            Result.Ok response ->
                Success response.body |> listResourceToLocal |> localToExternal
            Result.Err error ->
                Failure error |> listResourceToLocal |> localToExternal
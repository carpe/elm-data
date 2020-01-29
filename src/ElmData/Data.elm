module ElmData.Data exposing (..)

{-|
    Main module for DAO related things.
-}

import Http exposing (Response)

import Json.Decode

import ElmData.QueryParam exposing (..)
import ElmData.Messages exposing (..)
import ElmData.DAO exposing (..)

import ElmData.Session exposing (..)


-- Creates a function that will create and send requests for a given record.
--
curryFetch : DAO recordType -> (RequestResult recordType -> msg) -> Session -> String -> Cmd msg
curryFetch dao returnMsg =
    let
        -- create a request handler that maps the results in order to simplify the errors.
        requestHandler result = returnMsg (mapHttpErrors result)

        -- this is the function that will be used to CREATE a http request (not send it)
        createRequest session identifier = Http.request
            { method = "GET"
            , headers = headers dao session
            , url = (dao.apiUrl ++ "/" ++ identifier)
            , body = Http.emptyBody
            , expect = Http.expectStringResponse <| createResponseExpectation dao.deserialize
            , timeout = Nothing
            , withCredentials = False
            }

        -- this is the function that will be used to SEND an Http Request
        -- (notice how we call the method above)
        sendRequest session identifier = Http.send requestHandler (createRequest session identifier)
    in
        -- put it all together to create a function that creates THEN sends a request for a given record
        sendRequest


-- Creates a function that will send request to delete a given record.
--
curryDelete : DAO recordType -> (RequestResults recordType -> msg) -> Session -> String -> Cmd msg
curryDelete dao returnMsg =
    let
        -- create a request handler that maps the results in order to simplify the errors.
        requestHandler result = returnMsg (mapHttpErrors result)


        -- PAY ATTENTION: The functions above are bullshit, what's more important are these next
        -- two functions below this line. The first one creates requests, the send one sends them.

        -- this is the function that will be used to CREATE a http request
        createRequest session identifier = Http.request
            { method = "DELETE"
            , headers = headers dao session
            , url = (dao.apiUrl ++ "/" ++ identifier)
            , body = Http.emptyBody
            , expect = Http.expectStringResponse <| createEmptyResponseExpectation
            , timeout = Nothing
            , withCredentials = False
            }

        -- this is the function that will be used to SEND an Http Request
        -- (notice how we call the method above)
        sendRequest session identifier = Http.send requestHandler (createRequest session identifier)
    in
        -- put it all together to create a function that creates THEN sends a request for a given record
        sendRequest


-- Creates a function that will create and send requests for records based on a query.
--
--curryQuery : String -> String -> (DAOMsg recordType -> msg) -> Json.Decode.Decoder (List recordType) -> (List QueryParam -> Cmd msg)
curryQuery : DAO recordType -> (RequestResults recordType -> msg) -> Session -> List QueryParam -> Cmd msg
curryQuery dao returnMsg =
    let
        -- create a request handler that maps the results in order to simplify the errors.
        requestHandler result = returnMsg (mapHttpErrors result)

        -- PAY ATTENTION: The functions above are bullshit, what's more important are these next
        -- two functions below this line. The first one creates requests, the send one sends them.

        -- this is the function that will be used to CREATE a http request
        createRequest session queryParams = Http.request
            { method = "GET"
            , headers = headers dao session
            , url = (createUrl dao.apiUrl queryParams)
            , body = Http.emptyBody
            , expect = Http.expectStringResponse <| createListResponseExpectation dao.listDeserialize
            , timeout = Nothing
            , withCredentials = False
            }

        -- this is the function that will be used to SEND an Http Request
        -- (notice how we call the method above)
        sendRequest session queryParams = Http.send requestHandler (createRequest session queryParams)
    in
        -- put it all together to create a function that creates THEN sends a request for a given record
        sendRequest

-- Creates a function that will create and send requests for records
--
curryFetchAll : DAO recordType -> (RequestResults recordType -> msg) -> Session -> Cmd msg
curryFetchAll dao returnMsg =
    let
        -- create a request handler that maps the results in order to simplify the errors.
        requestHandler result = returnMsg (mapHttpErrors result)

        -- PAY ATTENTION: The functions above are bullshit, what's more important are these next
        -- two functions below this line. The first one creates requests, the send one sends them.

        -- this is the function that will be used to CREATE a http request
        createRequest session = Http.request
            { method = "GET"
            , headers = headers dao session
            , url = dao.apiUrl
            , body = Http.emptyBody
            , expect = Http.expectStringResponse <| createListResponseExpectation dao.listDeserialize
            , timeout = Nothing
            , withCredentials = False
            }


        sendRequest session = Http.send requestHandler <| createRequest session
    in
        -- this is the function that will be used to SEND an Http Request
        -- (notice how we call the method above)
        sendRequest


-- Creates a function that will create and send requests to persist a given record.
--
curryPost : DAO recordType -> (RequestResult recordType -> msg) -> Session -> recordType -> Cmd msg
curryPost dao returnMsg =
    let
        -- create a request handler that maps the results in order to simplify the errors.
        requestHandler result = returnMsg (mapHttpErrors result)

        -- this is the function that will be used to CREATE a http request based on some record's identifier
        createRequest session recordToPersist = Http.request
            { method = "POST"
            , headers = headers dao session
            , url = dao.apiUrl
            , body = Http.jsonBody <| dao.serialize recordToPersist
            , expect = Http.expectStringResponse <| createResponseExpectation dao.deserialize
            , timeout = Nothing
            , withCredentials = False
            }

        -- this is the function that will be used to SEND an Http Request
        -- (notice how we call the method above)
        sendRequest session recordToPersist = Http.send requestHandler <| createRequest session recordToPersist
    in
        -- put it all together to create a function that creates THEN sends a request for a given record
        sendRequest

-- Creates a function that will create and send requests to update a given record.
--
curryPut : DAO recordType -> (RequestResult recordType -> msg) -> Session -> recordType -> String -> Cmd msg
curryPut dao returnMsg =
    let
        -- create a request handler that maps the results in order to simplify the errors.
        requestHandler result = returnMsg (mapHttpErrors result)

        -- this is the function that will be used to CREATE a http request based on some record's identifier
        createRequest session recordToPersist identifier = Http.request
            { method = "PUT"
            , headers = headers dao session
            , url = (dao.apiUrl ++ "/" ++ identifier)
            , body = (Http.jsonBody <| dao.serialize recordToPersist)
            , expect = Http.expectStringResponse <| createResponseExpectation dao.deserialize
            , timeout = Nothing
            , withCredentials = False
            }

        -- this is the function that will be used to SEND an Http Request
        -- (notice how we call the method above)
        sendRequest session recordToPersist identifier = Http.send requestHandler <| createRequest session recordToPersist identifier
    in
        -- put it all together to create a function that creates THEN sends a request for a given record
        sendRequest


-- HELPERS

createResponseExpectation : Json.Decode.Decoder recordType -> (Response String -> Result String (DAORequestResponse recordType))
createResponseExpectation decoder =
    let
        createResponse decodedResult =
            { body = decodedResult
            }
    in
        \response ->
            Result.map createResponse (Json.Decode.decodeString decoder response.body)
                |> Result.mapError Json.Decode.errorToString

createListResponseExpectation : Json.Decode.Decoder (List recordType) -> (Response String -> Result String (ListDAORequestResponse recordType))
createListResponseExpectation decoder =
    let
        createResponse decodedResults =
            { body = decodedResults
            }
    in
        \response ->
            Result.map createResponse (Json.Decode.decodeString decoder response.body)
                |> Result.mapError Json.Decode.errorToString

createEmptyResponseExpectation : (Response String -> Result String (ListDAORequestResponse recordType))
createEmptyResponseExpectation =
    let
        createResponse =
            { body = []
            }
    in
        \response ->
            Ok createResponse

mapHttpErrors : Result Http.Error a -> Result RequestError a
mapHttpErrors httpResult =
    Result.mapError HttpError httpResult

requestErrorToString : RequestError -> String
requestErrorToString err =
    case err of
        UnableToParseResponseBody errString ->
            errString
        HttpError httpErr ->
            "HttpError"

-- Calculates the headers for a request by considering the dao and the current session
--
headers : DAO recordType -> Session -> List Http.Header
headers dao session =
    let
        flatMap = List.filterMap identity
    in
        [ authHeaderFromSession dao session
        ] |> flatMap

-- HELPERS FOR AUTH

authHeaderFromSession : DAO recordType -> Session -> Maybe Http.Header
authHeaderFromSession dao session =
    case session of
        Unauthenticated ->
            Nothing

        -- if the session is active, send the auth token in the configured header.
        Active sessionData ->
            let
                (k, v) = dao.authConfig.authHeader sessionData
            in
                Just <| Http.header k v
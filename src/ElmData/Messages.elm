module ElmData.Messages exposing (RequestError(..), RequestResult, RequestResults, DAORequestResponse, ListDAORequestResponse)

{-|
    # Use to pass query params to a request made via a Resource or ListResource.

    @docs RequestError, RequestResult, RequestResults, DAORequestResponse, ListDAORequestResponse
-}
import Http exposing (Response)

{-| results from a dao request
-}
type RequestError
    = UnableToParseResponseBody String
    | HttpError Http.Error

{-| results from a dao request
-}
type alias RequestResult recordType = (Result RequestError (DAORequestResponse recordType))

{-| results from a dao request for multiple records
-}
type alias RequestResults recordType = (Result RequestError (ListDAORequestResponse recordType))

{-| response from a dao request
-}
type alias DAORequestResponse recordType =
    { body : recordType
    }

{-| response from a dao request for many records
-}
type alias ListDAORequestResponse recordType =
    { body : List recordType
    }
module ElmData.Messages exposing (RequestError(..), RequestResult, DAORequestResponse)

{-|
Use to pass query params to a request made via a Resource or ListResource.

@docs RequestError, RequestResult, DAORequestResponse
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

{-| response from a dao request
-}
type alias DAORequestResponse recordType =
    { body : recordType
    }
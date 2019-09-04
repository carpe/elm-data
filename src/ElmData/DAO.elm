module ElmData.DAO exposing (DAO, createDAO)

{-|
    DAOs (Data Access Objects) exist to hold all state relevant to making requests to an API.

    @docs DAO, createDAO
-}

import Json.Decode
import Json.Encode

import ElmData.AuthConfig as AuthConfig exposing (AuthConfig)

{-|
    the dao
-}
type alias DAO recordType =
    { apiUrl : String
    -- auth config
    , authConfig : AuthConfig

    -- serialization
    , listDeserialize : Json.Decode.Decoder (List recordType)
    , deserialize : Json.Decode.Decoder recordType
    , serialize : (recordType -> Json.Encode.Value)
    }

{-|
    Function used to create a DAO
-}
createDAO : String -> Json.Decode.Decoder (List recordType) -> Json.Decode.Decoder recordType -> (recordType -> Json.Encode.Value) -> (DAO recordType)
createDAO apiUrl listDeserializer deserializer serializer =
    { apiUrl = apiUrl
    , authConfig = AuthConfig.default

    -- serialization
    , listDeserialize = listDeserializer
    , deserialize = deserializer
    , serialize = serializer
    }

{-|
    Function used to create a DAO
-}
createAuthenticatedDAO : String -> AuthConfig -> Json.Decode.Decoder (List recordType) -> Json.Decode.Decoder recordType -> (recordType -> Json.Encode.Value) -> (DAO recordType)
createAuthenticatedDAO apiUrl authConfig listDeserializer deserializer serializer =
    { apiUrl = apiUrl
    , authConfig = authConfig

    -- serialization
    , listDeserialize = listDeserializer
    , deserialize = deserializer
    , serialize = serializer
    }



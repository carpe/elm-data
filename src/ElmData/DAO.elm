module ElmData.DAO exposing (DAO, createDAO, createAuthenticatedDAO)

{-| DAOs (Data Access Objects) exist to hold all state relevant to making requests to an API.

@docs DAO, createDAO, createAuthenticatedDAO
-}

import Json.Decode
import Json.Encode

import ElmData.AuthConfig as AuthConfig exposing (AuthConfig)

{-| the dao
-}
type alias DAO recordType =
    { apiUrl : String
    -- auth config
    , authConfig : AuthConfig

    -- serialization
    , deserialize : Json.Decode.Decoder recordType
    , serialize : (recordType -> Json.Encode.Value)
    }

{-| Function used to create a DAO
-}
createDAO : String -> Json.Decode.Decoder recordType -> (recordType -> Json.Encode.Value) -> (DAO recordType)
createDAO apiUrl deserializer serializer =
    { apiUrl = apiUrl
    , authConfig = AuthConfig.default

    -- serialization
    , deserialize = deserializer
    , serialize = serializer
    }

{-| Function used to create a DAO
-}
createAuthenticatedDAO : String -> AuthConfig -> Json.Decode.Decoder recordType -> (recordType -> Json.Encode.Value) -> (DAO recordType)
createAuthenticatedDAO apiUrl authConfig deserializer serializer =
    { apiUrl = apiUrl
    , authConfig = authConfig

    -- serialization
    , deserialize = deserializer
    , serialize = serializer
    }



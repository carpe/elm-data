module ElmData.AuthConfig exposing (AuthConfig, default)

{-|
Configuration for how Authentication will be handled in your app.

@docs AuthConfig, default
-}

import ElmData.Session as Session exposing (Session, SessionData)


{-| Object to hold the configurations.
-}
type alias AuthConfig =
    -- function used to create the authorization header that will be used for all authenticated requests.
    -- returns a tuple that represents the Header's name and value respectively.
    { authHeader : SessionData -> (String, String)
    }


{-| Default AuthConfig that will attach a Bearer Token to your requests if a Authenticated Session is used.
-}
default : AuthConfig
default =
    { authHeader = \sessionData -> ("Authorization", "Bearer " ++ sessionData.authToken)
    }
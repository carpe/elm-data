module ElmData.QueryParam exposing (QueryParam, createUrl, string, int, float, bool)


{-|
    # Use to pass query params to a request made via a Resource or ListResource.

    @docs string, int, float, bool

    # Actual QueryParam type

    @docs QueryParam

    # Create url from QueryParams

    @docs createUrl
-}

{-| A QueryParam
-}
type alias QueryParam =
    { key : String
    , value : String
    }

{-| Create url from QueryParams
-}
createUrl : String -> List QueryParam -> String
createUrl baseUrl queryParameters =
    let
        -- put the query parameters together and encode them
        formattedQueryParams = List.map (\qp -> qp.key ++ "=" ++ qp.value) queryParameters
    in
        case queryParameters of
            [] ->
                baseUrl

            _ ->
                baseUrl ++ "?" ++ String.join "&" formattedQueryParams


{-| Create String QueryParam
-}
string : String -> String -> QueryParam
string key value =
    { key = key
    , value = value
    }

{-| Create Int QueryParam
-}
int : String -> Int -> QueryParam
int key value =
    { key = key
    , value = String.fromInt value
    }

{-| Create Float QueryParam
-}
float : String -> Float -> QueryParam
float key value =
    { key = key
    , value = String.fromFloat value
    }

{-| Create Bool QueryParam
-}
bool : String -> Bool -> QueryParam
bool key value =
    { key = key
    , value = 
        case value of
            True ->
                "true"
            False ->
                "false"
    }
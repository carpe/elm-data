module QueryParam exposing (..)

import ElmData.QueryParam as QueryParam exposing (createUrl)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "QueryParam"
        [ describe "createUrl"
            -- Nest as many descriptions as you like.
            [ test "generates a valid url" <|
                \_ ->
                    let
                        expected =
                            "https://something.com?name=elm-data&version=1.0.0"
                    in
                    Expect.equal expected
                        (createUrl "https://something.com"
                            [ QueryParam.string "name" "elm-data"
                            , QueryParam.string "version" "1.0.0"
                            ]
                        )
            , test "escapes special characters" <|
                \_ ->
                    let
                        expected =
                            "https://something.com?name=%26%2F"
                    in
                    Expect.equal expected
                        (createUrl "https://something.com"
                            [ QueryParam.string "name" "&/"
                            ]
                        )
            ]
        ]

module Main exposing (..)

import Browser
import Html exposing (Html, div, button, text, input, li, ul)
import Html.Attributes exposing (placeholder, value, checked, type_)
import Html.Events exposing (onClick, onInput, onCheck)

-- MODEL

type alias Id = Int

type alias Item =
    { id : Id
    , title : String
    , completed : Bool
    }

type alias State =
    { items : List Item
    , newItemTitle : String
    }

init : State
init =
    { items =
        [ { id = 1, title = "Check Twitter", completed = True }
        , { id = 2, title = "Write Paper", completed = False }
        ]
    , newItemTitle = ""
    }

-- EVENTS (or MESSAGES)

type Event
    = SetCompleted Id Bool
    | SetTitle Id String
    | Remove Id
    | Add
    | UpdateNewItemTitle String

-- UPDATE

update : Event -> State -> State
update msg state =
    case msg of
        SetCompleted id completed ->
            let
                updateItem item =
                    if item.id == id then
                        { item | completed = completed }
                    else
                        item
            in
            { state | items = List.map updateItem state.items }

        SetTitle id newTitle ->
            let
                updateItem item =
                    if item.id == id then
                        { item | title = newTitle }
                    else
                        item
            in
            { state | items = List.map updateItem state.items }

        Remove id ->
            { state | items = List.filter (\item -> item.id /= id) state.items }

        Add ->
            let
                newId =
                    List.length state.items + 1
                newItem =
                    { id = newId, title = state.newItemTitle, completed = False }
            in
            { state
                | items = newItem :: state.items
                , newItemTitle = ""
            }

        UpdateNewItemTitle title ->
            { state | newItemTitle = title }

-- VIEW

view : State -> Html Event
view state =
    div []
        [ input
            [ placeholder "New task title..."
            , value state.newItemTitle
            , onInput UpdateNewItemTitle
            ]
            []
        , button [ onClick Add ] [ text "Add" ]
        , ul []
            (List.map viewItem state.items)
        ]

viewItem : Item -> Html Event
viewItem item =
    li []
        [ input
            [ checked item.completed
            , type_ "checkbox"
            , onCheck (SetCompleted item.id)
            ]
            []
        , input
            [ value item.title
            , onInput (\newTitle -> SetTitle item.id newTitle)
            ]
            []
        , button [ onClick (Remove item.id) ] [ text "Remove" ]
        ]

-- MAIN

main =
    Browser.sandbox { init = init, update = update, view = view }


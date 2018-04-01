module Main exposing (..)

import AnimationFrame
import Char
import Html exposing (..)
import Html.Attributes exposing (height, width)
import Keyboard
import Math.Matrix4 exposing (..)
import Math.Vector2 exposing (..)
import Math.Vector3 as Vec3
import Math.Vector4 exposing (..)
import Task
import Time exposing (Time)
import WebGL as GL


type alias Model =
    { width : Int
    , height : Int
    , camPos : Vec3.Vec3
    , camYaw : Float
    , camSpeed : Float
    , dt : Float
    }


type Action
    = Animate Time
    | KeyMsg Keyboard.KeyCode


type alias Vertex =
    { position : Vec4, color : Vec3.Vec3 }


type alias Uniforms =
    { uView : Mat4, uProjection : Mat4 }


boxMesh : GL.Mesh Vertex
boxMesh =
    GL.triangles
        [ ( Vertex (vec4 0.0 1.0 0.0 1.0) (Vec3.vec3 1.0 0.0 0.0)
          , Vertex (vec4 0.5 0.0 0.0 1.0) (Vec3.vec3 0.0 1.0 0.0)
          , Vertex (vec4 -0.5 0.0 0.0 1.0) (Vec3.vec3 0.0 0.0 1.0)
          )
        , ( Vertex (vec4 -0.5 0.0 0.0 1.0) (Vec3.vec3 0.8 0.2 0.2)
          , Vertex (vec4 0.5 0.0 0.0 1.0) (Vec3.vec3 0.2 0.8 0.2)
          , Vertex (vec4 0.0 -1.0 0.0 1.0) (Vec3.vec3 0.2 0.2 0.8)
          )
        ]


vertexShader : GL.Shader Vertex Uniforms { vColor : Vec3.Vec3 }
vertexShader =
    [glsl|

precision mediump float;
attribute vec4 position;
attribute vec3 color;
varying vec3 vColor;
uniform mat4 uView;
uniform mat4 uProjection;

void main () {
  gl_Position = uProjection * uView * position;
  vColor = color;
}

|]


fragmentShader : GL.Shader {} Uniforms { vColor : Vec3.Vec3 }
fragmentShader =
    [glsl|

precision mediump float;
varying vec3 vColor;

void main () {
  gl_FragColor = vec4(vColor, 1.);
}

|]


projectionMatrix : Model -> Mat4
projectionMatrix { width, height } =
    let
        aspect =
            toFloat width / toFloat height

        near =
            0.1

        far =
            100.0
    in
    makePerspective 67.0 aspect near far


viewMatrix : Model -> Mat4
viewMatrix { camPos, camYaw } =
    let
        translate =
            Math.Matrix4.translate (Vec3.negate camPos) Math.Matrix4.identity

        rotate =
            makeRotate -camYaw (Vec3.vec3 0 1 0)
    in
    mul rotate translate


boxEntity : Model -> GL.Entity
boxEntity model =
    GL.entity
        vertexShader
        fragmentShader
        boxMesh
        { uView = viewMatrix model, uProjection = projectionMatrix model }


view : Model -> Html msg
view model =
    GL.toHtmlWith
        [ GL.alpha True, GL.antialias, GL.depth 1, GL.clearColor 0.6 0.6 0.8 1.0 ]
        [ width model.width, height model.height ]
        [ boxEntity model ]


moveInDirection : (Vec3.Vec3 -> Float) -> (Float -> Vec3.Vec3 -> Vec3.Vec3) -> Vec3.Vec3 -> Float -> Vec3.Vec3
moveInDirection getVal setVal v amount =
    setVal (getVal v + amount) v


moveInY : Vec3.Vec3 -> Float -> Vec3.Vec3
moveInY v amount =
    moveInDirection Vec3.getY Vec3.setY v amount


moveInX : Vec3.Vec3 -> Float -> Vec3.Vec3
moveInX v amount =
    moveInDirection Vec3.getX Vec3.setX v amount


handleKeyboard : Model -> Keyboard.KeyCode -> Model
handleKeyboard model keyCode =
    case Char.fromCode keyCode of
        'W' ->
            { model | camPos = moveInY model.camPos (-model.camSpeed * model.dt) }

        'S' ->
            { model | camPos = moveInY model.camPos (model.camSpeed * model.dt) }

        'A' ->
            { model | camPos = moveInX model.camPos (model.camSpeed * model.dt) }

        'D' ->
            { model | camPos = moveInX model.camPos (-model.camSpeed * model.dt) }

        _ ->
            model


update : Action -> Model -> ( Model, Cmd Action )
update msg model =
    case msg of
        KeyMsg code ->
            ( handleKeyboard model code, Cmd.none )

        Animate time ->
            ( { model | dt = time / 1000.0 }, Cmd.none )


init : ( Model, Cmd Action )
init =
    ( { width = 640
      , height = 480
      , camPos = Vec3.vec3 0 0 2
      , camSpeed = 1.0
      , camYaw = 0.0
      , dt = 16.0 / 1000.0
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Action
subscriptions _ =
    Sub.batch
        [ Keyboard.downs KeyMsg
        , AnimationFrame.diffs Animate
        ]


main : Program Never Model Action
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

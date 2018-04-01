module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (height, width)
import Math.Matrix4 exposing (..)
import Math.Vector2 exposing (..)
import Math.Vector3 exposing (..)
import Math.Vector4 exposing (..)
import WebGL as GL


type alias Model =
    { width : Int
    , height : Int
    , camPos : Vec3
    , camYaw : Float
    }


type alias Vertex =
    { position : Vec4, color : Vec3 }


type alias Uniforms =
    { uView : Mat4, uProjection : Mat4 }


boxMesh : GL.Mesh Vertex
boxMesh =
    GL.triangles
        [ ( Vertex (vec4 0.0 1.0 0.0 1.0) (vec3 1.0 0.0 0.0)
          , Vertex (vec4 0.5 0.0 0.0 1.0) (vec3 0.0 1.0 0.0)
          , Vertex (vec4 -0.5 0.0 0.0 1.0) (vec3 0.0 0.0 1.0)
          )
        , ( Vertex (vec4 -0.5 0.0 0.0 1.0) (vec3 0.8 0.2 0.2)
          , Vertex (vec4 0.5 0.0 0.0 1.0) (vec3 0.2 0.8 0.2)
          , Vertex (vec4 0.0 -1.0 0.0 1.0) (vec3 0.2 0.2 0.8)
          )
        ]


vertexShader : GL.Shader Vertex Uniforms { vColor : Vec3 }
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


fragmentShader : GL.Shader {} Uniforms { vColor : Vec3 }
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
            Math.Matrix4.translate (Math.Vector3.negate camPos) Math.Matrix4.identity

        rotate =
            makeRotate -camYaw (vec3 0 1 0)
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


init : Model
init =
    { width = 640
    , height = 480
    , camPos = vec3 0 0 2
    , camYaw = 0.0
    }


main : Program Never Model {}
main =
    Html.beginnerProgram
        { model = init
        , view = view
        , update = \_ m -> m
        }

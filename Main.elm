module Main exposing (..)

import Html exposing (..)
import Math.Vector2 exposing (..)
import Math.Vector3 exposing (..)
import Math.Vector4 exposing (..)
import WebGL as GL


type alias Vertex =
    { position : Vec4, color : Vec3 }


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


vertexShader : GL.Shader Vertex {} { vColor : Vec3 }
vertexShader =
    [glsl|

precision mediump float;
attribute vec4 position;
attribute vec3 color;
varying vec3 vColor;

void main () {
  gl_Position = position;
  vColor = color;
}

|]


fragmentShader : GL.Shader {} {} { vColor : Vec3 }
fragmentShader =
    [glsl|

precision mediump float;
varying vec3 vColor;

void main () {
  gl_FragColor = vec4(vColor, 1.);
}

|]


boxEntity : GL.Entity
boxEntity =
    GL.entity
        vertexShader
        fragmentShader
        boxMesh
        {}


view : {} -> Html msg
view _ =
    GL.toHtml
        []
        [ boxEntity ]


main : Program Never {} {}
main =
    Html.beginnerProgram
        { model = {}
        , view = view
        , update = \_ _ -> {}
        }

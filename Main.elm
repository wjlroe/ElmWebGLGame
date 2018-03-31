module Main exposing (..)

import Html exposing (..)
import Math.Vector2 exposing (..)
import Math.Vector3 exposing (..)
import WebGL as GL


type alias Vertex =
    { position : Vec2, color : Vec3 }


boxMesh : GL.Mesh Vertex
boxMesh =
    GL.triangles
        [ ( Vertex (vec2 -1 1) (vec3 1 0 0)
          , Vertex (vec2 1 1) (vec3 0 1 0)
          , Vertex (vec2 -1 -1) (vec3 0 0 1)
          )
        , ( Vertex (vec2 -1 -1) (vec3 1 0 0)
          , Vertex (vec2 1 -1) (vec3 0 1 0)
          , Vertex (vec2 1 1) (vec3 0 0 1)
          )
        ]


vertexShader : GL.Shader Vertex {} { vColor : Vec3 }
vertexShader =
    [glsl|

precision mediump float;
attribute vec2 position;
attribute vec3 color;
varying vec3 vColor;

void main () {
  gl_Position = vec4(position, 0.0, 1.0);
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

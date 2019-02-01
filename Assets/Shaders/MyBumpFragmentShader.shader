// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MyBumpFragmentShader" {
    Properties {
        _MainTex("Main Texture", 2D) = "whtie" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass {
            // First the tags
            Tags { "LightMode" = "Vertex" }  
            Cull Back
            Lighting On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; // 这个变量如果使用TRANSFORM_TEX就必须用，因为在宏里使用了

            // define the input of vertex shader
            struct a2v {
                float4 vertex :  POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
            };

            // define the input of fragement shader,
            // or the output of vertex shader
            struct v2f {
                float4 pos :  POSITION;
                float2 uv : TEXCOORD0;
                float3 color : TEXCOORD1;
            };

            v2f vert (a2v v) {
                v2f o;
                // v.text是模型坐标下的
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                o.color = ShadeVertexLights(v.vertex, v.normal);
                return o;
            }

            //  fragment shader会运行在所有像素上，也就是几百万像素，必须特别注意效率
            float4 frag(v2f i) : COLOR {
                float4 c = tex2D (_MainTex, i.uv);
                c.rgb = c.rgb * i.color * 2;
                return c;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
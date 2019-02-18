// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

 Shader "Custom/MyBumpFragmentShader" {
    Properties {
        _MainTex("Main Texture", 2D) = "whtie" {}
        _Bump("Bump", 2D) = "bump" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass {
            // First the tags
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            Lighting On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; // 这个变量如果使用TRANSFORM_TEX就必须用，因为在宏里使用了
            sampler2D _Bump;
            float4 _Bump_ST;

            // define the input of vertex shader
            struct a2v {
                float4 vertex :  POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
                float4 tangent : TANGENT;
            };

            // define the input of fragement shader,
            // or the output of vertex shader
            struct v2f {
                float4 pos :  POSITION;
                float2 uv : TEXCOORD0;

                float2 uv2 : TEXCOORD1; // coordinate in bump texture
                float3 lightDirection : TEXCOORD2;
                LIGHTING_COORDS(3, 4)
            };

            v2f vert (a2v v) {
                v2f o;

                TANGENT_SPACE_ROTATION;// 这个宏定义将新建两个变量binormal和rotation
                // rotation可以在这里用来在模型空间和切线空间之间转换
                o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex)); // not normalized! 在向量空间内
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.texcoord, _Bump);

                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            //  fragment shader会运行在所有像素上，也就是几百万像素，必须特别注意效率
            float4 frag(v2f i) : COLOR {
                float4 c = tex2D (_MainTex, i.uv);
                float3 n = UnpackNormal(tex2D(_Bump, i.uv2));

                float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // lightDirection is the unnormalized vector from light source to point on model
                float cosTheta = saturate(dot(normalize(n), normalize(i.lightDirection)));
                // float lightDistanceSq = dot(i.lightDirection, i.lightDirection);
                // float atten = 1.0 / (1.0 + lightDistanceSq * unity_LightAtten[0].z); //光源因为距离而产生衰减，取决于是点光源还是Directed
                float atten = LIGHT_ATTENUATION(i);

                // _LightColor0存了与重要的光源，最近的或者最亮的
                lightColor += _LightColor0.rgb * (cosTheta * atten);
                c.rgb = lightColor * c.rgb * 2;
                return c;
            }
            ENDCG
        }

        Pass {
            // First the tags
            Tags { "LightMode" = "ForwardAdd" }  
            Cull Back
            Lighting On
            Blend One One  

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; // 这个变量如果使用TRANSFORM_TEX就必须用，因为在宏里使用了
            sampler2D _Bump;
            float4 _Bump_ST;

            // define the input of vertex shader
            struct a2v {
                float4 vertex :  POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
                float4 tangent : TANGENT;
            };

            // define the input of fragement shader,
            // or the output of vertex shader
            struct v2f {
                float4 pos :  POSITION;
                float2 uv : TEXCOORD0;

                float2 uv2 : TEXCOORD1; // coordinate in bump texture
                float3 lightDirection : TEXCOORD2;
                LIGHTING_COORDS(3, 4)
            };

            v2f vert (a2v v) {
                v2f o;

                TANGENT_SPACE_ROTATION;// 这个宏定义将新建两个变量binormal和rotation
                // rotation可以在这里用来在模型空间和切线空间之间转换
                o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex)); // not normalized! 在向量空间内
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.texcoord, _Bump);

                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            //  fragment shader会运行在所有像素上，也就是几百万像素，必须特别注意效率
            float4 frag(v2f i) : COLOR {
                float4 c = tex2D (_MainTex, i.uv);
                float3 n = UnpackNormal(tex2D(_Bump, i.uv2));

                float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // lightDirection is the unnormalized vector from light source to point on model
                float cosTheta = saturate(dot(normalize(n), normalize(i.lightDirection)));
                // float lightDistanceSq = dot(i.lightDirection, i.lightDirection);
                // float atten = 1.0 / (1.0 + lightDistanceSq * unity_LightAtten[0].z); //光源因为距离而产生衰减，取决于是点光源还是Directed
                float atten = LIGHT_ATTENUATION(i);

                // _LightColor0存了与重要的光源，最近的或者最亮的
                lightColor += _LightColor0.rgb * (cosTheta * atten);
                c.rgb = lightColor * c.rgb * 2;
                return c;
            }
            ENDCG
        }        
    }
    FallBack "Diffuse"
}
// a Phisic Based Shader using GGX, a microfacet BRDF
Shader "EasyLighting/PBS/GGX" {
    Properties {
        _MainTex {"Main Texture", 2D} = "white" {}
        _EtaI {"Refraction Index of Incident Side", Float} = 1.0
        _EtaO {"Refraction Index of Incident Side", Float} = 1.0
        _EtaT {"Refraction Index of Incident Side", Float} = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
		LOD 200
    }

    Pass {
        Tags {"LightMode" = "ForwardBase"}
        Lighting On

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        #define EPSILON 10e-5f

        struct a2v {
            float2 uv : TEXCOORD0;
            float3 normal : NORMAL;
            float4 vertex : POSITION;
        }

        struct v2f {
            float2 uv : TEXCOORD0;
            float4 pos_clip : SV_POSITION;
            float4 pos_world : TEXCOORD1;
            float3 normal_obj : NORMAL;
        }

        sampler2D _MainTex;
        sample2D _MainTex_ST;

        v2f vert(a2v v) {
            v2f o;
            o.pos_world = mul(UNITY_MATRIX_M, v.vertex);
            o.pos_clip = UnityObjectToClipPos(v.vertex.xyz);
            o.normal_obj = v.normal;
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        }

        // Fresnel term
        // COOK R. L., TORRANCE K. E.: A reflectance model for computer graphics. ACM Transactions on Graphics 1, 1 (Jan. 1982), 7–24.
        fixed3 F(float3 i, float3 hr){
            fixed c = abs(i, m);
        }

        // Bidirectional shadowing-masking function
        fixed3 G(float3 i, float3 o, float3 hr) {

        }

        // Microfacet distribution function
        fixed3 D(float3 hr) {

        }
    
        fixed4 frag(v2f IN) : SV_TARGET {
            // Direction from which light is incident
            float3 i_obj = UnityWorldToObjectDir(_WorldSpaceLightPos0 - IN.pos_world).xyz;
            // Direction in which light is scattered
            // since we don't consider indirect light, o_obj is camera direction
            float3 o_obj = mul(unity_WorldToObject, _WorldSpaceCameraPos);
            // Macrosurface normal
            float3 n_obj = IN.normal_obj;
            // Microsurface normal
            // float3 m_obj = 
            // Half-direction for reflection
            float3 hr_obj = normalize(normalize(i_obj) + normalize(o_obj));
            // Half-direction for transmission
            // float3 ht_obj
            // f_s = f_r + f_t
            fixed IdotN = abs(dot(i_obj, n_obj)) + EPSILON;
            fixed OdotN = abs(dot(o_obj, n_obj)) + EPSILON;
            fixed4 fr = F(i_obj, hr_obj) * G(i_obj, o_obj, hr_obj) * D(hr_obj) / 4. / IdotN / OdotN;
            
            

        }
        ENDCG
    }
}
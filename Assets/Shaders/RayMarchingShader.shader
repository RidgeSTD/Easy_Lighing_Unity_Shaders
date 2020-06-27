Shader "EasyLighting/RayMarchingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define SURF_DIST 1e-3
            #define MAX_STEP 100
            #define MAX_DIST 1e2

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 ro : POSITION2;
                float3 hitPos : POSITION3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                o.hitPos = v.vertex;
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float GetDist(float3 p) {
                return length(p) - 0.2;
            }

            float3 GetNormal(float3 p) {
                float2 e = float2(1e-2, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p - e.xyy),
                    GetDist(p - e.yxy),
                    GetDist(p - e.yyx)
                );
                // return float3(0, 1, 0);
                return normalize(n);
            }

            float RayMarching(float3 ro, float3 rd) {
                float dO = 0;
                float dS;
                float3 p = ro;
                for (int i = 0; i < MAX_STEP; i++) {
                    p = ro + dO * rd;
                    dS = GetDist(p);
                    dO += dS;
                    if (dS < SURF_DIST || dO > MAX_DIST)
                        break;
                }
                
                return dO;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ray marching
                fixed4 col = fixed4(0, 0, 0, 1);
                float2 uv = i.uv - 0.5;
                // col.xy = uv;
                
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - i.ro);

                float d = RayMarching(ro, rd);
                if (d >= MAX_DIST) {
                    discard;
                } else {
                    float3 p = ro + rd * d;
                    float3 n = GetNormal(p);
                    
                    float3 L = mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz;
                    float l = dot(n, L);
                    col.rgb = fixed3(l, l, l);
                }

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}

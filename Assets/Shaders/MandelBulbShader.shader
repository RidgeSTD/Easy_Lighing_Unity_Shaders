Shader "EasyLighting/MandelBulbShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Scale", Range(0.1, 2)) = 1
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

            float _Scale;
            float Power;
            float ThetaShift;
            float PhiShift;

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
                o.hitPos = v.vertex / _Scale;
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // iq codes
            float map( in float3 p, out float4 resColor )
            {
                float3 w = p;
                float m = dot(w,w);

                float4 trap = float4(abs(w),m);
                float dz = 1.0;
                
                
                for( int i=0; i<4; i++ )
                {
            #if 0
                    float m2 = m*m;
                    float m4 = m2*m2;
                    dz = 8.0*sqrt(m4*m2*m)*dz + 1.0;

                    float x = w.x; float x2 = x*x; float x4 = x2*x2;
                    float y = w.y; float y2 = y*y; float y4 = y2*y2;
                    float z = w.z; float z2 = z*z; float z4 = z2*z2;

                    float k3 = x2 + z2;
                    float k2 = inversesqrt( k3*k3*k3*k3*k3*k3*k3 );
                    float k1 = x4 + y4 + z4 - 6.0*y2*z2 - 6.0*x2*y2 + 2.0*z2*x2;
                    float k4 = x2 - y2 + z2;

                    w.x = p.x +  64.0*x*y*z*(x2-z2)*k4*(x4-6.0*x2*z2+z4)*k1*k2;
                    w.y = p.y + -16.0*y2*k3*k4*k4 + k1*k1;
                    w.z = p.z +  -8.0*y*k4*(x4*x4 - 28.0*x4*x2*z2 + 70.0*x4*z4 - 28.0*x2*z2*z4 + z4*z4)*k1*k2;
            #else
                    dz = 8.0*pow(sqrt(m),7.0)*dz + 1.0;
                    //dz = 8.0*pow(m,3.5)*dz + 1.0;
                    
                    float r = length(w);
                    float b = 8.0*acos( w.y/r);
                    float a = 8.0*atan( float2(w.x, w.z) );
                    w = p + pow(r,8.0) * float3( sin(b)*sin(a), cos(b), sin(b)*cos(a) );
            #endif        
                    
                    trap = min( trap, float4(abs(w),m) );

                    m = dot(w,w);
                    if( m > 256.0 )
                        break;
                }

                resColor = float4(m,trap.yzw);

                return 0.25*log(m)*sqrt(m)/dz;
            }


            // loicvdb's implementation
            // https://www.shadertoy.com/view/wl2SDt
            float distanceEstimation(float3 pos) {
                if(length(pos) > 1.5) return length(pos) - 1.2;
                float3 z = pos;
                float dr = 1.0, r = 0.0, theta, phi;
                for (int i = 0; i < 15; i++) {
                    r = length(z);
                    if (r>1.5) break;
                    dr =  pow( r, Power-1.0)*Power*dr + 1.0;
                    theta = acos(z.z/r) * Power + ThetaShift;
                    phi = atan(float2(z.y,z.x)) * Power + PhiShift;
                    float sinTheta = sin(theta);
                    z = pow(r,Power) * float3(sinTheta*cos(phi), sinTheta*sin(phi), cos(theta)) + pos;
                }
                return 0.5*log(r)*r/dr;
            }

            float3 normalEstimation(float3 pos){
                float dist = distanceEstimation(pos);
                float3 xDir = float3(dist, 0, 0);
                float3 yDir = float3(0, dist, 0);
                float3 zDir = float3(0, 0, dist);
                return normalize(float3(distanceEstimation(pos + xDir),
                                        distanceEstimation(pos + yDir),
                                        distanceEstimation(pos + zDir))
                                - float3(dist, dist, dist));
            }
            // end of loicvdb's implementation


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

            // float RayMarching(float3 ro, float3 rd, out fixed4 resCol) {
            float RayMarching(float3 ro, float3 rd) {
                float dO = 0;
                float dS;
                float3 p = ro;
                // fixed4 col;
                for (int i = 0; i < MAX_STEP; i++) {
                    p = ro + dO * rd;
                    // dS = GetDist(p);
                    // 
                    // dS = map(p, col); // iq's implementation
                    dS = distanceEstimation(p); // loicvdb's implementation
                    dO += dS;
                    if (dS < SURF_DIST || dO > MAX_DIST) {
                        // resCol = col;
                        break;
                    }
                    
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

                Power = _Time.y;
                Power = 3.0 + 5.0 * abs(_SinTime.y);
                ThetaShift = _Time.z;
                PhiShift = _Time.z;


                // float d = RayMarching(ro, rd, col);
                float d = RayMarching(ro, rd);
                if (d >= MAX_DIST) {
                    discard;
                } else {
                    float3 p = ro + rd * d;
                    // float3 n = GetNormal(p);
                    float3 n = normalEstimation(p);
                    
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

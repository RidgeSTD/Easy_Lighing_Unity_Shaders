struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct v2f {
    float2 uv : TEXCOORD0;
    float4 pos_clip : SV_POSITION;
    float4 pos_world : TEXCOORD1;
    float3 normal : NORMAL; // normal in world space
    float3 lightDirection_world : TEXCOORD2;
    float3 cameraDirection_world_norm : TEXCOORD3;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _n;
float _ka;
float _kd;
float _ks;

v2f vert (appdata v)
{
    v2f o;
    o.pos_clip = UnityObjectToClipPos(v.vertex);
    o.pos_world = mul(UNITY_MATRIX_M, v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = mul(UNITY_MATRIX_M, float4(v.normal, 0.)).xyz;
    o.lightDirection_world = (_WorldSpaceLightPos0 - o.pos_world).xyz;
    o.cameraDirection_world_norm = normalize((_WorldSpaceCameraPos - o.pos_world).xyz);
    return o;
}
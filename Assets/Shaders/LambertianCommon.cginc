struct appdata {
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT; // this is necessary for macro TANGENT_SPACE_ROTATION
};

struct v2f {
    float2 uv : TEXCOORD0;
    float4 pos_clip : SV_POSITION;
    float3 lightDirection_obj : TEXCOORD2;
    float3 normal : NORMAL;
};

sampler2D _MainTex;
float4 _MainTex_ST;
uniform float4 _LightColor0; // main light source


v2f vert (appdata v) {
    v2f o;
    TANGENT_SPACE_ROTATION;
    
    o.lightDirection_obj = ObjSpaceLightDir(v.vertex);
    o.pos_clip = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = v.normal;
    return o;
}
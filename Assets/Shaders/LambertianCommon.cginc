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
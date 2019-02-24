#define EPSILON 10e-6f
#define PI 3.14159265358979323846

struct a2v {
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 vertex : POSITION;
};

struct v2f {
    float2 uv : TEXCOORD0;
    float4 pos_obj : TEXCOORD1;
    float4 pos_clip : SV_POSITION;
    float3 normal_obj : NORMAL;
    float F0 : TEXCOORD3;
    float3 lightDirection_obj : TEXCOORD2;
    float4 pos_world : TEXCOORD4;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _EtaI;
float _EtaT;
float _K;
float _D;

v2f vert(a2v v) {
    v2f o;
    o.pos_obj = v.vertex;
    o.pos_clip = UnityObjectToClipPos(v.vertex.xyz);
    o.normal_obj = normalize(v.normal);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.F0 = pow((_EtaI - _EtaT) / (_EtaI + _EtaT), 2);
    o.lightDirection_obj = ObjSpaceLightDir(v.vertex);
    o.pos_world = mul(UNITY_MATRIX_M, v.vertex);
    return o;
}

// Fresnel term, Schlick's approximation
// Schlick C. An inexpensive BRDF model for physically‐based rendering[C]//Computer graphics forum. Edinburgh, UK: Blackwell Science Ltd, 1994, 13(3): 233-246.
float F_Schlick(float3 L, float3 H_r, float F0){
    return F0 + (1 - F0) * pow((1 - dot(L, H_r)), 5);
}

float G_Smith(float NdotV) {
    return NdotV / (NdotV * (1.0 - _K) + _K);
}

// Bidirectional shadowing-masking function
// Used Smith G Approximate, according to Walter et al.
float G_GGX(float LdotN, float VdotN) {
    return G_Smith(LdotN) * G_Smith(VdotN);
}

// Microfacet distribution function
// Trowbridge-Reitz GGX function
float D_GGX_TR(float3 N, float3 H) {
    float d2 = _D * _D;
    return d2 / (PI * pow((pow(dot(N, H), 2) * (d2 - 1) + 1), 2));

}

float4 frag(v2f IN) : SV_TARGET {
    // TODO

    float4 col = tex2D(_MainTex, IN.uv);
    // Direction from which light is incident
    float3 L = normalize(IN.lightDirection_obj);
    // Direction in which light is scattered
    // since we don't consider indirect light, o_obj is camera direction
    float3 O = normalize(ObjSpaceViewDir(IN.pos_obj));
    // Macrosurface normal
    float3 N = IN.normal_obj;
    // Microsurface normal
    // float3 m_obj = 
    // Half-direction for reflection
    float3 H = normalize(L + O);
    // Half-direction for transmission
    // float3 ht_obj
    // f_s = f_r + f_t
    float LdotN = abs(dot(L, N)) + EPSILON;
    float VdotN = abs(dot(O, N)) + EPSILON;
    float F = F_Schlick(L, H, IN.F0);
    float G = G_GGX(LdotN, VdotN);
    float D = D_GGX_TR(N, H);
    float fr = F * G * D / 4. / LdotN / VdotN;
    return col * fr * VdotN;
    // float jkl = 1 / 180. / LdotN / VdotN;
    // return float4(LdotN,LdotN,LdotN, 1);
}
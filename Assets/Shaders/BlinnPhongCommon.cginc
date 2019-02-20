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
    float3 normal_world : NORMAL; // normal in world space
    // float3 lightDirection_world : TEXCOORD2;
    // float3 cameraDirection_world_norm : TEXCOORD3;
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
    o.normal_world = normalize(mul(UNITY_MATRIX_M, float4(v.normal, 0.)).xyz);
    // o.lightDirection_world = (_WorldSpaceLightPos0 - o.pos_world).xyz;
    // o.cameraDirection_world_norm = normalize((_WorldSpaceCameraPos - o.pos_world).xyz);
    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    // DirectionalLight的w是0，其方向与定点位置无关，此时_WorldSpaceLightPos0.w==0。反之如果是点光源，应计算与定点的相对位置
    float3 L = (_WorldSpaceLightPos0 - i.pos_world).xyz * _WorldSpaceLightPos0.w + _WorldSpaceLightPos0.xyz * (1- _WorldSpaceLightPos0.w);
    float3 V = normalize((_WorldSpaceCameraPos - i.pos_world).xyz);
    // Blinn-Phong模型公式: I = k_a * I_L + k_d * I_L * dot(N, L) + k_s * I_L * dot(R_L, V) ^ n
    fixed4 col = tex2D(_MainTex, i.uv);
    float distanceSq = dot(L, L);
    // 如果这里是Directional light就不应该考虑衰减，否则w是1，就考虑衰减了
    float atten = 1.0 / (1.0 + (distanceSq + unity_LightAtten[0].z) * _WorldSpaceLightPos0.w);
    float3 R = normalize(reflect(-L, i.normal_world));

    float4 lightColor = _ka * unity_AmbientSky; // 环境光
    lightColor += _kd * _LightColor0 * saturate(dot(i.normal_world, normalize(L))); // diffuse反射
    lightColor += _ks * _LightColor0  * pow(saturate(dot(R, V)), _n); // specular反射
    return col * lightColor; // 将光源与材料本身颜色叠加
}
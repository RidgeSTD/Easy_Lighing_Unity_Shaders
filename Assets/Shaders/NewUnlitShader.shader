// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "ApcShader/SpecularPerPixel"
{
	//属性
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1.0, 255)) = 20
	}
 
	//子着色器	
	SubShader
	{
		Pass
		{
			//定义Tags
			Tags{ "LightingMode" = "ForwardBase" }
 
			CGPROGRAM
			//引入头文件
			#include "Lighting.cginc"
 
			//定义函数
			#pragma vertex vert
			#pragma fragment frag
 
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
 
			//定义结构体：应用阶段到vertex shader阶段的数据
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
 
			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : NORMAL;
				float3 worldPos : TEXCOORD1;
			};
 
			//顶点shader
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线转化到世界空间
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// o.worldNormal = normalize(mul((float3x3)unity_WorldToObject, v.normal));
				//顶点位置转化到世界空间
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
 
			//片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse;
				//归一化光方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//再次归一化worldNorml
				fixed3 worldNormal = normalize(i.worldNormal);
				//diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
				//计算反射方向R,worldLight表示光源方向（指向光源），入射光线方向为-worldLight，通过reflect函数（入射方向，法线方向）获得反射方向
				fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
				//计算该像素对应位置（顶点计算过后传给像素经过插值后）的观察向量V，相机坐标-像素位置
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				//计算高光值，高光值与反射光方向与观察方向的夹角有关，夹角为dot（R,V），最后根据反射系数计算的反射值为pow（dot（R,V），Gloss）
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0.0,dot(reflectDir, viewDir)), _Gloss);
				//冯氏模型：Diffuse + Ambient +　Specular
				fixed3 color = diffuse + ambient + specular;
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
 
	//前面的Shader失效的话，使用默认的Diffuse
	FallBack "Diffuse"
}
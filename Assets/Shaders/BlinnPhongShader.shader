Shader "prac/BlinnPhongShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_n ("BlinnPhong Exponent", Range(0, 10)) = 2.0
		_ka ("BlinnPhong Abient Degree", Range(0, 10)) = 1.0
		_kd ("BlinnPhong Diffuse Degree", Range(0, 10)) = 1.0
		_ks ("BlinnPhong Specular Degree", Range(0, 10)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags {
				// base light pass for primary light source
				"LightMode" = "ForwardBase"
			}
			Lighting On
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragBase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "BlinnPhongCommon.cginc"

			fixed4 fragBase (v2f i) : SV_Target
			{
				// I = k_a * I_L + k_d * I_L * dot(N, L) + k_s * I_L * dot(R_L, V) ^ n
				fixed4 col = tex2D(_MainTex, i.uv);
				float distanceSq = dot(i.lightDirection_world, i.lightDirection_world);
				// 如果这里是Directional light就不应该考虑衰减，否则w是1，就考虑衰减了
				float atten = 1.0 / (1.0 + (distanceSq + unity_LightAtten[0].z) * _WorldSpaceLightPos0.w);
				float3 L = normalize(i.lightDirection_world);
				float3 R = normalize(2 * i.normal - L);

				float4 lightColor = _ks * unity_AmbientSky; // k_a * I_L
				lightColor += _kd * _LightColor0 * saturate(dot(i.normal, L));
				lightColor += _ks * _LightColor0  * pow(saturate(dot(R, i.cameraDirection_world_norm)), _n);
				return col * lightColor;
			}
			ENDCG
		}

		Pass {
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One
			Lighting On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragAdd

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "BlinnPhongCommon.cginc"

			fixed4 fragAdd (v2f i) : SV_Target
			{
				// I = k_a * I_L + k_d * I_L * dot(N, L) + k_s * I_L * dot(R_L, V) ^ n
				fixed4 col = tex2D(_MainTex, i.uv);
				float distanceSq = dot(i.lightDirection_world, i.lightDirection_world);
				// 如果这里是Directional light就不应该考虑衰减，否则w是1，就考虑衰减了
				float atten = 1.0 / (1.0 + (distanceSq + unity_LightAtten[0].z) * _WorldSpaceLightPos0.w);
				float3 L = normalize(i.lightDirection_world);
				float3 R = normalize(2 * i.normal - L);

				// no ambient light for sub-light source
				float4 lightColor = _kd * _LightColor0 * saturate(dot(i.normal, L));
				lightColor += _ks * _LightColor0  * pow(saturate(dot(R, i.cameraDirection_world_norm)), _n);
				return col * lightColor;
			}
			ENDCG
		}
	}
}

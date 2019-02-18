Shader "prac/LambertianShader" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {
			Tags {
				// base light pass for primary light source
				"LightMode" = "ForwardBase"
			}
			Lighting On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#if !defined(LAMBERTIAN_COMMON_INCLUDED)
			#define LAMBERTIAN_COMMON_INCLUDED
			#include "LambertianCommon.cginc"
			#endif

			uniform float4 _LightColor0; // main light source

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v) {
				v2f o;
				TANGENT_SPACE_ROTATION;
				
				o.lightDirection_obj = ObjSpaceLightDir(v.vertex);
				o.pos_clip = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = tex2D(_MainTex, i.uv);

				// lambertian model starts
				fixed3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float distanceSq = dot(i.lightDirection_obj, i.lightDirection_obj);
				// attenuation from both distance and unity default setting 衰减
				// float atten = 1.0 / (1.0 + distanceSq + unity_LightAtten[0].z);
				float atten = 1.0 / (1.0 + unity_LightAtten[0].z);
				lightColor += _LightColor0 * saturate(dot(i.normal, normalize(i.lightDirection_obj))) * atten;
				
				col.rgb = col.rgb * lightColor;
				return col;
			}
			ENDCG
		}

		Pass {
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One
			Lighting On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#if !defined(LAMBERTIAN_COMMON_INCLUDED)
			#define LAMBERTIAN_COMMON_INCLUDED
			#include "LambertianCommon.cginc"
			#endif

			uniform float4 _LightColor0; // main light source

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v) {
				v2f o;
				TANGENT_SPACE_ROTATION;
				
				o.lightDirection_obj = ObjSpaceLightDir(v.vertex);
				o.pos_clip = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = tex2D(_MainTex, i.uv);

				// lambertian model starts
				fixed3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float distanceSq = dot(i.lightDirection_obj, i.lightDirection_obj);
				// attenuation from both distance and unity default setting 衰减
				float atten = 1.0 / (1.0 + distanceSq + unity_LightAtten[0].z);
				lightColor += _LightColor0 * saturate(dot(i.normal, normalize(i.lightDirection_obj))) * atten;
				
				col.rgb = col.rgb * lightColor;
				return col;
			}
			ENDCG
		}
	}
}

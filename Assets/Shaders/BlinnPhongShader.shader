﻿Shader "EasyLighting/BlinnPhongShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_n ("BlinnPhong Exponent", Float) = 45
		_ka ("BlinnPhong Abient Degree", Float) = 1.0
		_kd ("BlinnPhong Diffuse Degree", Float) = 1.0
		_ks ("BlinnPhong Specular Degree", Float) = 1.0
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
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "BlinnPhongCommon.cginc"

			
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
			#include "Lighting.cginc"
			#include "BlinnPhongCommon.cginc"

			ENDCG
		}
	}
}
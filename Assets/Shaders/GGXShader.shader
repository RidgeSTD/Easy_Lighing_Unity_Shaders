// a Phisic Based Shader using GGX, a microfacet BRDF
Shader "EasyLighting/PBS/GGX" {
    Properties {
        _MainTex ("Main Texture", 2D) = "white" {}
        _EtaI ("Refraction Index of Incident Side", Range(0, 1)) = 1.0
        _EtaT ("Refraction Index of Incident Side", Range(0, 1)) = 1.0
        _K ("Parameter for G Function", Range(0, 1)) = 1.0
        _D ("Roughness for NDF", Range(0, 1)) = 1.0
        _DiffWeight("Diffuse Weight", Range(0, 1)) = 0.5
        _SpecWeight("Specular Weight", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
		LOD 200

        Pass {
            Tags {"LightMode" = "ForwardBase"}
            Lighting On

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "GGXShader.cginc"

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardAdd" }
			Blend One One
            Lighting On

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "GGXShader.cginc"

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }
}
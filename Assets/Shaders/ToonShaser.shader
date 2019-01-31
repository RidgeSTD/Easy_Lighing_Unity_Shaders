Shader "Custom/ToonShader" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "red" {}
        _MainBump ("Bump Texture", 2D) = "bump" {}
        _Tooniness ("Tooniness", Range(0.1, 20)) = 4
        _ColorMerge ("Color Merge", Range(0.1, 20.0)) = 4
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface mysurf Toon finalcolor:myfinal
        
        sampler2D _MainTex;
        sampler2D _MainBump;
        float _Tooniness;
        float _ColorMerge;

        struct Input {
            float2 uv_MainTex;
            float2 uv_MainBump;
        };

        // struct SurfaceOutput
        // {
        //     fixed3 Albedo;  // diffuse color
        //     fixed3 Normal;  // tangent space normal, if written
        //     fixed3 Emission;
        //     half Specular;  // specular power in 0..1 range
        //     fixed Gloss;    // specular intensity
        //     fixed Alpha;    // alpha for transparencies
        // };
        void mysurf (Input IN, inout SurfaceOutput o) {
            // tex2D从2D纹理中提取颜色
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal ( tex2D(_MainBump, IN.uv_MainBump));
            // _ColorMerge 调整颜色种类
            o.Albedo = floor(c.rgb * _ColorMerge) / _ColorMerge; 
            o.Alpha = c.a;
        }
        
        // 这里的输入是来自Surface着色器的输出o
        half4 LightingToon (SurfaceOutput s, half3 lightDir, half atten) {
            half4 c;
            half NdotL = dot(s.Normal, lightDir);
            NdotL = floor(NdotL * _Tooniness) / _Tooniness; // _Tooniness现在用来调整光照级数
            c.rgb = s.Albedo * _LightColor0.rgb * NdotL * atten * 2;
            c.a = s.Alpha;
            return c;
        }
        void myfinal(Input IN, SurfaceOutput o, inout fixed4 color) {
            // do nothing for now
        }
        ENDCG
    }
    FallBack "Diffuse"
}
Shader "Custom/SnowSurfaceShader" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}

		_Bump ("Bump Texture", 2D) = "bump" {}

		_Snow ("Snow Level", Range(0, 1)) = 0
		_SnowColor ("Snow Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SnowDirection ("Snow Direction", Vector) = (0, 1, 0)
		_SnowDepth ("Snow Depth", Range(0, 0.3)) = 0.1
	}

    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert
		// 在这里加入两个同名称的变量，作为Property的引用
		sampler2D _MainTex;
		sampler2D _Bump;
		float _Snow;
		float4 _SnowColor;
		float3 _SnowDirection;
		float _SnowDepth;

		// shader的输入作为一个结构体
        struct Input {
			float2 uv_MainTex; // 注贴图的uv坐标
			float2 uv_Bump;

			float3 worldNormal;
			INTERNAL_DATA
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
			// half半精度, 是一种较新的浮点类型。 
			// 英伟达在2002年初发布的Cg语言中称它作 half 类型，并首次在2002年末发布的GeForce FX中实现。
			// 与8位或16位整数的相比，它的优点是可以提升动态范围，从而使高对比度图片中更多细节得以保留。
			// 与单精度浮点数相比，它的优点是只需要一半的存储空间和带宽（但是会以精度和数值范围为代价）
			
			half4 c = tex2D (_MainTex, IN.uv_MainTex); // 从MainTex取出对应值
			o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump)); // 获取法线向量

			if (dot(WorldNormalVector(IN, o.Normal), _SnowDirection.xyz) > lerp(1, -1, _Snow)) {
				// lerp(st, en, t)是线性插值的意思，从st到en, t是0到1之间的比重参数
				o.Albedo = _SnowColor.rgb;
			} else {
				o.Albedo = c.rgb;
			}
			o.Alpha = c.a;
        }

		void vert (inout appdata_full v) {
			float4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection); // 将世界坐标系下的向量换成模型坐标系
			
			if (dot(v.normal, sn.xyz) >= lerp(1, -1, _Snow * 2.0 / 3.0 )) {
				v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;
			}
		}
        ENDCG
    }
    FallBack "Diffuse"
}
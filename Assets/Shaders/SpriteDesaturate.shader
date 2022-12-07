// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sprites/Desaturate"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_Saturate ("Saturate", Range (0, 1)) = 1
		_Bright ("Brightness", Float) = 0
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		
		// required for UI.Mask
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
		 }

		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha

		Pass
		{
//		    Stencil {
//                Ref 2
//                Comp Less
//                Pass keep 
//                Fail decrWrap 
//                ZFail keep
//            }
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
//				float saturation: FLOAT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float saturation: FLOAT;
				fixed brightness: FIXED;
				half2 texcoord  : TEXCOORD0;
			};
			
			fixed4 _Color;
			fixed _Saturate;
			fixed _Bright;
			
			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				OUT.saturation = _Saturate;
				OUT.brightness = _Bright;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}


			fixed4 frag(v2f IN) : SV_Target
			{
				float luminance = (tex2D(_MainTex, IN.texcoord).r + tex2D(_MainTex, IN.texcoord).g + tex2D(_MainTex, IN.texcoord).b)/3.0;
				fixed4 colorSature = fixed4(lerp(luminance, tex2D(_MainTex, IN.texcoord).r, IN.saturation) + IN.brightness,	lerp(luminance, tex2D(_MainTex, IN.texcoord).g, IN.saturation) + IN.brightness, lerp(luminance, tex2D(_MainTex, IN.texcoord).b, IN.saturation) + IN.brightness, tex2D(_MainTex, IN.texcoord).a);
				fixed4 c = colorSature * IN.color;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
}

Shader "Learning/Ch6/half_lambert"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
        // 新增兩個屬性，對漫反射進行調整
        _A ("Half Lambert Scale", Range(0.1, 1.0)) = 0.5
        _B ("Half Lambert Offset", Range(0.1, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
            };

            fixed4 _Diffuse;
            fixed _A;
            fixed _B;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                fixed3 worldNormalDir = normalize(i.normal);

                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 由saturate改為，由兩個變數進行調整
                fixed3 half_lambert = dot(worldNormalDir, worldLightDir) * _A + _B;

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * half_lambert;

                return fixed4(ambient + diffuse, 1);
            }
            ENDCG
        }
    }
}
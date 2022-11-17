// 與逐頂點並無太大的差異，只是將光源計算至fragment(pixel) shader中
Shader "Learning/Diffuse-Per-Pixel"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
   
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
              
                fixed3 diffIntensity = saturate(dot(worldNormalDir, worldLightDir));

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * diffIntensity;

                return fixed4(ambient + diffuse, 1);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
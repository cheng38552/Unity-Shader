Shader "Learning/Specular_Phong"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
        // 高光反射的顏色
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        // 這裡的gloss表示反射光亮點的大小
        _Gloss ("Gloss", float) = 32.0
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
                // 需要將物件的頂點由物件空間轉至世界空間
                float3 worldPos : TEXCOORD0;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex.xyz);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                fixed3 worldNormalDir = normalize(i.normal);

                fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormalDir, worldLightDir));
                
                // ---Phong的作法---
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormalDir));
                
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);        
                
                // ---Phong的作法結束---

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }

    Fallback "Specular"
}
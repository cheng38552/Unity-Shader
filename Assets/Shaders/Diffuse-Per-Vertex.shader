Shader "Learning/Diffuse-Per-Vertex"
{
    Properties
    {
        // 定義一個顏色屬性於Unity Editor中調整
        _Diffuse ("Diffuse Color", Color) = (1, 1, 1, 1)
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

            // 來自上方定義的_Diffuse屬性
            fixed4 _Diffuse;
        
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };
            
            v2f vert(appdata_base v)
            {
                v2f o;

                // 將物件由模型空間轉換至裁剪空間
                o.pos = UnityObjectToClipPos(v.vertex);

                // 獲得環境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 將物件的法向量轉換至世界空間，記得線性代數的計算是由右至左
                fixed3 worldNormalDir = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // 獲得光的方向向量
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 計算漫反射係數
                // saturate(x): 將x擷取至[0, 1]，我們不希望獲得負值的結果
                fixed diffIntensity = saturate(dot(worldNormalDir, worldLightDir));

                // 將光的顏色、物件的顏色、反射的係數"混合"
                // Diffuse = I * C * dot(L, N)
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * diffIntensity;

                // 將環境光與漫反射進行"疊加"
                o.color = ambient + diffuse;

                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                // 取得由上一階段vertex shader所計算的color
                return fixed4(f.color, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Specular"
}
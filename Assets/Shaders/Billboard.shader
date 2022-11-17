Shader "Learning/Billboard" {
    Properties{
        _MainTex("Main Tex", 2D) = "white" {}
        _Color("Color Tint", Color) = (1, 1, 1, 1)
    }

        SubShader{

            // 兩個標籤
            // IgnoreProjector: True的話表示不受Projector元件影響
            // DiableBatching: 關閉批次處理是因為頂點會因為會需要對模型空間的頂點做處理，
            //                 Batching會導致資料遺失
            Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True"}

            Pass {
                Tags { "LightMode" = "ForwardBase" }

                ZWrite Off
                Blend SrcAlpha OneMinusSrcAlpha
                Cull Off

                CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag

                #include "Lighting.cginc"

                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed4 _Color;

                struct v2f {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

                v2f vert(appdata_base v) {
                    v2f o;

                    float3 center = float3(0, 0, 0);
                    float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos, 1));

                    float3 normal = viewer - center;
                    float3 normalDir = normalize(normal);

                    float3 upDir = float3(0, 1, 0);
                    float3 rightDir = normalize(cross(upDir, normalDir));
                    upDir = normalize(cross(normalDir, rightDir));

                    float3 centerOffs = v.vertex.xyz - center;
                    float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                    o.pos = UnityObjectToClipPos(float4(localPos, 1));
                    o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

                    return o;
                }

                fixed4 frag(v2f i) : SV_Target {
                    fixed4 c = tex2D(_MainTex, i.uv);
                    c.rgb *= _Color.rgb;

                    return c;
                }

                ENDCG
            }
        }
}
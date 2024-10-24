Shader "Manana/Gaussian Blur"
{
    Properties{
        _MainTex("Main Texture", 2D) ="white"{}
        _PixelOffset("Pixel offset", float) = 1
    } 
    
    Subshader{
        Tags{
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        
        ZWrite Off
        
        
        Pass{
            Name "Gaussian3X3"
            
            HLSLPROGRAM
            
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Input{
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            

            sampler2D _MainTex;
            float4 _MainTex_TexelSize; //sufijo para el tamaño de las texturas
            float _PixelOffset;

            float4 ApplyKernel3x3(sampler2D tex, float2 uv, float pixelOffset, float2 texelSize, float kernel[9])
            {

                float4 result =0;

                [unroll(9)]
                for (int y=-1; y < 2;++y)
                {
                    for (int x=-1; x<2;++x)
                    {
                        float2 offset = float2(x,y)*texelSize*pixelOffset;
                        result += tex2D(tex, uv+offset) * kernel[(x+1)+(y+1)*3];
                    }
                }

                return result;
            }

            Varyings Vertex(Input IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 Fragment(Varyings IN ): SV_Target{
                const float GaussianKernel[9] = {
                    0.0625, 0.125, 0.0625,
                    0.125, 0.25, 0.125,
                    0.0625, 0.125, 0.0625
                };

                const float SharppenKernel[9] = {
                    0, 1, 0,
                    1, -4, 1,
                    0, 1, 0
                };

                const float SobelKernelX[9] =
                {
                    -1, 0,  1,
                    -2, 0,  2,
                    -1, 0,  1
                };

                const float SobelKernelY[9] =
                {
                    1,  2,  1,
                    0,  0,  0,
                    -1, -2, -1
                };

                float sobelx = ApplyKernel3x3(_MainTex, IN.uv, _PixelOffset, _MainTex_TexelSize.xy, SobelKernelX);
                float sobely = ApplyKernel3x3(_MainTex, IN.uv, _PixelOffset, _MainTex_TexelSize.xy, SobelKernelY);

                float sobel = sqrt(sobelx*sobelx + sobely*sobely);
                float4 tex = tex2D(_MainTex,IN.uv);

                return lerp (tex,float4(1,0,0,1),saturate(pow(sobel,7)*50));

                //return tex2D(_MainTex, IN.uv) + ApplyKernel3x3(_MainTex, IN.uv, _PixelOffset, _MainTex_TexelSize.xy, SharppenKernel);
            }
            
            ENDHLSL
        }
    }
}
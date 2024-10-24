using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FilterSetting : MonoBehaviour
{
    

    public enum FilterType
    {
        Gaussian,
        Laplacian
    }

    public enum FilterSize
    {
        F3x3=1,
        F4x4=2,
        F5x5=3
    }

    [SerializeField] private Material material;
    [SerializeField] private FilterType filterType;
    [SerializeField] private FilterSize filterSize;

    private float[] GenerateKernel()
    {
        float[][] kernel3x3 = new float[][]
        {
            new float[] {
                0.0625f, 0.125f, 0.0625f,
                    0.125f, 0.25f, 0.125f,
                    0.0625f, 0.125f, 0.0625f},

            new float[] {

            }
        };

        return kernel3x3[(int)filterType];
    }

    private void UpdateFilter()
    {
        if (material == null) return;

        material.SetInt("_MainTex", (int)filterSize);
    }

    private void OnValidate()
    {
        
    }

    private void Awake()
    {
        
    }
}

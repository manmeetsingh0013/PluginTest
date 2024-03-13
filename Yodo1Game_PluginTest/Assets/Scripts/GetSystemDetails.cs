using System.Runtime.InteropServices;
using UnityEngine;
using TMPro;
using System;

#if UNITY_IOS
public class StatsTrackingPlugin
{
    [DllImport("__Internal")] private static extern void startTracking();

    [DllImport("__Internal")] private static extern IntPtr stopTracking();


    public void StartTracking() => startTracking();
    public IntPtr StopTracking() => stopTracking();
}

public class GetSystemDetails : MonoBehaviour
{
    public TMP_Text textField;
    StatsTrackingPlugin plugin;

    private void Start()
    {
        plugin = new StatsTrackingPlugin();
    }

    public void StartTracking()
    {
        textField.text = "Tracking Started";
        plugin.StartTracking();
    }

    public void StopTracking()
    {
        IntPtr arrayPtr = plugin.StopTracking();

        double[] value = new double[3];
        Marshal.Copy(arrayPtr, value, 0, 3);

        
        textField.text = " CPU: " + value[0] + " \nRAM: " + value[1] + " \nGPU: " + value[2];

    }
}
#endif
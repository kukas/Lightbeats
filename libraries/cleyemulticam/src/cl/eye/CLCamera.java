//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// This file is part of CL-EyeMulticam SDK
//
// Java JNI CLEyeMulticam wrapper
//
// It allows the use of multiple CL-Eye cameras in your own Java applications
//
// For updates and file downloads go to: http://codelaboratories.com/research/view/cl-eye-muticamera-sdk
//
// Copyright 2008-2010 (c) Code Laboratories, Inc. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
package cl.eye;
import processing.core.*;

public class CLCamera
{
    // camera color mode
    public static int CLEYE_GRAYSCALE		= 0;
    public static int CLEYE_COLOR		= 1;

    // camera resolution
    public static int CLEYE_QVGA		= 0;	// Allowed frame rates: 15, 30, 60, 75, 100, 125
    public static int CLEYE_VGA			= 1;	// Allowed frame rates: 15, 30, 40, 50, 60, 75

    // camera sensor parameters
    public static int CLEYE_AUTO_GAIN 		= 0;  	// [0, 1]
    public static int CLEYE_GAIN		= 1;	// [0, 79]
    public static int CLEYE_AUTO_EXPOSURE	= 2;    // [0, 1]
    public static int CLEYE_EXPOSURE		= 3;    // [0, 511]
    public static int CLEYE_AUTO_WHITEBALANCE	= 4;	// [0, 1]
    public static int CLEYE_WHITEBALANCE_RED	= 5;	// [0, 255]
    public static int CLEYE_WHITEBALANCE_GREEN	= 6;   	// [0, 255]
    public static int CLEYE_WHITEBALANCE_BLUE	= 7;    // [0, 255]
    // camera linear transform parameters
    public static int CLEYE_HFLIP		= 8;    // [0, 1]
    public static int CLEYE_VFLIP		= 9;    // [0, 1]
    public static int CLEYE_HKEYSTONE		= 10;   // [-500, 500]
    public static int CLEYE_VKEYSTONE		= 11;   // [-500, 500]
    public static int CLEYE_XOFFSET		= 12;   // [-500, 500]
    public static int CLEYE_YOFFSET		= 13;   // [-500, 500]
    public static int CLEYE_ROTATION		= 14;   // [-500, 500]
    public static int CLEYE_ZOOM		= 15;   // [-500, 500]
    // camera non-linear transform parameters
    public static int CLEYE_LENSCORRECTION1	= 16;	// [-500, 500]
    public static int CLEYE_LENSCORRECTION2	= 17;	// [-500, 500]
    public static int CLEYE_LENSCORRECTION3	= 18;	// [-500, 500]
    public static int CLEYE_LENSBRIGHTNESS	= 19;	// [-500, 500]

    private PApplet parent;

    public static boolean IsLibraryLoaded()
    {
        return false;
    }
    public static void loadLibrary(String libraryPath)
    {
        return;
    }
    public static int cameraCount()
    {
        return 0;
    }
    public static String cameraUUID(int index)
    {
        return "0000";
    }
    // public methods
    public CLCamera(PApplet parent)
    {
        this.parent = parent;
    }
    public void dispose()
    {
        return;
    }
    public boolean createCamera(int cameraIndex, int mode, int resolution, int framerate)
    {
        return false;
    }
    public boolean destroyCamera()
    {
        return false;
    }
    public boolean startCamera()
    {
        return false;
    }
    public boolean stopCamera()
    {
        return false;
    }
    public boolean getCameraFrame(int[] imgData, int waitTimeout)
    {
        return false;
    }
    public boolean setCameraParam(int param, int val)
    {
        return false;
    }
    public int getCameraParam(int param)
    {
        return 0;
    }
}

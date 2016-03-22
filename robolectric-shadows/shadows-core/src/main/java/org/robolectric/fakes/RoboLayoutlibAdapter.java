package org.robolectric.fakes;

import org.robolectric.util.ReflectionHelpers;

/**
 * Serves as an adapter to the Layoutlib library
 */
public class RoboLayoutlibAdapter {

  public static void init() {
    setFontLocation("/system/etc/");
  }

  private static void setFontLocation(String fontLocation){
    Class<?> aClass;
    try {
      aClass = Class.forName("android.graphics.FontFamily_Delegate");
    } catch (ClassNotFoundException e) {
      throw new RuntimeException(e);
    }
    ReflectionHelpers.setStaticField(aClass, "sFontLocation", fontLocation);
  }

}

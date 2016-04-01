package org.robolectric.fakes;

import android.graphics.FontFamily_Delegate;

/**
 * Serves as an adapter to the Layoutlib library
 */
public class RoboLayoutlibAdapter {

  public static void init() {
    setFontLocation("/tmp/fonts/");
  }

  private static void setFontLocation(String fontLocation) {
    FontFamily_Delegate.setFontLocation(fontLocation);
  }

}

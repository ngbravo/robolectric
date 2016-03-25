package org.robolectric.fakes;

import android.graphics.FontFamily_Delegate;

/**
 * Serves as an adapter to the Layoutlib library
 */
public class RoboLayoutlibAdapter {

  public static void init() {
    FontFamily_Delegate.setFontLocation("/tmp/fonts/");
  }

}

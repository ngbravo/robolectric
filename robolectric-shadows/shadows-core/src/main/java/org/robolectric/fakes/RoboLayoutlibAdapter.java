package org.robolectric.fakes;

import android.graphics.FontFamily_Delegate;

/**
 * Serves as an adapter to the Layoutlib library
 */
public class RoboLayoutlibAdapter {

  public static void init(String fontsDir) {
    setFontLocation(fontsDir);
  }

  private static void setFontLocation(String fontLocation) {
    // Todo: this should be fixed in {@link LocalDependencyResolver#fileToUrl} by not returning a URL for a directory
    FontFamily_Delegate.setFontLocation(fontLocation.split("file:")[1]);
  }

}

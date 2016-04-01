package org.robolectric.shadows;

import android.graphics.FontFamily_Delegate;
import android.os.FileUtils;

import org.robolectric.annotation.Implementation;
import org.robolectric.annotation.Implements;
import org.robolectric.util.ReflectionHelpers;

import java.awt.Font;
import java.io.File;
import java.nio.file.Paths;

import static org.robolectric.internal.Shadow.directlyOn;

/**
 * Shadow for {@link android.graphics.FontFamily_Delegate}.
 */
@Implements(FontFamily_Delegate.class)
public class ShadowFontFamily_Delegate {

  public static String getFontLocation() {
    return ReflectionHelpers.getStaticField(FontFamily_Delegate.class, "sFontLocation");
  }

  @Implementation
  public static Font loadFont(String path) {
    // Copy font file to font location required by layoutlib
    if(!path.startsWith("/system/fonts/")) {
      String fileName = Paths.get(path).getFileName().toString();
      FileUtils.copyFile(new File(path), new File(getFontLocation() + fileName));

      // Return result of call to original method with a fake system path
      path = "/system/fonts/" + fileName;
    }
    return directlyOn(FontFamily_Delegate.class, "loadFont",
        new ReflectionHelpers.ClassParameter<>(String.class, path));
  }

  }
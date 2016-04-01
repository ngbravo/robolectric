package org.robolectric.shadows;

import android.content.res.AssetManager;
import android.graphics.FontFamily;

import org.robolectric.RuntimeEnvironment;
import org.robolectric.Shadows;
import org.robolectric.annotation.Implementation;
import org.robolectric.annotation.Implements;
import org.robolectric.annotation.RealObject;
import org.robolectric.manifest.AndroidManifest;

/**
 * Shadow for {@link android.graphics.FontFamily}.
 */
@Implements(FontFamily.class)
public class ShadowFontFamily {

  @RealObject
  FontFamily realFontFamily;

  @Implementation
  public boolean addFontFromAsset(AssetManager mgr, String path) {
    AndroidManifest appManifest = Shadows.shadowOf(RuntimeEnvironment.application).getAppManifest();
    String fontPath = appManifest.getAssetsDirectory().join(path).toString();

    return realFontFamily.addFont(fontPath);
  }

}
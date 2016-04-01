package org.robolectric.test;

import android.os.FileUtils;

import org.junit.rules.ExternalResource;
import org.robolectric.manifest.AndroidManifest;
import org.robolectric.res.FileFsFile;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * The TemporaryAsset Rule allows creation of assets based on an ApplicationManifest.
 *
 * <pre>
 * public static class HasTempFolder {
 *   &#064;Rule
 *  public TemporaryAsset temporaryAsset = new TemporaryAsset();

 *
 *   &#064;Test
 *   public void testUsingTempFolder() throws IOException {
 *     AndroidManifest appManifest = shadowOf(RuntimeEnvironment.application).getAppManifest();
 *     fontFile = temporaryAsset.createFile(appManifest, &quot;myFont.ttf&quot;, &quot;myFontData&quot;);
 *     // ...
 *   }
 * }
 * </pre>
 */
public class TemporaryAsset extends ExternalResource {
  List<File> assetsToDelete = new ArrayList<>();

  @Override protected void after() {
    for (File file : assetsToDelete) {
      file.delete();
    }
  }

  public File createClonedFontFile(AndroidManifest manifest, String fileName, String fontPath) throws Exception {
    File assetBase = ((FileFsFile) manifest.getAssetsDirectory()).getFile();
    File file = new File(assetBase, fileName);
    file.getParentFile().mkdirs();
    File toCloneFile = new File(fontPath);
    FileUtils.copyFile(toCloneFile, file);

    assetsToDelete.add(file);
    return file;
  }
}

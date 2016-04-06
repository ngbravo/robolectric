package org.robolectric.fakes;

import android.graphics.FontFamily_Delegate;

import net.lingala.zip4j.core.ZipFile;
import net.lingala.zip4j.exception.ZipException;

import java.io.File;
import java.util.HashSet;

/**
 * Serves as an adapter to the Layoutlib library
 */
public class RoboLayoutlibAdapter {

  private static HashSet<String> extractedFontZips = new HashSet<>();

  public static void init(String fontsDir) {
    setFontLocation(fontsDir);
  }

  private static void setFontLocation(String fontZipLocation) {

    //Remove "file:" and ".zip", and append "/"
    fontZipLocation = fontZipLocation.substring(5);
    String fontLocation = fontZipLocation.substring(0, fontZipLocation.length() - 4);
    fontLocation += "/";

    // Check if zip was extracted, and if not, well...extract it
    if (!extractedFontZips.contains(fontZipLocation)){
      // It may have been extracted beforehand
      File fontDir = new File(fontLocation);
      if (fontDir.exists() && fontDir.isDirectory() && fontDir.canRead() && fontDir.canWrite()) {
        extractedFontZips.add(fontZipLocation);
      }
      else {
        extractZip(fontZipLocation, fontLocation);
      }
    }

    FontFamily_Delegate.setFontLocation(fontLocation);
  }

  private static void extractZip (String zipLocation, String destination) {
    try {
      ZipFile zipFile = new ZipFile(zipLocation);
      zipFile.extractAll(destination);
      extractedFontZips.add(zipLocation);
    } catch (ZipException e) {
      e.printStackTrace();
      new File(destination).delete();
      extractedFontZips.remove(zipLocation);
    }
  }



}

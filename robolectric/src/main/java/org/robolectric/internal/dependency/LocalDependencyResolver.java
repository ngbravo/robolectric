package org.robolectric.internal.dependency;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;

public class LocalDependencyResolver implements DependencyResolver {
  private File offlineJarDir;

  public LocalDependencyResolver(File offlineJarDir) {
    super();
    this.offlineJarDir = offlineJarDir;
  }

  @Override
  public URL getLocalArtifactUrl(RoboDependency roboDependency) {
    StringBuilder filenameBuilder = new StringBuilder();
    filenameBuilder.append(roboDependency.getArtifactId())
        .append("-")
        .append(roboDependency.getVersion());

    if (roboDependency.getClassifier() != null) {
      filenameBuilder.append("-")
          .append(roboDependency.getClassifier());
    }

    if (roboDependency.getType().equals(RoboDependency.Type.dir.toString())) {
      filenameBuilder.append("/");
    }
    else {
      filenameBuilder.append(".")
          .append(roboDependency.getType());
    }

    return fileToUrl(validateFile(new File(offlineJarDir, filenameBuilder.toString())));
  }

  @Override
  public URL[] getLocalArtifactUrls(RoboDependency... dependencies) {
    URL[] urls = new URL[dependencies.length];

    for (int i=0; i<dependencies.length; i++) {
      urls[i] = getLocalArtifactUrl(dependencies[i]);
    }

    return urls;
  }

  /**
   * Validates {@code file} is an existing file that is readable.
   *
   * @param file the File to test
   * @return the provided file, if all validation passes
   * @throws IllegalArgumentException if validation fails
   */
  private static File validateFile(File file) throws IllegalArgumentException {
    if (!file.isFile() && !file.isDirectory()) {
      throw new IllegalArgumentException("Path is not a file or directory: " + file);
    }
    if (!file.canRead()) {
      throw new IllegalArgumentException("Unable to read: " + file);
    }
    return file;
  }

  /** Returns the given file as a {@link URL}. */
  private static URL fileToUrl(File file) {
    try {
      return file.toURI().toURL();
    } catch (MalformedURLException e) {
      throw new IllegalArgumentException(
          String.format("File \"%s\" cannot be represented as a URL: %s", file, e));
    }
  }
}

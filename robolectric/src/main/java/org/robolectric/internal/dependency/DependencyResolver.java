package org.robolectric.internal.dependency;

import java.net.URL;

public interface DependencyResolver {
  URL[] getLocalArtifactUrls(RoboDependency... dependencies);
  URL getLocalArtifactUrl(RoboDependency roboDependency);
}

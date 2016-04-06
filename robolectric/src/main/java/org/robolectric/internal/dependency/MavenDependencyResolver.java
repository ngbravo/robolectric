package org.robolectric.internal.dependency;

import org.apache.maven.artifact.ant.DependenciesTask;
import org.apache.maven.artifact.ant.RemoteRepository;
import org.apache.maven.model.Dependency;
import org.apache.tools.ant.Project;
import org.robolectric.RoboSettings;
import org.robolectric.util.Util;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Hashtable;

public class MavenDependencyResolver implements DependencyResolver {
  private final Project project = new Project();
  private final String repositoryUrl;
  private final String repositoryId;

  public MavenDependencyResolver() {
    this(RoboSettings.getMavenRepositoryUrl(), RoboSettings.getMavenRepositoryId());
  }

  public MavenDependencyResolver(String repositoryUrl, String repositoryId) {
    this.repositoryUrl = repositoryUrl;
    this.repositoryId = repositoryId;
  }

  /**
   * Get an array of local artifact URLs for the given dependencies. The order of the URLs is guaranteed to be the
   * same as the input order of dependencies, i.e., urls[i] is the local artifact URL for dependencies[i].
   */
  @Override
  public URL[] getLocalArtifactUrls(RoboDependency... dependencies) {
    DependenciesTask dependenciesTask = createDependenciesTask();
    configureMaven(dependenciesTask);

    RemoteRepository remoteRepository = new RemoteRepository();
    remoteRepository.setUrl(repositoryUrl);
    remoteRepository.setId(repositoryId);

    dependenciesTask.addConfiguredRemoteRepository(remoteRepository);
    dependenciesTask.setProject(project);

    for (RoboDependency roboDependency : dependencies) {
      Dependency mavenDependency = new org.apache.maven.model.Dependency();
      mavenDependency.setArtifactId(roboDependency.getArtifactId());
      mavenDependency.setGroupId(roboDependency.getGroupId());
      mavenDependency.setType(roboDependency.getType());
      mavenDependency.setVersion(roboDependency.getVersion());

      if (roboDependency.getClassifier() != null) {
        mavenDependency.setClassifier(roboDependency.getClassifier());
      }

      dependenciesTask.addDependency(mavenDependency);
    }
    dependenciesTask.execute();

    @SuppressWarnings("unchecked")
    Hashtable<String, String> artifacts = project.getProperties();
    URL[] urls = new URL[dependencies.length];
    for (int i = 0; i < urls.length; i++) {
      try {
        urls[i] = Util.url(artifacts.get(key(dependencies[i])));
      } catch (MalformedURLException e) {
        throw new RuntimeException(e);
      }
    }
    return urls;
  }

  @Override
  public URL getLocalArtifactUrl(RoboDependency roboDependency) {
    URL[] urls = getLocalArtifactUrls(roboDependency);
    if (urls.length > 0) {
      return urls[0];
    }
    return null;
  }

  private String key(RoboDependency roboDependency) {
    String key = roboDependency.getGroupId() + ":" + roboDependency.getArtifactId() + ":" + roboDependency.getType();
    if(roboDependency.getClassifier() != null) {
      key += ":" + roboDependency.getClassifier();
    }
    return key;
  }

  protected DependenciesTask createDependenciesTask() {
    return new DependenciesTask();
  }

  protected void configureMaven(DependenciesTask dependenciesTask) {
    // maybe you want to override this method and some settings?
  }
}

package org.robolectric.internal.dependency;

import org.apache.maven.artifact.ant.DependenciesTask;
import org.apache.maven.artifact.ant.RemoteRepository;
import org.apache.tools.ant.Project;
import org.junit.Before;
import org.junit.Test;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

import java.net.URL;
import java.util.List;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

public class MavenDependencyResolverTest {

  private static final String REPOSITORY_URL = "https://default-repo";

  private static final String REPOSITORY_ID = "remote";

  private DependenciesTask dependenciesTask;

  private Project project;

  @Before
  public void setUp() {
    dependenciesTask = spy(new DependenciesTask());
    doNothing().when(dependenciesTask).execute();
    doAnswer(new Answer() {
      @Override
      public Void answer(InvocationOnMock invocationOnMock) throws Throwable {
        invocationOnMock.callRealMethod();
        Object[] args = invocationOnMock.getArguments();
        project = (Project) args[0];
        project.setProperty("group1:artifact1:jar", "path1");
        project.setProperty("group2:artifact2:jar", "path2");
        project.setProperty("group3:artifact3:jar:classifier3", "path3");
        return null;
      }
    }).when(dependenciesTask).setProject(any(Project.class));
  }

  @Test
  public void getLocalArtifactUrl_shouldAddConfiguredRemoteRepository() {
    DependencyResolver dependencyResolver = createResolver();
    RoboDependency roboDependency = new RoboDependency("group1", "artifact1", "", null, RoboDependency.Type.jar);

    dependencyResolver.getLocalArtifactUrl(roboDependency);

    List<RemoteRepository> repositories = dependenciesTask.getRemoteRepositories();

    assertEquals(1, repositories.size());
    RemoteRepository remoteRepository = repositories.get(0);
    assertEquals(REPOSITORY_URL, remoteRepository.getUrl());
    assertEquals(REPOSITORY_ID, remoteRepository.getId());
  }

  @Test
  public void getLocalArtifactUrl_shouldAddDependencyToDependenciesTask() {
    DependencyResolver dependencyResolver = createResolver();
    RoboDependency roboDependencyJar = new RoboDependency("group1", "artifact1", "3", null, RoboDependency.Type.jar);

    dependencyResolver.getLocalArtifactUrl(roboDependencyJar);

    List<org.apache.maven.model.Dependency> dependencies = dependenciesTask.getDependencies();

    assertEquals(1, dependencies.size());
    org.apache.maven.model.Dependency dependency = dependencies.get(0);
    assertEquals("group1", dependency.getGroupId());
    assertEquals("artifact1", dependency.getArtifactId());
    assertEquals("3", dependency.getVersion());
    assertEquals("jar", dependency.getType());
    assertNull(dependency.getClassifier());
  }

  @Test
  public void getLocalArtifactUrl_shouldExecuteDependenciesTask() {
    DependencyResolver dependencyResolver = createResolver();
    RoboDependency roboDependency = new RoboDependency("group1", "artifact1", "", null, RoboDependency.Type.jar);

    dependencyResolver.getLocalArtifactUrl(roboDependency);

    verify(dependenciesTask).execute();
  }

  @Test
  public void getLocalArtifactUrl_shouldReturnCorrectUrlForArtifactKey() {
    DependencyResolver dependencyResolver = createResolver();
    RoboDependency roboDependency = new RoboDependency("group1", "artifact1", "", null, RoboDependency.Type.jar);

    URL url = dependencyResolver.getLocalArtifactUrl(roboDependency);

    assertEquals("file:/path1", url.toExternalForm());
  }

  @Test
  public void getLocalArtifactUrl_shouldReturnCorrectUrlForArtifactKeyWithClassifier() {
    DependencyResolver dependencyResolver = createResolver();
    RoboDependency roboDependency = new RoboDependency("group3", "artifact3", "", "classifier3", RoboDependency.Type.jar);

    URL url = dependencyResolver.getLocalArtifactUrl(roboDependency);

    assertEquals("file:/path3", url.toExternalForm());
  }

  @Test
  public void getLocalArtifactUrls_shouldReturnEmptyArrayIfNoDependencyJarProvided() {
    DependencyResolver dependencyResolver = createResolver();

    URL[] urls = dependencyResolver.getLocalArtifactUrls();

    assertEquals(0, urls.length);
  }

  @Test
  public void getLocalArtifactUrls_shouldReturnURLsForEachDependencyJar() {
    DependencyResolver dependencyResolver = createResolver();
    RoboDependency roboDependency1 = new RoboDependency("group1", "artifact1", "", null, RoboDependency.Type.jar);
    RoboDependency roboDependency2 = new RoboDependency("group2", "artifact2", "", null, RoboDependency.Type.jar);

    URL[] urls = dependencyResolver.getLocalArtifactUrls(roboDependency1, roboDependency2);

    assertEquals(2, urls.length);
    assertEquals("file:/path1", urls[0].toExternalForm());
    assertEquals("file:/path2", urls[1].toExternalForm());
  }

  @Test
  public void getLocalArtifactUrls_shouldAddEachDependencyToDependenciesTask() {
    DependencyResolver dependencyResolver = createResolver();
    RoboDependency roboDependency1 = new RoboDependency("group1", "artifact1", "", null, RoboDependency.Type.jar);
    RoboDependency roboDependency2 = new RoboDependency("group2", "artifact2", "", null, RoboDependency.Type.jar);

    dependencyResolver.getLocalArtifactUrls(roboDependency1, roboDependency2);

    verify(dependenciesTask, times(2)).addDependency(any(org.apache.maven.model.Dependency.class));
  }

  private DependencyResolver createResolver() {
    return new MavenDependencyResolver(REPOSITORY_URL, REPOSITORY_ID) {
      @Override
      protected DependenciesTask createDependenciesTask() {
        return dependenciesTask;
      }
    };
  }
}

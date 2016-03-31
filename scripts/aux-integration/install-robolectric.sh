#!/bin/bash
#
# Install Robolectric into the local Maven repository.
# Modified to patch in new android-all jars
#
set -e

# Read params.
# Param -p forces patches and installs the new jar
PATCH=0
for param in "$@"
do
  case "$param" in
    ("-p") PATCH=1 ;;
  esac
done

PARALLEL_BUILD_CONFIG="0.5C"
TEST_VERSIONS=("6.0.0_r1-robolectric-0")

#API_VERSIONS=(16, 17, 18, 19, 20, 21, 22, 23)
API_VERSIONS=(23)

PROJECT=$(cd $(dirname "$0")/../..; pwd)
M2_REPO=$(cd ~/.m2/repository/org/robolectric; pwd)
AUX_DIR=$(cd $(dirname "$0") ./; pwd)

if [ -z ${INCLUDE_SOURCE+x} ]; then SOURCE_ARG=""; else SOURCE_ARG="source:jar"; fi
if [ -z ${INCLUDE_JAVADOC+x} ]; then JAVADOC_ARG=""; else JAVADOC_ARG="javadoc:jar"; fi

build_robolectric() {
  echo "Building Robolectric..."
  cd "$PROJECT"
  mvn -T ${PARALLEL_BUILD_CONFIG} -D skipTests clean ${SOURCE_ARG} ${JAVADOC_ARG} install
}

build_shadows() {
  for api_version in "${API_VERSIONS[@]}"
  do
    echo "Building shadows for API $api_version..."
    cd "$PROJECT"/robolectric-shadows/shadows-core
    mvn -T ${PARALLEL_BUILD_CONFIG} -P android-${api_version} clean ${SOURCE_ARG} ${JAVADOC_ARG} install
  done
}

run_tests() {
  echo "Running Tests..."
  cd "$PROJECT"
  mvn -T ${PARALLEL_BUILD_CONFIG} test
}

#### START INTEGRATION DEV PURPOSE ####
remove_android_alls() {
  for test_version in "${TEST_VERSIONS[@]}"
  do
    echo "Removing original android-all-$test_version to force re-download..."
    cd $M2_REPO/android-all
    rm -r -f ${test_version}
  done
}

patch_android_alls() {
  for test_version in "${TEST_VERSIONS[@]}"
  do
    patch_android_all_for_version ${test_version}
  done
}

patch_android_all_for_version() {
  echo "Patching new android-all jars in for $1..."
  #Following https://docs.google.com/a/google.com/document/d/1jcw2qivGWBiYDpVJiFZwGdhGBLI7MgfF6rsgoJTxSZY/edit?usp=sharing

  # Extract original jar
  cd "$AUX_DIR"
  mkdir -p temp/patching-workspace/$1
  cd temp/patching-workspace/$1
  jar xvf $M2_REPO/android-all/$1/android-all-$1.jar

  # Move provided to patching workspace dir
  cd $AUX_DIR
  cp -r android-jars/provided/android-all-$1.jar temp/patching-workspace/$1/android-all-$1.jar

  # Replace relevant classes
  echo "Replacing and removing classes..."
  cd $AUX_DIR/temp/patching-workspace/$1

  # zip-d commands delete, jar -uvf commands replace

  remove_class_from_android-all $1 "com/google/android/maps/MapView.class"

  replace_class_from_android-all $1 "android/view/SurfaceView.class"
  replace_class_from_android-all $1 "android/view/SurfaceView\$1.class"
  replace_class_from_android-all $1 "android/view/SurfaceView\$2.class"
  replace_class_from_android-all $1 "android/view/SurfaceView\$3.class"
  replace_class_from_android-all $1 "android/view/SurfaceView\$4.class"
  replace_class_from_android-all $1 "android/view/SurfaceView\$MyWindow.class"

  replace_class_from_android-all $1 "android/webkit/WebView.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$1.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$FindListener.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$FindListenerDistributor.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$HitTestResult.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$PictureListener.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$PrivateAccess.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$VisualStateCallback.class"
  replace_class_from_android-all $1 "android/webkit/WebView\$WebViewTransport.class"

  replace_class_from_android-all $1 "android/view/accessibility/AccessibilityManager.class"
  replace_class_from_android-all $1 "android/view/accessibility/AccessibilityManager\$1.class"
  replace_class_from_android-all $1 "android/view/accessibility/AccessibilityManager\$AccessibilityStateChangeListener.class"
  replace_class_from_android-all $1 "android/view/accessibility/AccessibilityManager\$HighTextContrastChangeListener.class"
  replace_class_from_android-all $1 "android/view/accessibility/AccessibilityManager\$MyHandler.class"
  replace_class_from_android-all $1 "android/view/accessibility/AccessibilityManager\$TouchExplorationStateChangeListener.class"

  replace_class_from_android-all $1 "android/os/ServiceManager.class"

  replace_class_from_android-all $1 "android/util/LruCache.class"

  replace_class_from_android-all $1 "android/content/res/TypedArray.class"
  remove_class_from_android-all $1 "android/content/res/TypedArray_Delegate.class"

  replace_class_from_android-all $1 "android/util/Xml.class"
  replace_class_from_android-all $1 "android/util/Xml\$Encoding.class"
  replace_class_from_android-all $1 "android/util/Xml\$XmlSerializerFactory.class"
  remove_class_from_android-all $1 "android/util/Xml_Delegate.class"

  replace_class_from_android-all $1 "android/content/res/Resources\$Theme.class"
  remove_class_from_android-all $1 "android/content/res/Resources_Theme_Delegate.class"

  replace_class_from_android-all $1 "android/os/Handler.class"
  remove_class_from_android-all $1 "android/os/Handler_Delegate.class"

  replace_class_from_android-all $1 "android/view/View.class"
  remove_class_from_android-all $1 "android/view/View_Delegate.class"


  # Patch new jar in
  cd "$AUX_DIR"
  # mvn -q install:install-file -DgroupId='org.robolectric' -DartifactId='android-all' -Dversion=$1 -Dfile="temp/patching-workspace/$1/android-all-$1.jar" -Dpackaging=jar
  cp -r temp/patching-workspace/$1/android-all-$1.jar $M2_REPO/android-all/$1/android-all-$1.jar

  # Store the patched jar to cache
  cp -r temp/patching-workspace/$1/android-all-$1.jar $AUX_DIR/android-jars/patched/android-all-$1.jar

  # Delete working directory
  rm -r temp/patching-workspace/$1
}

replace_class_from_android-all () {
  jar -uvf android-all-$1.jar "${2}"
}

remove_class_from_android-all () {
  zip -d android-all-$1.jar "${2}"
}

patch_cached_android_alls() {
  echo "Using cached patches"
  for test_version in "${TEST_VERSIONS[@]}"
  do
    patch_cached_android_all $test_version
  done
}

patch_cached_android_all() {
  echo "Installing cached patch for $1"
  cp -r $AUX_DIR/android-jars/patched/android-all-$1.jar $M2_REPO/android-all/$1/android-all-$1.jar
}

#### END INTEGRATION DEV PURPOSE ####

if (($PATCH))
then
  remove_android_alls
  # First build will fail, but we need the original android-all from Maven
  build_robolectric || (patch_android_alls && build_robolectric)
else
  patch_cached_android_alls
  build_robolectric
fi
build_shadows
#run_tests

echo "Finished successfully!"
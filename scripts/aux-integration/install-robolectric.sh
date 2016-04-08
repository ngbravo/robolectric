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
TEST_VERSIONS=(
  "6.0.0_r1-robolectric-0"
  "5.1.1_r9-robolectric-1"
)

#API_VERSIONS=(16, 17, 18, 19, 20, 21, 22, 23)
API_VERSIONS=(22, 23)

PROJECT=$(cd $(dirname "$0")/../..; pwd)
M2_REPO=$(cd ~/.m2/repository/org/robolectric; pwd)
AUX_DIR=$(cd $(dirname "$0") ./; pwd)

if [ -z ${INCLUDE_SOURCE+x} ]; then SOURCE_ARG=""; else SOURCE_ARG="source:jar"; fi
if [ -z ${INCLUDE_JAVADOC+x} ]; then JAVADOC_ARG=""; else JAVADOC_ARG="javadoc:jar"; fi

build_robolectric() {
  echo "[INFO] Building Robolectric..."
  cd ${PROJECT}
  mvn -T ${PARALLEL_BUILD_CONFIG} -D skipTests clean ${SOURCE_ARG} ${JAVADOC_ARG} install
}

build_shadows() {
  for api_version in "${API_VERSIONS[@]}"
  do
    echo "[INFO] Building shadows for API $api_version..."
    cd "$PROJECT"/robolectric-shadows/shadows-core
    mvn -T ${PARALLEL_BUILD_CONFIG} -P android-${api_version} clean ${SOURCE_ARG} ${JAVADOC_ARG} install
  done
}

run_tests() {
  echo "[INFO] Running Tests..."
  cd "$PROJECT"
  mvn -T ${PARALLEL_BUILD_CONFIG} test
}

#### START INTEGRATION DEV PURPOSE ####
redownload_android_alls() {
  for test_version in "${TEST_VERSIONS[@]}"
  do
    echo "[INFO] Removing current android-all-$test_version..."
    rm -r -f $M2_REPO/android-all/${test_version}
  done

  cd ${PROJECT}
  for api in "${API_VERSIONS[@]}"
  do
    echo "[INFO] Redownloading original android-all-$test_version..."
    mvn dependency:resolve -P android-${api}
  done

}

patch_android_alls() {
  for test_version in "${TEST_VERSIONS[@]}"
  do
    patch_android_all_for_version ${test_version}
  done
}

patch_android_all_for_version() {
  echo "[INFO] Patching new android-all jars in for $1..."
  #Following https://docs.google.com/a/google.com/document/d/1jcw2qivGWBiYDpVJiFZwGdhGBLI7MgfF6rsgoJTxSZY/edit?usp=sharing

  # Extract original jar
  cd "$AUX_DIR"
  echo "[INFO] Extracting original $1..."
  mkdir -p temp/patching-workspace/$1
  cd temp/patching-workspace/$1
  jar xvf $M2_REPO/android-all/$1/android-all-$1.jar >/dev/null

  # Move provided to patching workspace dir
  cd $AUX_DIR
  cp -r android-jars/provided/android-all-$1.jar temp/patching-workspace/$1/android-all-$1.jar

  replace_and_remove_classes $1

  # Patch new jar in
  cd "$AUX_DIR"
  # mvn -q install:install-file -DgroupId='org.robolectric' -DartifactId='android-all' -Dversion=$1 -Dfile="temp/patching-workspace/$1/android-all-$1.jar" -Dpackaging=jar
  cp -r temp/patching-workspace/$1/android-all-$1.jar $M2_REPO/android-all/$1/android-all-$1.jar

  # Store the patched jar to cache
  cp -r temp/patching-workspace/$1/android-all-$1.jar $AUX_DIR/android-jars/patched/android-all-$1.jar

  # Delete working directory
  rm -r temp/patching-workspace/$1
}

replace_and_remove_classes () {
  # Replace relevant classes
  echo "[INFO] Replacing and removing classes..."
  cd $AUX_DIR/temp/patching-workspace/$1

  # zip-d commands delete, jar -uvf commands replace

  remove_class_from_android-all $1 "com/google/android/maps/MapView"
  replace_class_from_android-all $1 "android/view/SurfaceView"
  replace_class_from_android-all $1 "android/webkit/WebView"
  replace_class_from_android-all $1 "android/view/accessibility/AccessibilityManager"
  replace_class_from_android-all $1 "android/os/ServiceManager"
  replace_class_from_android-all $1 "android/util/LruCache"

  replace_class_from_android-all $1 "android/content/res/TypedArray"
  remove_class_from_android-all $1 "android/content/res/TypedArray_Delegate"

  replace_class_from_android-all $1 "android/util/Xml"
  remove_class_from_android-all $1 "android/util/Xml_Delegate"

  replace_class_from_android-all $1 "android/content/res/Resources\$Theme"
  remove_class_from_android-all $1 "android/content/res/Resources_Theme_Delegate"

  replace_class_from_android-all $1 "android/os/Handler"
  remove_class_from_android-all $1 "android/os/Handler_Delegate"

  replace_class_from_android-all $1 "android/view/View"
  remove_class_from_android-all $1 "android/view/View_Delegate"
}

replace_class_from_android-all () {
  # We replace the original class and all its subclasses
  jar -uvf android-all-$1.jar "${2}.class" || true

  for subclass in ${AUX_DIR}/temp/patching-workspace/${1}/${2}\$*.class
  do
    jar -uvf android-all-$1.jar "${subclass}" || true
  done
}

remove_class_from_android-all () {
  zip -d android-all-$1.jar "${2}.class" || true
}

patch_cached_android_alls() {
  echo "[INFO] Using cached patches"
  for test_version in "${TEST_VERSIONS[@]}"
  do
    patch_cached_android_all $test_version
  done
}

patch_cached_android_all() {
  echo "[INFO] Installing cached patch for $1"
  cp -r $AUX_DIR/android-jars/patched/android-all-$1.jar $M2_REPO/android-all/$1/android-all-$1.jar
}

#### END INTEGRATION DEV PURPOSE ####

if (($PATCH))
then
  redownload_android_alls
  patch_android_alls
  build_robolectric
else
  patch_cached_android_alls
  build_robolectric
fi
build_shadows
#run_tests

echo "[INFO] Finished successfully!"
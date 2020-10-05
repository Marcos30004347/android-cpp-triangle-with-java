############################
# Set loca variables
############################

SDK=$ANDROID_SDK
BUILD_TOOLS="${SDK}/build-tools/30.0.2"
PLATFORM="${SDK}/platforms/android-22"

APP_NAME="testelib"
APK_PACKAGE="com.example.$APP_NAME"
APPLICATION_NAME="app_name"
ANDROID_ABI="arm64-v8a"

# Debug purposes
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN=`tput setaf 2`



#######################################################
# Set up
#######################################################

mkdir -p build/gen build/obj build/apk build/lib build/manifest build/java
cp -a android/res/. build/res
build -p build/res/values






#######################################################
# Compile native lib
#######################################################
printf "${GREEN}Building native lib!\n${NC}"

# cmake will create:
#     - build/java/LoadLibraries.java
#     - build/manifest/AndroidManifest.xml
# and compile our cpp code.

cd build/lib

cmake -DANDROID_ABI=$ANDROID_ABI \
      -DAPPLICATION_NAME=$APPLICATION_NAME \
      -DAPK_PACKAGE=$APK_PACKAGE \
      -DAPP_NAME=$APP_NAME \
      -DCMAKE_TOOLCHAIN_FILE=../../cmake/android.cmake \
       ../..

make

cd ..

# All native libs need to be inside lib/<android-arch-abi> folder of the APK
mkdir -p ./apk/lib/$ANDROID_ABI

cp ./lib/lib$APP_NAME.so ./apk/lib/$ANDROID_ABI

cd ..






#######################################################
# Compile java code
#######################################################
printf "${GREEN}Compiling java!\n${NC}"

# Create R.java file, this will be in build/gen/com/example/$APP_NAME because of the app_package
${BUILD_TOOLS}/aapt package -f -m -J build/gen/ -S build/res \
-M build/manifest/AndroidManifest.xml -I "${PLATFORM}/android.jar"

# Compile LoadLibraries.java code into byte code
javac -source 1.7 -target 1.7 -bootclasspath "${JAVA_HOME}/jre/lib/rt.jar" \
      -classpath "${PLATFORM}/android.jar" -d build/obj \
      build/gen/com/example/$APP_NAME/R.java build/java/LoadLibraries.java


# Translate byte code into Dalvik required by android
${BUILD_TOOLS}/dx --dex --output=build/apk/classes.dex build/obj/






#######################################################
# Create APK
#######################################################
printf "${GREEN}Building APK!\n${NC}"

# Create unsigned APK
${BUILD_TOOLS}/aapt package -f -M build/manifest/AndroidManifest.xml -S build/res/ \
      -I "${PLATFORM}/android.jar" \
      -F build/$APP_NAME.unsigned.apk build/apk/

# Align unsigned APK
${BUILD_TOOLS}/zipalign -f -p 4 \
      build/$APP_NAME.unsigned.apk build/$APP_NAME.aligned.apk

rm build/$APP_NAME.unsigned.apk

# Sign APK
${BUILD_TOOLS}/apksigner sign --ks build/keys/keystore.jks \
      --ks-key-alias androidkey --ks-pass pass:android \
      --key-pass pass:android --out build/$APP_NAME.apk \
      build/$APP_NAME.aligned.apk

rm -rf build/$APP_NAME.aligned.apk


printf "${GREEN}Successfully create $APP_NAME.apk!\n"
printf "${NC}\n"
printf "${GREEN}APK contents are:\n"
printf "${NC}\n"

# List APK contents
jar tf build/$APP_NAME.apk
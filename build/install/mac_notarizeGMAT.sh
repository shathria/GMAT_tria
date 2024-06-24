#!/bin/zsh

# mac_notarizeGMAT.sh -v <versionName> -u <notaryProfile> [-p <packageDirPath>]
#     versionName: GMAT version, e.g. R2022a
#     notaryProfile: notarytool profile name stored in keychain (see below)
#     packageDir: (Optional) Absolute path to GMAT folder to be distributed.
#                 If absent, assumes GMAT folder is "GMAT-<versionName>-Darwin-x64"
#                 and is located in the root of the GMAT repository (CMake default).
#
# This script packages, signs, and notarizes GMAT for distribution via a .dmg file.
# It has the following prerequisites:
#  - The developer must have run `make install` to create a standalone version of GMAT.
#    The standalone version of GMAT has the folder name format: "GMAT-<version>-Darwin-x64",
#    which is the default folder name for the GMAT CMake build system.
#  - The developer must have stored their app-specific password (from their Apple developer account)
#    to their macOS account keychain using the following command:
#    > xcrun notarytool store-credentials --apple-id "myappleid@whatever.com" --team-id "82A95CK2HC"
#      This will interactively prompt for the following inputs:
#        Desired Profile Name: recommend using the Apple ID
#        App-Specific Password: get this from the Apple developer account
#      NOTE: This must be done only ONCE on each macOS account

# Parse inputs
usage() { echo "Usage: mac_notarizeGMAT -v <versionName> -u <notaryProfile> [-p <packageDirPath>]" 1>&2; exit 1; }
while getopts "v:u:p:" o; do
  case "${o}" in
    v) version=${OPTARG};;
    u) notaryProfile=${OPTARG};;
    p) packageDir=${OPTARG};;
    *) usage;;
  esac
done
shift $((OPTIND-1))

# Enforce required opts
if [ -z "$version" ] || [ -z "$notaryProfile" ]; then
	usage
fi

# Go to GMAT repository root directory
# Assumes this script resides in <GMAT>/build/install
scriptDir="$(dirname "$0")"
gmatDir="$scriptDir/../.."
cd $gmatDir
gmatDir="$(pwd)"
scriptDir="$gmatDir/build/install"

# Determine which GMAT folder to distribute
if [ -z $packageDir ]
then
  package="$gmatDir/GMAT-$version-Darwin-x64" # Use default folder
else
  package="${packageDir%/}" # Use specified folder without trailing slash
fi

# Make sure it exists
if [ ! -d "$package" ]
then
	echo "GMAT directory $package does not exist."
	exit 1
else
	echo "Packaging GMAT directory: $package"
	packageParentDir="$(dirname "$package")"
fi

# Determine paths to GMAT packages and folders
appName="GMAT-${version}_Beta.app"          # GMAT app name
container="${package}-signed.dmg"  # Name of distributable container that will hold GMAT
volumeName="$packageParentDir/GMAT $version" # Volume name when container is mounted
rootDir="GMAT $version"          # Name of distributed root GMAT directory
dstDir="$volumeName/$rootDir"    # Destination directory structure when copying GMAT
binDir="$dstDir/bin"             # GMAT bin directory
appDir="$binDir/$appName"        # GMAT.app directory

# NASA's Apple signing identity
# Note that the team ID is public information and can be safely kept here
identity="Developer ID Application: NASA (82A95CK2HC)"

# GMAT entitlements file
entitlementsFile="$scriptDir/mac_GMAT.entitlements"

# Cleanup and create top-level directory that will be the root of the GMAT package
rm -Rf "$dstDir"
rm -Rf "$volumeName"
if [ $? -ne 0 ]
then
	# On macOS sometimes rm -Rf does not succeed
	echo "Could not delete $volumeName, please try again"
	exit 1
fi
rm -f "$container"
mkdir -p "$dstDir"
cp -a "$package/" "$dstDir"

# codesign doesn't like dots in folder names, so remove them from osgPlugins-x.x.x
# The RunGMAT script accounts for this by setting OSG_LIBRARY_PATH
# Ref: https://stackoverflow.com/questions/37737829/codesign-osx-app-bundle-with-periods-in-macos-directory-names
mv "$appDir/Contents/Frameworks/osgPlugins-3.6.5" "$appDir/Contents/Frameworks/osgPlugins"

# Get GMAT bundle ID
bundleID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$appDir/Contents/Info.plist")

# Sign all .dylib with secure timestamp (for GMAT, plugins, dependencies)
# Look inside binDir to catch plugins external to the app bundle (e.g. libCInterface)
echo "**** Signing GMAT shared libraries ****"
find "$binDir/" -name "*.dylib" -type f -print0 |
while IFS= read -r -d '' dylib; do
  codesign -f --timestamp -o runtime --sign "$identity" "$dylib"
done

# Sign all .so with secure timestamp (for GMAT Python API, OpenFramesInterface file loaders)
find "$appDir/" -name "*.so" -print0 |
while IFS= read -r -d '' so; do
  codesign -f --timestamp -o runtime --sign "$identity" "$so"
done

# Sign all Python scripts with secure timestamp (for GMAT Python API)
echo "**** Signing GMAT Python API ****"
find "$appDir/" -name "*.py" -print0 |
while IFS= read -r -d '' py; do
  codesign -f --timestamp -o runtime --sign "$identity" "$py"
done

# Sign all Java files with secure timestamp (for GMAT Java API)
echo "**** Signing GMAT Java API ****"
find "$appDir/" \( -name "*.jnilib" -or -name "*.jar" \) -print0 |
while IFS= read -r -d '' javaFile; do
  codesign -f --timestamp -o runtime --sign "$identity" "$javaFile"
done

# Sign GMAT executable with entitlements
#codesign -f --entitlements "$entitlementsFile" --timestamp -o runtime -i "$bundleID" --sign "$identity" "$appDir/Contents/MacOS/RunGMAT"
codesign -f --entitlements "$entitlementsFile" --timestamp -o runtime -i "$bundleID" --sign "$identity" "$appDir/Contents/MacOS/GMAT-$version"

# Sign GMAT application bundle with entitlements
codesign -f --entitlements "$entitlementsFile" --verbose=4 --display --timestamp -o runtime -i "$bundleID" --sign "$identity" "$appDir"

# Sign GMAT console executable with entitlements
codesign -f --entitlements "$entitlementsFile" --timestamp -o runtime --sign "$identity" "$binDir/GmatConsole-$version"

# Create container for GMAT
hdiutil create -srcfolder "$volumeName" -o "$container"
codesign -f --verbose=4 --sign "$identity" --timestamp -i "$bundleID" "$container"

#echo "Exiting before notarization"
#exit 0;

# Temp workaround to enable notarization on macOS 10.15 Catalina
# macOS 10.15 uses XCode 12, which does not include notarytool. On that system notarytool must be manually placed in a location
# accessible by the PATH environment variable. However, in this situation xcrun will not allow notarytool to execute, and instead
# it must be executed directly. So we just execute notarytool directly on all systems.
notarytoolcmd=$(xcrun -find notarytool)
notarytoolcmd_status=$?
if [ $notarytoolcmd_status -ne 0 ]
then
	echo "\n*** ERROR: notarytool command-line tool not found. Please install XCode 13+ or put notarytool somewhere in your \$PATH. ***\n"
	exit $notarytoolcmd_status
fi

# Submit GMAT container to notarization service and wait for result
echo "Submitting to notarization service - this may take a while ..."
$notarytoolcmd submit "$container" \
               --keychain-profile "$notaryProfile" \
               --wait
notarytool_status=$?
if [ $notarytool_status -ne 0 ]
then
  echo "\n*** ERROR: Notarization failed with status = $notarytool_status. Please check notarytool log. ***\n"
  exit $notarytool_status
fi

# Staple notary ticket to container
xcrun stapler staple "$container"
stapler_status=$?
if [ $stapler_status -ne 0 ]
then
  echo "\n*** ERROR: Stapling notary ticket failed with status = $stapler_status. ***\n"
  exit $stapler_status
fi

echo "\n*** Success! GMAT for macOS can be distributed via $container. ***\n"
exit 0

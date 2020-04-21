#!/bin/sh

#  distribution_script.sh
#  Teamo
#
#  Created by Andrei Konoplev on 14.04.2020.
#  Copyright © 2020 Виктор Заикин. All rights reserved.

# cd folder with .git
# bash Teamo/Teamo/Recources/Scripts/distribution_script.sh
#


conf_file="$(pwd)/Conf/teamo.config.sh"
utilits_file="$(pwd)/utilits/deploy_logger.sh"

source $conf_file
source $utilits_file

log "👷🏻‍♂️ Will deploy Teamo for testers 👷🏻‍♂️"
log_seporator
log_param "Project target" "$XC_TARGET_NAME"
log_param "Project scheme" "$XC_SCHEME"
log_param "Project configuration" "$XC_CONFIGURATION"
log_param "Git branch" "$CURRENT_GIT_BRANCH"
log_param "Deploy marketing version" "$DEPLOY_MARKETING_VERSION"
log_param "Deploy internal build number" "$DEPLOY_BUILD_NUMBER"
log_param "Bundle short version" "$BUNDLE_SHOT_VERSION"
log_param "Bundle version" "$BUNDLE_VERSION"

#
# Clean derived data
#
log_did_start "cleaning derived data"
mkdir DerivedDataOutput 2> /dev/null || true
log_did_finish_or_exit_if_failed "clean derived data"

#
#Clean
#

log_did_start "cleaning project"
xcodebuild \
-workspace $XC_WORKSPACE \
-scheme $XC_SCHEME \
-configuration $XC_CONFIGURATION \
clean
log_did_finish_or_exit_if_failed "clean project"

#
#Archive
#

log_did_start "archiving project will start"
xcodebuild \
-workspace $XC_WORKSPACE \
-scheme $XC_SCHEME \
-configuration $XC_CONFIGURATION \
-derivedDataPath DerivedDataOutput \
-archivePath ExportFiles/ArchiveOutput \
archive
log_did_finish_or_exit_if_failed "archiving project did finish"

load_did_finish_or_exit_if_failed "export ipa for AdHoc distribution"
xcodebuild -exportArchive -exportOptionsPlist Teamo/Teamo/Recources/Scripts/Conf/teamo.adhoc.exportOptions.plist \
-archivePath ExportFiles/ArchiveOutput.xcarchive \
-exportPath ExportApplication/$XC_TARGET_NAME
log_did_finish_or_exit_if_failed "export ipa for adHoc distribution"

#
#Upload to Firebase Add Distribution
#

log_did_start "uploading"
/usr/local/bin/firebase appdistribution:distribute ExportApplication/$XC_TARGET_NAME/$XC_TARGET_NAME.ipa \
  # {identifier of your app in firebase console}  
  	--app 1:11003138102:ios:7a2693817324rfdew4543 \
  # {names of group yout tester distribute for } 
  	--groups teamo-ios-testers \
  # {token generate with Firebase CLI in your terminal} 
   --token 1//092Mm9D_qL8AYCgYIARAAGAkSNwF-L9IrNgG1FaHf1hceRVPz2SGBs3RGxdVeZb66A \
    --non-interactive 2>&1
log_did_finish_or_exit_if_failed "uploading"

log_did_start "uploading dSYMs to Crashlytics"
find "./ExportFiles/ArchiveOutput.xcarchive/dSYMs/" -name "*.dSYM" | xargs -I \{\} "Pods/Fabric/upload-symbols" \
 -a $CRASHLYTICS_API_KEY \
 -p ios \{\}

log_did_finish_or_exit_if_failed "upload dSYMs to Crashlytics"














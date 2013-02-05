#!/bin/bash
#
# This script launches Munki Manifest Selector.app with a few default
# options.
#
# The keys/arguments supported by Munki Manifest Selector.app are:
#	--targetVolume (required) Prepended to "/Library/Preferences/ManagedInstalls.plist"
#
# 	Flags:
#
#	--InstallAppleSoftwareUpdates
#	--SuppressAutoInstall
#	--SuppressLoginwindowInstall
#	--SuppressStopButtonOnInstall
#	--SuppressUserNotification
#	--SuppressUserNotification
#	--InstallRequiresLogout
#	--ShowRemovalDetail
#
#	Named Arguments:
#
#	--SoftwareRepoURL <url>
#	--SoftwareUpdateServerURL <url>
#	--DaysBetweenNotifications <interval> - This differs from Munki's values and must be one of "Hourly", "Daily", "Weekly" or "Monthly". This is for display purposes only and will be translated to a integer before the plist is written.
#


BASE_DIR=`dirname "${0}"`
$BASE_DIR/Munki\ Manifest\ Selector.app/Contents/MacOS/Munki\ Manifest\ Selector\
	--targetVolume "${DS_LAST_SELECTED_TARGET}"\
	--InstallAppleSoftwareUpdates\
	--DaysBetweenNotifications Daily\
	--ShowRemovalDetail

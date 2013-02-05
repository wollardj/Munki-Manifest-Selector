//
//  AppDelegate.h
//  Munki Manifest Selector
//
//  Created by Joseph M. Wollard on 1/20/13.
//  Copyright (c) 2013 Denison University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
    MMS_CLEAN_EXIT_CODE = 0,
    MMS_INCOMPLETE_PLIST_EXIT_CODE = 1,
    MMS_INVALID_PLIST_VALUE_EXIT_CODE = 2,
    MMS_MISSING_OR_INVALID_TARGET_VOLUME_EXIT_CODE = 3
} MMS_EXIT_CODE;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSAlertDelegate>
{
    NSString *targetVolume;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSPopUpButton *manifestPopupMenu;
@property (assign) IBOutlet NSPopover *popover;
@property (strong) NSString *selectedManifestName;
@property (strong) NSMutableDictionary *manifestDict;

@property BOOL enableMunkiBootstrapMode;

@property BOOL installAppleSoftwareUpdates;
@property BOOL suppressAutoinstall;
@property BOOL suppressUserNotification;
@property BOOL suppressLoginwindowInstall;
@property BOOL suppressStopButtonOnInstall;
@property BOOL installRequiresLogout;
@property BOOL showRemovalDetail;
@property (strong) NSString *daysBetweenNotifications;

- (IBAction)useSelectedManifest:(id)aSender;
- (IBAction)reloadManifests:(id)aSender;
- (IBAction)setSelectedManifest:(NSPopUpButton *)aSender;
- (IBAction)showAdvancedOptions:(NSButton *)aButton;

@end

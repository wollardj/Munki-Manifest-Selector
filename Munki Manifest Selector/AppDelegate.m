//
//  AppDelegate.m
//  Munki Manifest Selector
//
//  Created by Joseph M. Wollard on 1/20/13.
//  Copyright (c) 2013 Denison University. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize manifestPopupMenu,
            selectedManifestName,
            manifestDict,
            enableMunkiBootstrapMode;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setManifestDict: [NSMutableDictionary dictionary]];
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    
    // Hide all other applications.
    //[NSApp hideOtherApplications:self];
    [NSApp activateIgnoringOtherApps:YES];


    // set the default values
    [self setEnableMunkiBootstrapMode:NO];
    [manifestDict setObject:[self convertBool:NO] forKey:@"InstallAppleSoftwareUpdates"];
    [manifestDict setObject:[self convertBool:NO] forKey:@"SuppressAutoInstall"];
    [manifestDict setObject:[self convertBool:NO] forKey:@"SuppressLoginwindowInstall"];
    [manifestDict setObject:[self convertBool:NO] forKey:@"SuppressStopButtonOnInstall"];
    [manifestDict setObject:[self convertBool:NO] forKey:@"SuppressUserNotification"];
    [manifestDict setObject:[self convertBool:NO] forKey:@"SuppressUserNotification"];
    [manifestDict setObject:[self convertBool:NO] forKey:@"InstallRequiresLogout"];
    [manifestDict setObject:[self convertBool:NO] forKey:@"ShowRemovalDetail"];
    [manifestDict setObject:@"" forKey:@"SoftwareRepoURL"];
    [manifestDict setObject:@"" forKey:@"SoftwareUpdateServerURL"];
    [manifestDict setObject:@"Hourly" forKey:@"DaysBetweenNotifications"];

    
    // Attempt to populate the manifests.
    [self reloadManifests:nil];
    
    [self.manifestDict addObserver:self
                        forKeyPath:@"SuppressAutoInstall"
                           options:NSKeyValueObservingOptionOld
                           context:nil];
    [self.manifestDict addObserver:self
                        forKeyPath:@"SuppressLoginwindowInstall"
                           options:NSKeyValueObservingOptionOld
                           context:nil];

    
    // Loop over the provided arguments and set the manifestDict values accordingly.
    NSArray *manifestKeys = [manifestDict allKeys];
    for(int i = 1; i < [arguments count]; i++)
    {
        NSString *arg = [arguments objectAtIndex:i];
        NSString *cleanArg = [arg stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if ([manifestKeys containsObject:cleanArg])
        {
            if ([cleanArg isEqualToString:@"DaysBetweenNotifications"])
            {
                NSString *value = [arguments objectAtIndex:++i];
                if ([value isEqualToString:@"1"])
                    [manifestDict setObject:@"Daily" forKey:@"DaysBetweenNotifications"];
                else if ([value isEqualToString:@"7"])
                    [manifestDict setObject:@"Weekly" forKey:@"DaysBetweenNotifications"];
                else if ([value isEqualToString:@"30"])
                    [manifestDict setObject:@"Monthly" forKey:@"DaysBetweenNotifications"];
            }
            else if ([cleanArg isEqualToString:@"SoftwareRepoURL"])
                [manifestDict setObject:[arguments objectAtIndex:++i] forKey:@"SoftwareRepoURL"];
            else if ([cleanArg isEqualToString:@"SoftwareUpdateServerURL"])
                [manifestDict setObject:[arguments objectAtIndex:++i] forKey:@"SoftwareUpdateServerURL"];
            else
                [manifestDict setObject:[self convertBool:YES] forKey:cleanArg];
        }
        else if ([cleanArg isEqualToString:@"targetVolume"])
            targetVolume = [arguments objectAtIndex:++i];
        else if ([cleanArg isEqualToString:@"enableMunkiBootstrapMode"])
            [self setEnableMunkiBootstrapMode:YES];
        else
            NSLog(@"Discarding unrecognized argument '%@'", arg);
    }
    
    // Make sure targetVolume was one of the arguments and that the value of that argument is valid.
    BOOL isDir;
    if (targetVolume == nil
        || [[NSFileManager defaultManager] fileExistsAtPath:targetVolume isDirectory:&isDir] == NO
        || isDir == NO)
    {
        targetVolume = @"/";
        NSLog(@"Missing -targetVolume argument. Using default value '/'");
        // exit(MMS_MISSING_OR_INVALID_TARGET_VOLUME_EXIT_CODE);
    }
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber *value = [object valueForKeyPath:keyPath];
    
    if ([keyPath isEqualToString:@"SuppressAutoInstall"] && value == [self convertBool:YES])
        [manifestDict setObject:[self convertBool:NO] forKey:@"SuppressLoginwindowInstall"];
    
    else if ([keyPath isEqualToString:@"SuppressLoginwindowInstall"] && value == [self convertBool:YES])
        [manifestDict setObject:[self convertBool:NO] forKey:@"SuppressAutoInstall"];
}




- (IBAction)reloadManifests:(id)aSender
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *infoDict = [bundle infoDictionary];
    
    // Make sure the 'Manifests URL' key exists in the Info.plist file.
    if ([[infoDict allKeys] containsObject:@"Manifests URL"] == NO
        || [infoDict objectForKey:@"Manifests URL"] == nil)
    {
        [self runAlertWithTitle:@"Unable to read 'Manifests URL'"
                     andMessage:@"Check the value of 'Manifests URL' within Info.plist. The key doesn't appear to exist."
                  usingExitCode:MMS_INCOMPLETE_PLIST_EXIT_CODE];
        return;
    }
    
    NSURL *mURL = [NSURL URLWithString:[infoDict objectForKey:@"Manifests URL"]];
    NSDictionary *aDict = [NSDictionary dictionaryWithContentsOfURL:mURL];
    
    // Make sure the value of 'Manifests URL' is valid.
    if (aDict == nil || [[aDict allKeys] count] == 0)
    {
        [self runAlertWithTitle:@"Unable load Manifests URL."
                     andMessage:@"Check the value of 'Manifests URL' within Info.plist. The the value is either incorrect, or the plist it points to is invalid."
                  usingExitCode:MMS_INVALID_PLIST_VALUE_EXIT_CODE];
    }
    else {
        // Add a placeholder of '-' to the list and sort it alphabetically.
        NSMutableArray *manifests = [[aDict objectForKey:@"ManifestGroups"] mutableCopy];
        [manifests addObject:@"-"];
        NSArray *sortedManifests = [manifests sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [manifestPopupMenu removeAllItems];
        [manifestPopupMenu addItemsWithTitles:sortedManifests];
        [self setSelectedManifestName:nil];
    }
}




- (IBAction)setSelectedManifest:(NSPopUpButton *)aSender
{
    NSString *selectedTitle = [aSender titleOfSelectedItem];
    if ([selectedTitle isEqualToString:@"-"])
        [self setSelectedManifestName:nil];
    else
        [self setSelectedManifestName:selectedTitle];
}




- (IBAction)useSelectedManifest:(id)aSender
{
//    NSArray *manifestNameParts = [self.selectedManifestName componentsSeparatedByString:@"/"];
//    NSString *templateManifestName = [NSString stringWithFormat:@"__%@Template", [manifestNameParts lastObject]];
    NSString *templateManifestName = [NSString stringWithFormat:@"%@/generic", self.selectedManifestName];
    [manifestDict setObject:templateManifestName forKey:@"ClientIdentifier"];
    
    if ([[manifestDict objectForKey:@"DaysBetweenNotifications"] isEqualToString:@"Hourly"])
        [manifestDict setObject:[NSNumber numberWithInt:0] forKey:@"DaysBetweenNotifications"];
    else if ([[manifestDict objectForKey:@"DaysBetweenNotifications"] isEqualToString:@"Daily"])
        [manifestDict setObject:[NSNumber numberWithInt:1] forKey:@"DaysBetweenNotifications"];
    else if ([[manifestDict objectForKey:@"DaysBetweenNotifications"] isEqualToString:@"Weekly"])
        [manifestDict setObject:[NSNumber numberWithInt:7] forKey:@"DaysBetweenNotifications"];
    else if ([[manifestDict objectForKey:@"DaysBetweenNotifications"] isEqualToString:@"Monthly"])
        [manifestDict setObject:[NSNumber numberWithInt:30] forKey:@"DaysBetweenNotifications"];
    
    // Delete the SoftwareUpdateServerURL key if it hasn't been set.
    if ([[manifestDict objectForKey:@"SoftwareUpdateServerURL"] isEqualToString:@""])
        [manifestDict removeObjectForKey:@"SoftwareUpdateServerURL"];
    
    NSString *clientManifestPath = [targetVolume stringByAppendingPathComponent:@"/Library/Preferences/ManagedInstalls.plist"];
    
    // Write the manifest file to ManagedInstalls.plist on the target volume.
    [manifestDict writeToFile:clientManifestPath atomically:YES];
    
    // Enable bootstrap mode if specified.
    if ([self enableMunkiBootstrapMode] == YES)
    {
        [[NSFileManager defaultManager] createFileAtPath:[targetVolume stringByAppendingPathComponent:@"/Users/Shared/.com.googlecode.munki.checkandinstallatstartup"]
                                                contents:nil
                                              attributes:nil];
    }
    [NSApp terminate:self];
}




- (NSNumber *)convertBool:(BOOL)aBool
{
    return [NSNumber numberWithBool:aBool];
}




- (IBAction)showAdvancedOptions:(NSButton *)aButton
{
    [_popover setBehavior:NSPopoverBehaviorTransient];
    [_popover showRelativeToRect:[aButton bounds]
                         ofView:aButton
                  preferredEdge:NSMaxYEdge];
}




- (void)runAlertWithTitle:(NSString *)aTitle andMessage:(NSString *)aMessage usingExitCode:(MMS_EXIT_CODE)anExitCode
{
    NSAlert *alert = [NSAlert alertWithMessageText:aTitle
                                     defaultButton:@"Okay"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"%@", aMessage];
    [alert runModal];
    [self sendToSTDOUT:aMessage];
    exit(anExitCode);
}




- (void)sendToSTDOUT:(NSString *)aMessage
{
    printf("%s", [aMessage cStringUsingEncoding:[NSString defaultCStringEncoding]]);
}




- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)anApp
{
    if (self.selectedManifestName == nil)
        return NSTerminateCancel;
    return NSTerminateNow;
}
@end

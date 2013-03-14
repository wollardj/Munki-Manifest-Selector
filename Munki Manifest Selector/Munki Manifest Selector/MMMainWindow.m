//
//  MMMainWindow.m
//  Munki Manifest Selector
//
//  Created by Joseph M. Wollard on 3/14/13.
//  Copyright (c) 2013 Denison University. All rights reserved.
//

#import "MMMainWindow.h"

@implementation MMMainWindow



- (void)awakeFromNib
{
    // Make sure the window is able to popup in front of any other window.
    [self center];
//    [self setLevel:NSScreenSaverWindowLevel];
}




- (BOOL)canBecomeKeyWindow
{
    return YES;
}




- (BOOL)acceptsFirstResponder
{
    return YES;
}




- (BOOL)canBecomeMainWindow
{
    return YES;
}


- (BOOL)canBecomeVisibleWithoutLogin
{
    return YES;
}

@end

//
//  AppDelegate.m
//  VSCProxy
//
//  Originally Created by Tim Keating to register an apple event handler, and NSLog the output on 5/18/13.
//  Modified by Allan Lavell to open Sublime Text 2 at the correct line location on 31st 07/31/13.
//  Modified by Wallace Huang to open Visual Studio Code v0.5.0 July 10, 2015

#import "AppDelegate.h"

@implementation AppDelegate

//NSString *const APP_PATH = @"/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl";
//NSString *const LINE_FORMAT = @"%@:%d;
NSString *const APP_PATH = @"/Users/eugene/test.py";
NSString *const LINE_FORMAT = @"%d";

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:)
     forEventClass:'aevt' andEventID:'odoc'];
}

- (void)bringiTermInFront{
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
                                   @"tell application \"iTerm\" activate end tell"];
    
    returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    
    [self bringiTermInFront];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:APP_PATH];
    
    NSData *eventData = [event data];
    
    unsigned char *buffer = malloc(sizeof(UInt16));
    [eventData getBytes: buffer range:NSMakeRange(422, sizeof(UInt16))];
    UInt16 x = *(UInt16 *)buffer;
    if (x == ((UInt16)65534)) {
        x = 0;
    }
    x += 1;
    
    const AEKeyword filekey  = '----';
    NSString *filepath = [[[event descriptorForKeyword:filekey] stringValue] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    filepath = [filepath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *lineNumber = [NSString stringWithFormat:LINE_FORMAT, x];
    NSString *debug = [NSString stringWithFormat:@"%@ - %@", filepath, lineNumber];
    

    
    NSArray *arguments;
    // wh: had to add more flags to the arguments array
    arguments = [NSArray arrayWithObjects: @"--remote", filepath, @"-c", lineNumber, nil];
    
    
    NSString * result = [[arguments valueForKey:@"description"] componentsJoinedByString:@"\n"];
    
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText: result];
    [alert runModal];
    
    [task setArguments: arguments];
    
    
    
    [task launch];
 
    
    [[NSApplication sharedApplication] terminate:nil];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    return TRUE;
}

@end

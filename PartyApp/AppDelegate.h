//
//  AppDelegate.h
//  PartyApp
//
//  Created by Kanav Arora on 8/5/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSButton *switchTrackButton;
@property (nonatomic, assign) NSUInteger trackIndex;

- (IBAction)playPauseMusic:(NSButton *)sender;
- (IBAction)switchTrack:(NSButton *)sender;
- (IBAction)playSound1:(NSButton *)sender;
- (IBAction)playSound2:(NSButton *)sender;
- (IBAction)setSoundVolume:(NSSlider *)sender;
- (IBAction)setMusicVolume:(NSSlider *)sender;

@end

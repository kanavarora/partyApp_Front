//
//  AppDelegate.m
//  PartyApp
//
//  Created by Kanav Arora on 8/5/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

#import "ASIHTTPRequest.h"
#import "MasterViewController.h"
#import "SoundManager.h"

@interface AppDelegate ()

@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;

@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(__unused NSNotification *)notification
{
    // 1. Create the master View Controller
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    
    // 2. Add the view controller to the Window's content view
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView*)self.window.contentView).bounds;
    
    /*
    NSURL *url = [NSURL URLWithString:@"http://www.mbr-pwrc.usgs.gov/id/htmwav/h5810so.mp3"];
    Sound *sound = [Sound soundWithContentsOfURL:url];
    [[SoundManager sharedManager] prepareToPlayWithSound:sound];
    [[SoundManager sharedManager] playMusic:sound looping:NO];
    //[[SoundManager sharedManager] prepareToPlay];
    //[[SoundManager sharedManager] prepareToPlayWithSound:@"track1.caf"];
    //[self playMusic];
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stoppedPlaying) name:@"SoundDidFinishPlayingNotification" object:nil];
}

- (void)stoppedPlaying {
    NSLog(@"%@", @"WTF");
}

- (void)playMusic
{
    if (self.trackIndex == 0)
    {
        [[SoundManager sharedManager] playMusic:@"track1" looping:NO];
    }
    else
    {
        [[SoundManager sharedManager] playMusic:@"track2" looping:YES];
    }
}

- (IBAction)playPauseMusic:(NSButton *)sender
{
    if ([SoundManager sharedManager].playingMusic)
    {
        [[SoundManager sharedManager] stopMusic];
        [sender setTitle:@"Play Music"];
        [self.switchTrackButton setEnabled:NO];
    }
    else
    {
        [self playMusic];
        [sender setTitle:@"Pause Music"];
        [self.switchTrackButton setEnabled:YES];
    }
}

- (IBAction)switchTrack:(__unused NSButton *)sender
{
    self.trackIndex ++;
    self.trackIndex = self.trackIndex % 2;
    [self playMusic];
}

- (IBAction)playSound1:(__unused NSButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound1" looping:NO];
}

- (IBAction)playSound2:(__unused NSButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
}

- (IBAction)setSoundVolume:(NSSlider *)sender
{
    [SoundManager sharedManager].soundVolume = [sender floatValue]/100.0;
}

- (IBAction)setMusicVolume:(NSSlider *)sender
{
    [SoundManager sharedManager].musicVolume = [sender floatValue]/100.0;
}


@end

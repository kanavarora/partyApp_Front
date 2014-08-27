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
#import "PlayListManager.h"
#import "ServerManager.h"
#import "FullsScreenViewController.h"

@interface AppDelegate ()

@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;
@property (nonatomic, strong) IBOutlet FullsScreenViewController *fullScreenViewController;

@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(__unused NSNotification *)notification
{
     [PlayListManager sharedManager];
    [[ServerManager sharedManager] keepTryingToDownloadPlaylist];
    [self switchToMasterView];
    [[PlayListManager sharedManager]playFromStart];
}

- (void)stoppedPlaying {
    NSLog(@"%@", @"WTF");
}

- (void)switchToMasterView {
    [self.fullScreenViewController.view removeFromSuperview];
    self.fullScreenViewController = nil;
    
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView *)self.window.contentView).bounds;
}

- (void)switchToFullScreenView {
    [self.masterViewController.view removeFromSuperview];
    self.masterViewController = nil;
    
    self.fullScreenViewController = [[FullsScreenViewController alloc] initWithNibName:@"FullScreenView" bundle:nil];
    [self.window.contentView addSubview:self.fullScreenViewController.view];
    self.fullScreenViewController.view.frame = ((NSView *)self.window.contentView).bounds;
}

- (void)downloadedPlaylist {
    if (self.fullScreenViewController) {
        [self.fullScreenViewController setup]; // just resetup.
    }
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

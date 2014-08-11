//
//  MasterViewController.h
//  PartyApp
//
//  Created by Kanav Arora on 8/5/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "EXTKeyPathCoding.h"

@interface MasterViewController : NSViewController


- (IBAction)setSoundVolume:(NSSlider *)sender;
- (IBAction)playPauseMusic:(NSButton *)sender;
- (void)redraw;
- (void)redrawSearch:(NSArray *)songsList;
- (void)enableSearchSongButton;

@end

//
//  PlayListManager.h
//  PartyApp
//
//  Created by Kanav Arora on 8/6/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SoundManager.h"
@class MasterViewController;

@interface PlayListManager : NSObject

+ (PlayListManager *)sharedManager;

@property (nonatomic, readwrite, strong) MasterViewController *vc;
@property (nonatomic, readwrite, strong) NSString *nameOfPlaylist;

@property (nonatomic, readwrite, strong) NSMutableArray *songs;
@property (nonatomic, readwrite, assign) int currentTrackNumber;



- (void)addSongResponse:(NSMutableDictionary *)d;

- (void)playFromStart;
- (void)jumpToNextSong;
- (void)jumpToSongAtIndex:(int) i;

@end

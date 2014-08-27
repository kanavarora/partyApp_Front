//
//  SongBrowserViewController.h
//  PartyApp
//
//  Created by Kanav Arora on 8/26/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SongMetadata.h"

@interface SongBrowserViewController : NSViewController

@property (nonatomic, readwrite, strong) SongMetadata *song;
@property (nonatomic, readwrite, assign) int trackNumber;
- (void)setBorder;
- (void)setupWithSongMetada:(SongMetadata *)current andIndex:(int) i;


@end

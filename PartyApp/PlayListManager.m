//
//  PlayListManager.m
//  PartyApp
//
//  Created by Kanav Arora on 8/6/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import "PlayListManager.h"

#import "SongMetadata.h"
#import "MasterViewController.h"
#import "ServerManager.h"

#define kSongDidFinishNotification @"SoundDidFinishPlayingNotification"

@implementation PlayListManager

+ (instancetype)sharedManager
{
    static PlayListManager *sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        _songs = [NSMutableArray array];
    }
    return self;
}

- (BOOL)doesContainSong:(SongMetadata *)songMetadata {
    for (SongMetadata *song in self.songs) {
        if ([song.uid isEqualTo:songMetadata.uid]) {
            return YES;
        }
    }
    return NO;
}

- (void)triggerPendingDownloads {
    // check in file path TODO:
    for (SongMetadata *song in self.songs) {
        if (song.downloadStatus == notDownloaded) {
            // check if file already exisits, if not then download it
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:song.nameOfSong];
            BOOL fileExits = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (fileExits) {
                song.downloadStatus = downloaded;
            } else {
                [[ServerManager sharedManager] downloadSongFromLocalhost:song];
            }
        }
    }
}

- (void)addSongResponse:(NSMutableDictionary *)d {
    SongMetadata *songMetadata = [[SongMetadata alloc]
                                  initWithUid:d[@"_id"][@"$oid"]
                                  phoneNumber:d[@"phoneNumber"]
                                  songId:d[@"songId"]
                                  url:d[@"link"]
                                  duration:[d[@"duration"] floatValue]
                                  songName:d[@"songName"]
                                  artistName:d[@"artistName"]
                                  serialized:d[@"serialized"]];
    if (![self doesContainSong:songMetadata]) {
        [self.songs addObject:songMetadata];
        [self triggerPendingDownloads];
        [self.vc redraw];
        if (self.currentTrackNumber == self.songs.count - 1) {
            // play the new song
            [self playCurrentSong];
        }
    }
}

// Playing songs in a queue
- (void)playFromStart {
    self.currentTrackNumber = 0;
    [self playCurrentSong];
}

- (void)playCurrentSong {
    [self playSongAtTrack:self.currentTrackNumber];
}

- (void)finishedPlayingSong {
    [self clearStateFromCurrentSong];
    [self jumpToNextSong];
}

- (void)jumpToSongAtIndex:(int) i {
    self.currentTrackNumber = i;
    if (self.currentTrackNumber >= self.songs.count) {
        self.currentTrackNumber = (int)self.songs.count;
    }
    [self clearStateFromCurrentSong];
    [[SoundManager sharedManager] stopMusic:NO];
    [self performSelector:@selector(playCurrentSong) withObject:nil afterDelay:1.0f];
}

- (void)jumpToNextSong {
    [self jumpToSongAtIndex:self.currentTrackNumber+1];
}

- (void)playSongAtTrack:(int)index {
    if (index < self.songs.count) {
        [self playSongWithMetadata:self.songs[index]];
    }
}


// Music Player
-(void)playSongWithMetadata:(SongMetadata *)songMetadata {
    if (songMetadata.downloadStatus == isDownloading) {
        [self performSelector:@selector(playSongWithMetadata:) withObject:songMetadata afterDelay:0.5f];
        return;
        // TODO: check for failed download
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:songMetadata.nameOfSong];
    Sound *song = [Sound soundNamed:filePath];
    [[SoundManager sharedManager] prepareToPlayWithSound:song];
    [[SoundManager sharedManager] playMusic:song looping:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:    @selector(finishedPlayingSong) name:kSongDidFinishNotification object:nil];
}

- (void)clearStateFromCurrentSong {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSongDidFinishNotification object:nil];
}


@end

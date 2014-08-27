//
//  ServerManager.h
//  PartyApp
//
//  Created by Kanav Arora on 8/6/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MasterViewController;
@class SongMetadata;
@interface ServerManager : NSObject

+ (ServerManager *)sharedManager;
- (void)keepTryingToDownloadPlaylist;
- (void)downloadPlayList:(NSString *)playListName;
// TODO: dont take vc as arguments
- (void)searchForSong:(NSString *)query withVC:(MasterViewController *)vc;
- (void)addSearchSongToPlayList:(NSMutableDictionary *)song withVc:(MasterViewController *)vc;
- (void)downloadSongFromLocalhost:(SongMetadata *)songMetada;

@end

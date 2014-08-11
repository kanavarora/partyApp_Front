//
//  ServerManager.h
//  PartyApp
//
//  Created by Kanav Arora on 8/6/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject

+ (ServerManager *)sharedManager;
- (void)keepTryingToDownloadPlaylist;
- (void)downloadPlayList:(NSString *)playListName;

@end

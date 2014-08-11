//
//  ServerManager.m
//  PartyApp
//
//  Created by Kanav Arora on 8/6/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import "ServerManager.h"

#import "ASIHTTPRequest.h"
#import "PlayListManager.h"

@implementation ServerManager

+ (instancetype)sharedManager
{
    static ServerManager *sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

#define kMainUrl @"http://localhost:5000/"

+(NSString *)constructUrl:(NSString *)relativeUrl {
    return [NSString stringWithFormat:@"%@%@", kMainUrl, relativeUrl];
}

#define kIntervalSec 10.0f
- (void)keepTryingToDownloadPlaylist {
    [self downloadPlayList:@"default"];
    [self performSelector:@selector(keepTryingToDownloadPlaylist) withObject:nil afterDelay:kIntervalSec];
}

- (void)downloadPlayList:(NSString *)playListName {
    NSURL *url = [NSURL URLWithString:[ServerManager constructUrl:@"getPlayList"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSArray* songsList = [NSJSONSerialization
                              JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                              
                              options:kNilOptions 
                              error:&error];
        for (NSMutableDictionary *song in songsList) {
            [[PlayListManager sharedManager] addSongResponse:song];
        }
        NSLog(@"%@", response);
    }
}

@end

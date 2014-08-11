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
#import "MasterViewController.h"
#import "ASIFormDataRequest.h"

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
    
    [request setCompletionBlock:^{
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
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"%@", error);
    }];
    
    [request startAsynchronous];
}


- (void)searchForSong:(NSString *)query withVC:(MasterViewController *)vc {
    NSString *relativeUrl = [NSString stringWithFormat:@"querySong?query=%@", query];
    relativeUrl = [relativeUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:[ServerManager constructUrl:relativeUrl]];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSError *error = [request error];
        if (!error) {
            NSString *response = [request responseString];
            NSArray *songsList = [NSJSONSerialization
                                  JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&error];
            [vc redrawSearch:songsList];
        }

    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"%@", error);
    }];
    [request startAsynchronous];
}


- (void)addSearchSongToPlayList:(NSMutableDictionary *)song withVc:(MasterViewController *)vc{
    NSString *relativeUrl = @"addSearchSong";
    NSURL *url = [NSURL URLWithString:[ServerManager constructUrl:relativeUrl]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:song
                                                       options:kNilOptions
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:jsonString forKey:@"song"];
    [request setCompletionBlock:^{
        NSError *error = [request error];
        if (!error) {
            NSString *response = [request responseString];
            NSLog(@"%@", response);
            [self downloadPlayList:@"default"]; // just trigger download of the playlist
        }
        [vc enableSearchSongButton];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"%@", error);
        [vc enableSearchSongButton];
    }];
    [request startAsynchronous];
}

@end

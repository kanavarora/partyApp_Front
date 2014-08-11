//
//  SongMetadata.m
//  PartyApp
//
//  Created by Kanav Arora on 8/10/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import "SongMetadata.h"

@implementation SongMetadata


- (id) initWithUid:(NSString *)uid
       phoneNumber:(NSString *)phoneNumber
            songId:(NSString *)songId
               url:(NSString *)url
          duration:(float)duration
          songName:(NSString *)songName
        artistName:(NSString *)artistName {
    if (self  = [super init]) {
        _uid = uid;
        _phoneNumber= phoneNumber;
        _songId = songId;
        _url = url;
        _duration = duration;
        _songName = songName;
        _artistName = artistName;
    }
    return self;
}

- (NSString *)nameOfSong {
    return [NSString stringWithFormat:@"%@-%@.mp3", self.songId, self.phoneNumber];
}

@end

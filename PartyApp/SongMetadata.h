//
//  SongMetadata.h
//  PartyApp
//
//  Created by Kanav Arora on 8/10/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongMetadata : NSObject

@property (nonatomic, readwrite, strong) NSString *uid;
@property (nonatomic, readwrite, strong) NSString *phoneNumber;
@property (nonatomic, readwrite, strong) NSString *songId;
@property (nonatomic, readwrite, strong) NSString *url;
@property (nonatomic, readwrite, assign) float duration;
@property (nonatomic, readwrite, strong) NSString *songName;
@property (nonatomic, readwrite, strong) NSString *artistName;

- (id) initWithUid:(NSString *)uid
       phoneNumber:(NSString *)phoneNumber
            songId:(NSString *)songId
               url:(NSString *)url
          duration:(float)duration
          songName:(NSString *)songName
        artistName:(NSString *)artistName;

- (NSString *)nameOfSong;

@end

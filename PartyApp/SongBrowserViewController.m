//
//  SongBrowserViewController.m
//  PartyApp
//
//  Created by Kanav Arora on 8/26/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import "SongBrowserViewController.h"

#import "SongMetadata.h"

@interface SongBrowserViewController ()

@property (weak) IBOutlet NSImageView *albumImage;
@property (weak) IBOutlet NSTextField *songName;

@end

@implementation SongBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view setWantsLayer:YES]; // myView is an NSView
}

- (void)setBorder {
    self.view.layer.borderWidth = 2.0f;
    self.view.layer.borderColor = [NSColor orangeColor].CGColor;
}

- (void)setupWithSongMetada:(SongMetadata *)current andIndex:(int) i{
    if (i== self.trackNumber) {
        // already setup
        return;
    }
    self.song = current;
    self.trackNumber = i;
    if (current) {
        [self.songName setHidden:NO];
        [self.albumImage setHidden:NO];
    self.songName.stringValue = [NSString stringWithFormat:@"%@ - %@\n%@", current.songName, current.artistName, current.phoneNumber];

        NSString *albumUrl = current.serialized[@"cover"];
        if ([albumUrl isEqualToString:@"http://images.grooveshark.com/static/albums/0"] || albumUrl.length == 0) {
            albumUrl = @"http://4.bp.blogspot.com/_-Tzt6qbOrjA/TQfx8dJFwbI/AAAAAAAABGs/dk_yNdwkj8w/s320/default_song_album.jpg";
        }
    NSImage *img = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:albumUrl]];
    [img setSize:NSMakeSize(200, 200)];
    self.albumImage.image = img;
    } else {
        [self.songName setHidden:YES];
        [self.albumImage setHidden:YES];
    }

}

@end

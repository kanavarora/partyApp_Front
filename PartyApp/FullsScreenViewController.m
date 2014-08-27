//
//  FullsScreenViewController.m
//  PartyApp
//
//  Created by Kanav Arora on 8/13/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import "FullsScreenViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "PlayListManager.h"
#import "SongMetadata.h"
#import "AppDelegate.h"
#import "SongBrowserViewController.h"

@interface FullsScreenViewController ()

@property (weak) IBOutlet NSTextField *currentSongName;
@property (weak) IBOutlet NSTextField *currentPhoneNumber;
@property (weak) IBOutlet NSImageView *albumImage;


@property (nonatomic, readwrite, strong) NSMutableArray *songVcs;
@property (nonatomic, readwrite, strong) NSMutableArray *queuedVcs;

@end

#define kMaxQueued 3
#define kMaxDisplay 2

@implementation FullsScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [[PlayListManager sharedManager] addObserver:self
                                          forKeyPath:@"currentTrackNumber"
                                             options:(NSKeyValueObservingOptionNew |
                                                      NSKeyValueObservingOptionOld)
                                             context:NULL];
        _songVcs = [[NSMutableArray alloc] init];
        _queuedVcs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view setWantsLayer:YES]; // myView is an NSView
    self.view.layer.backgroundColor = [NSColor blackColor].CGColor;
    [self setupTableOnce];
    [self setup];
}

- (void)dealloc {
    [[PlayListManager sharedManager] removeObserver:self forKeyPath:@"currentTrackNumber"];
}

- (float)offsetForIndex:(int) i andWidth:(float)w {
    float total = 0;
    for (int x =0; x< ABS(i) ; x++) {
        float s = 0.5 + ((kMaxDisplay - x)*0.25);
        float s1 = 0.5 + ((kMaxDisplay - 1 - x)*0.25);
        total += s*w*0.5 + s1*w*0.5;
        if (i> 0) {
            total += (w*0.5);
        }
    }
    return i>=0 ? total : -total;
}

- (void)setupTableOnce {
    for (int a =-kMaxDisplay; a <=kMaxDisplay; a++) {
        float scaleFactor = 0.5 + ((kMaxDisplay - ABS(a))*0.25);
        SongBrowserViewController *vc = [[SongBrowserViewController alloc] initWithNibName:@"SongBrowserViewController" bundle:nil];
        float w = vc.view.frame.size.width/2;
        float offset = [self offsetForIndex:a andWidth:w];
        vc.view.frame = CGRectMake((self.view.frame.size.width - vc.view.frame.size.width)/2 + offset,
                                   (self.view.frame.size.height - vc.view.frame.size.height*scaleFactor)/2,
                                   vc.view.frame.size.width*scaleFactor, vc.view.frame.size.height*scaleFactor);
        [vc.view setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        [self.view addSubview:vc.view];
        if (a==0) {
            [vc setBorder];
        }
        [vc.view scaleUnitSquareToSize:NSMakeSize(scaleFactor, scaleFactor)];
        [vc setupWithSongMetada:nil andIndex:-1];
        [self.songVcs addObject:vc];
    }
    
    for (int i=0; i<kMaxQueued ; i++) {
        int offset = 200;
        float scaleFactor = 0.5f;
        SongBrowserViewController *vc = [[SongBrowserViewController alloc] initWithNibName:@"SongBrowserViewController" bundle:nil];
        vc.view.frame = CGRectMake((self.view.frame.size.width - vc.view.frame.size.width*scaleFactor + i*offset)/2 + 150,
                                   (self.view.frame.size.height - vc.view.frame.size.height*scaleFactor)/2 - 300, // as down as possible
                                   vc.view.frame.size.width*scaleFactor, vc.view.frame.size.height*scaleFactor);
        [vc.view setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        [self.view addSubview:vc.view];
        [vc.view scaleUnitSquareToSize:NSMakeSize(scaleFactor, scaleFactor)];
        [vc setupWithSongMetada:nil andIndex:-1];
        [self.queuedVcs addObject:vc];

    }
}

- (void)tableViewSetup {
    int t = [PlayListManager sharedManager].currentTrackNumber;
    NSArray *songs = [PlayListManager sharedManager].songs;
    for (int a =-2; a <=2 ; a++) {
        int i = a + t;
        SongBrowserViewController *vc = self.songVcs[a+2];
        if (songs.count && i < songs.count && i >=0) {
            SongMetadata *current = songs[i];
            [vc setupWithSongMetada:current andIndex:i];
        } else {
            [vc setupWithSongMetada:nil andIndex:-1];
        }
    }
    
    for (int a=0; a<kMaxQueued; a++) {
        int index = (int)songs.count -a -1;
        SongMetadata *queuedSong = (songs.count > a) ? songs[index] : nil;
        SongBrowserViewController *vc = self.queuedVcs[a];
        [vc setupWithSongMetada:queuedSong andIndex:index];
    }
}

- (void)setup {
    [self tableViewSetup];
}

- (IBAction)switchToMasterScreen:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate switchToMasterView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualTo:@"currentTrackNumber"]) {
        NSLog(@"%@", @"observed succesfully");
        [self setup];
    }
}

@end

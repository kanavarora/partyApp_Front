//
//  MasterViewController.m
//  PartyApp
//
//  Created by Kanav Arora on 8/5/14.
//  Copyright (c) 2014 Kanav Arora. All rights reserved.
//

#import "MasterViewController.h"

#import "ServerManager.h"
#import "SoundManager.h"
#import "PlayListManager.h"
#import "SongMetadata.h"

@interface MasterViewController ()
@property (weak) IBOutlet NSTableView *songsTable;

@property (nonatomic, readwrite, assign) BOOL isPaused;

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [PlayListManager sharedManager];
        // Initialization code here.
        [[PlayListManager sharedManager] addObserver:self
                  forKeyPath:@"currentTrackNumber"
                     options:(NSKeyValueObservingOptionNew |
                              NSKeyValueObservingOptionOld)
                     context:NULL];
        [[ServerManager sharedManager] keepTryingToDownloadPlaylist];
        [self setupTableView];
        [PlayListManager sharedManager].vc = self;
        [[PlayListManager sharedManager] playFromStart];
        
    }
    return self;
}

- (void)setupTableView {
    self.songsTable.backgroundColor = [NSColor blackColor];
}

- (void)redraw {
    [self.songsTable reloadData];
}

- (void)playMusicFromUrl:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:@"http://www.mbr-pwrc.usgs.gov/id/htmwav/h5810so.mp3"];
    Sound *sound = [Sound soundWithContentsOfURL:url];
    [[SoundManager sharedManager] prepareToPlayWithSound:sound];
    [[SoundManager sharedManager] playMusic:sound looping:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stoppedPlaying) name:@"SoundDidFinishPlayingNotification" object:nil];
}

- (void)stoppedPlaying {
    NSLog(@"%@", @"WTF");
}

-(int)selectedSongMetadataIndex
{
    NSInteger selectedRow = [self.songsTable selectedRow];
    NSArray *songs = [PlayListManager sharedManager].songs;
    if( selectedRow >=0 && songs.count > selectedRow )
    {
        return selectedRow;
    }
    return -1;
    
}

- (IBAction)playCurrentSelected:(id)sender {
    int selectedIndex = [self selectedSongMetadataIndex];
    if (selectedIndex >= 0) {
        [[PlayListManager sharedManager] jumpToSongAtIndex:selectedIndex];
    }
}

- (IBAction)playPauseMusic:(NSButton *)sender
{
    if (self.isPaused) {
        [[SoundManager sharedManager] resumeMusic];
        self.isPaused = NO;
        [sender setTitle:@"Pause"];
    } else {
        [[SoundManager sharedManager] pauseMusic];
        self.isPaused = YES;
        [sender setTitle:@"Play"];
    }
}

- (IBAction)setSoundVolume:(NSSlider *)sender
{
    [SoundManager sharedManager].soundVolume = [sender floatValue]/100.0;
    [SoundManager sharedManager].musicVolume = [sender floatValue]/100.0;
}

- (IBAction)skipCurrentSong:(id)sender
{
    [[PlayListManager sharedManager] jumpToNextSong];
}

- (void)setupCellView:(NSTableCellView *)cellView isCurrent:(BOOL)isCurrent {
    cellView.textField.textColor = [NSColor whiteColor];
    //cellView.textField.backgroundColor = [NSColor yellowColor];
    if (isCurrent) {
        cellView.textField.backgroundColor = [NSColor yellowColor];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    BOOL isCurrent = NO;
    SongMetadata *songMetadata = [PlayListManager sharedManager].songs[row];
    if (row == [PlayListManager sharedManager].currentTrackNumber) {
        isCurrent = YES;
    }
    if (isCurrent) {
        NSTableRowView *rowView = [tableView rowViewAtRow:row makeIfNecessary:YES];
        rowView.backgroundColor = [NSColor orangeColor];
    }
    if ([tableColumn.identifier isEqualTo:@"SongColumn"]) {
        // Get a new ViewCell
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = songMetadata.songName? songMetadata.songName : @"";
        [self setupCellView:cellView isCurrent:isCurrent];
        return cellView;
    } else if ([tableColumn.identifier isEqualTo:@"ArtistColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = songMetadata.artistName? songMetadata.artistName : @"";
        [self setupCellView:cellView isCurrent:isCurrent];
        return cellView;
    } else if ([tableColumn.identifier isEqualTo:@"DurationColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = [@(songMetadata.duration) stringValue];
        [self setupCellView:cellView isCurrent:isCurrent];
        return cellView;
    } else if ([tableColumn.identifier isEqualTo:@"PhoneColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = songMetadata.phoneNumber ? songMetadata.phoneNumber : @"";
        [self setupCellView:cellView isCurrent:isCurrent];
        return cellView;
    }
    return nil;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [PlayListManager sharedManager].songs.count;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualTo:@"currentTrackNumber"]) {
        NSLog(@"%@", @"observed succesfully");
        [self redraw];
    }
}

@end

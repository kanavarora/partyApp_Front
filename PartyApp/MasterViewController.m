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
#import "AppDelegate.h"

@interface MasterViewController ()
@property (weak) IBOutlet NSTableView *songsTable;
@property (weak) IBOutlet NSTableView *searchTable;
@property (weak) IBOutlet NSTextField *searchText;
@property (weak) IBOutlet NSButton *addSearchSongButton;



@property (nonatomic, readwrite, assign) BOOL isPaused;

@property (nonatomic, readwrite, strong) NSArray *searchSongs;

@end

@implementation MasterViewController

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
        [PlayListManager sharedManager].vc = self;
        
    }
    return self;
}

- (void)dealloc {
    [[PlayListManager sharedManager] removeObserver:self forKeyPath:@"currentTrackNumber"];
}

- (void)loadView {
    [super loadView];
    [self setupTableView];
}
- (void)setupTableView {
    self.songsTable.backgroundColor = [NSColor blackColor];
}

- (void)redraw {
    [self.songsTable reloadData];
}

- (void)redrawSearch:(NSArray *)songsList {
    self.searchSongs = songsList;
    [self.searchTable reloadData];
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

-(int)selectedSearchSong
{
    NSInteger selectedRow = [self.searchTable selectedRow];
    NSArray *songs = self.searchSongs;
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

- (IBAction)searchForSong:(id)sender
{
    NSString *query = self.searchText.stringValue;
    if (query.length) {
        [[ServerManager sharedManager] searchForSong:query withVC:self];
    }
}

- (IBAction)addSearchSong:(id)sender {
    int i = [self selectedSearchSong];
    if (i > -1) {
        [[ServerManager sharedManager] addSearchSongToPlayList:self.searchSongs[i] withVc:self];
        // disable add button for some seconds until we get response
        [self.addSearchSongButton setEnabled:NO];
    }
}

- (IBAction)switchToFullScreen:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate switchToFullScreenView];
}

- (void)enableSearchSongButton {
    [self.addSearchSongButton setEnabled:YES];
}

- (void)setupCellView:(NSTableCellView *)cellView isCurrent:(BOOL)isCurrent {
    cellView.textField.textColor = [NSColor whiteColor];
    if (isCurrent) {
        cellView.textField.backgroundColor = [NSColor yellowColor];
    }
}

// song table View
- (NSView *)tableViewForSongsTable:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
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

// search table view
- (NSView *)tableViewForSearchTable:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSMutableDictionary *searchSong = self.searchSongs[row];
    if ([tableColumn.identifier isEqualTo:@"searchNameColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = searchSong[@"name"];
        return cellView;
    } else if ([tableColumn.identifier isEqualTo:@"searchArtistNameColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = searchSong[@"artist"];
        return cellView;
    } else if ([tableColumn.identifier isEqualTo:@"searchDurationColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = [@((int)[searchSong[@"duration"] floatValue]) stringValue];
        return cellView;
    }
    return nil;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.songsTable) {
        return [self tableViewForSongsTable:tableView viewForTableColumn:tableColumn row:row];
    } else if (tableView == self.searchTable) {
        return [self tableViewForSearchTable:tableView viewForTableColumn:tableColumn row:row];
    }
    return nil;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.songsTable) {
        return [PlayListManager sharedManager].songs.count;
    } else if (tableView == self.searchTable) {
        return self.searchSongs.count;
    }
    return 0;
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

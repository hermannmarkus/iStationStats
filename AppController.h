//iStationStats - Statistiken für Shoutcast-Streams
//
//Copyright (C) 2010 Markus Hermann
//
//This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.

/* AppController */

#import <Cocoa/Cocoa.h>
#import "StatusBar.h"

@interface AppController : NSObject
{
    IBOutlet NSButton *startButton;
    IBOutlet NSButton *stopButton;
	IBOutlet NSTextField *aktTextField;
	IBOutlet NSTextField *listenerCountTextField;
	IBOutlet NSTextField *intervalTextField;
	IBOutlet NSTextField *streamURL;
	IBOutlet NSTextField *streamPort;
	IBOutlet NSSlider *intervalSlider;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSProgressIndicator *testURLProInd;
	IBOutlet NSProgressIndicator *getTitleProInd;
	IBOutlet NSImageView *testImg;
	IBOutlet NSSegmentedControl *statusBarState;
	IBOutlet NSMenu *statusBarMenu;
	
	IBOutlet NSArrayController *infoArrayController;
	IBOutlet NSArrayController *playlistFilterArrayController;
	IBOutlet NSArrayController *titleFilterArrayController;
	
	StatusBar *statBar;
	bool showStatBar;
	
	NSMutableArray *titInfo;
	NSMutableArray *playlistFilter;
	NSMutableArray *titleFilter;
	
	NSMutableData *receivedData;
	
	NSString *streamURLString;
	NSNumber *streamPortNumber;
	
	NSTimer *getInfoTimer;
	int timerCount;
	int i;
	int interval;
	bool checkURL;
}
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)expPlaylist:(id)sender;
- (IBAction)setInterval:(id)sender;
- (IBAction)testURL:(id)sender;
- (IBAction)changeStatusBarState:(id)sender;

- (void)copyToPasteboard:(NSString *)pasteboardString;
- (void)savePreferences;
- (void)loadPreferences;

- (void)getInfo;
- (void)exportPlaylist;
- (BOOL)filterCheck:(int)lineCount;
- (NSString* )titleFilter:stringToFilter;
- (void)setListeners:(NSString *)listeners;

@end

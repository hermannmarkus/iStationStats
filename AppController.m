//iStationStats - Statistiken für Shoutcast-Streams
//
//Copyright (C) 2010 Markus Hermann
//
//This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.

#import "AppController.h"
#import "StatusBar.h"

@implementation AppController

- (id)init
{
	[super init];
	titInfo = [[NSMutableArray alloc] init];
	titleFilter = [[NSMutableArray alloc] init];
	playlistFilter = [[NSMutableArray alloc] init];
	streamURLString = [[NSString alloc] init];
	streamPortNumber = [[NSNumber alloc] init];
	showStatBar = YES;
	
	[mainWindow setDelegate:self];
	timerCount = 0;
	return self;
}

- (IBAction)start:(id)sender
{
	
	if(timerCount == 0)
	{
		[self getInfo];
		getInfoTimer = [NSTimer scheduledTimerWithTimeInterval:interval target: self selector: @selector(getInfo) userInfo: nil repeats: YES];
		[aktTextField setHidden:NO];
	}
	timerCount++;
	[getTitleProInd startAnimation:self];
}

- (IBAction)stop:(id)sender
{
	if(timerCount != 0)
	{
		[getInfoTimer invalidate];
		timerCount = 0;
		[aktTextField setHidden:YES];
		[getTitleProInd stopAnimation:self];
	}
}

- (IBAction)expPlaylist:(id)sender
{
	[self exportPlaylist];
	/*	NSString *testString = [NSString stringWithString:@"Hallo das ist ein Test"];
	NSLog(@"%@",[self titleFilter:testString]);*/
}

- (IBAction)setInterval:(id)sender
{
	interval = [intervalSlider floatValue];
	[intervalTextField setObjectValue:[NSString stringWithFormat:@"%d", interval]];
	//	NSLog(@"%d", interval);
}

- (IBAction)testURL:(id)sender
{
	[testImg setHidden:YES];
	[testURLProInd startAnimation:self];
	checkURL = YES;
	[self getInfo];
}

- (void)getInfo
{
	NSString *stationString = [NSString stringWithString:@"http://"];
	stationString = [stationString stringByAppendingString:[streamURL objectValue]];
	stationString = [stationString stringByAppendingString:@":"];
	stationString = [stationString stringByAppendingString:[NSString stringWithFormat:@"%@", [streamPort objectValue]]];
	stationString = [stationString stringByAppendingString:@"/7"];
	NSURL *stationURL = [NSURL URLWithString:stationString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:stationURL];
	float tiInterval = 30;
	[request setTimeoutInterval:tiInterval];
	[request setValue:@"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)" forHTTPHeaderField:@"User-Agent"];
	//	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil];
	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	if (theConnection) {
		receivedData = [[NSMutableData alloc] init];
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}
}

- (void)exportPlaylist
{	
	NSMutableArray *exportArray = [[NSMutableArray alloc] init];
	//Titel filtern
	if([titInfo count] != 0)
	{
		for(i = 0; i < [titInfo count]; i++)
		{
			if([self filterCheck:i])
			{
				if(i == 0)
				{
					[exportArray addObject:[[titInfo objectAtIndex:i] objectForKey:@"title"]];
				}else{
					if([[[titInfo objectAtIndex:i] objectForKey:@"title"] isEqualToString:[[titInfo objectAtIndex:(i-1)] objectForKey:@"title"]])
					{
					}else{
						[exportArray addObject:[[titInfo objectAtIndex:i] objectForKey:@"title"]];
					}
				}
			}
		}
		NSString *ausgabe = [NSString stringWithString:@""];
		for(i = 0; i < [exportArray count]; i++)
		{
			ausgabe = [ausgabe stringByAppendingString:[exportArray objectAtIndex:i]];
			ausgabe = [ausgabe stringByAppendingString:@"\n"];
		}
		NSLog(@"%@", ausgabe);
		[self copyToPasteboard: ausgabe];
	}else{
		NSLog(@"Titelliste leer");
	}
	[exportArray release];
}

- (BOOL)filterCheck:(int)lineCount
{
	int q = 0;
	int j;
	NSMutableArray *exportFilter = [[NSMutableArray alloc] init];
	if([playlistFilter count] != 0)
	{
		for(j = 0; j < [playlistFilter count]; j++)
		{
			[exportFilter addObject:[[playlistFilter objectAtIndex:j] objectForKey:@"playlistFilterString"]];
		}
		
		for(j = 0; j < [exportFilter count]; j++)
		{
			if([[exportFilter objectAtIndex:j]isEqualToString:[[titInfo objectAtIndex:lineCount] objectForKey:@"title"]])
			{
				q = 1;
			}
		}
	}
	[exportFilter release];
	if(q == 0)
	{
		return YES;
	}else{
		return NO;
	}
}

- (NSString* )titleFilter:stringToFilter
{
	int j;
	NSArray *prefixArray = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], @"", nil];
	NSString *returnString = [[NSString alloc] init];
	if([titleFilter count] != 0)
	{
		for(j = 0; j < [titleFilter count]; j++)
		{
			if([[titleFilter objectAtIndex:j] objectForKey:@"titleFilterString"] != nil &&[stringToFilter hasPrefix:[[titleFilter objectAtIndex:j] objectForKey:@"titleFilterString"]])
			{
				prefixArray = [NSArray arrayWithObjects: [NSNumber numberWithInt: 1], [[titleFilter objectAtIndex:j] objectForKey:@"titleFilterString"], nil];
			}
		}
		if([[prefixArray objectAtIndex:0]isEqualToNumber:[NSNumber numberWithInt:1]])
		{
			returnString = [stringToFilter substringFromIndex:[[prefixArray objectAtIndex:1] length]];
		}else{
			returnString = stringToFilter;
		}
	}else{
		returnString = stringToFilter;
	}
	return returnString;
	[returnString release];
}

- (void)copyToPasteboard:(NSString *)pasteboardString
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteboard setString:pasteboardString forType:NSStringPboardType];
}

- (void)savePreferences
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([[streamURL objectValue]isEqualToString:@""])
	{
		[defaults setObject:[NSString stringWithString:@""] forKey:@"streamURL"];
	}else{
		[defaults setObject:[streamURL objectValue] forKey:@"streamURL"];
	}
	if([[NSString stringWithFormat:@"%d", [streamPort objectValue]]isEqualToString:@""])
	{
		[defaults setObject:@"" forKey:@"streamPort"];
	}else{
		[defaults setObject:[streamPort objectValue] forKey:@"streamPort"];
	}	
	[defaults setObject:[intervalSlider objectValue] forKey:@"interval"];
	
	//playlistFilter
	NSMutableArray *playlistFilterStringArray = [[NSMutableArray alloc] init];
	for(i = 0; i < [playlistFilter count]; i++)
	{
		if([[playlistFilter objectAtIndex:i] objectForKey:@"playlistFilterString"] != nil)
		{
			[playlistFilterStringArray addObject:[[playlistFilter objectAtIndex:i] objectForKey:@"playlistFilterString"]];
		}
	}
	if([[defaults objectForKey:@"playlistFilter"] count] != 0)
	{
		[defaults removeObjectForKey:@"playlistFilter"];
	}
	[defaults setObject:[NSArray arrayWithArray:playlistFilterStringArray] forKey:@"playlistFilter"];
	
	//titelFilter
	NSMutableArray *titleFilterStringArray = [[NSMutableArray alloc] init];
	for(i = 0; i < [titleFilter count]; i++)
	{
		if([[titleFilter objectAtIndex:i] objectForKey:@"titleFilterString"] != nil)
		{
			[titleFilterStringArray addObject:[[titleFilter objectAtIndex:i] objectForKey:@"titleFilterString"]];
		}
	}
	if([[defaults objectForKey:@"titleFilter"] count] != 0)
	{
		[defaults removeObjectForKey:@"titleFilter"];
	}
	[defaults setObject:[NSArray arrayWithArray:titleFilterStringArray] forKey:@"titleFilter"];
	
	//StatBar einbauen
	if(showStatBar)
	{
		[defaults setObject:[NSString stringWithString:@"YES"] forKey:@"showStatBar"];
	}else{
		[defaults setObject:[NSString stringWithString:@"NO"] forKey:@"showStatBar"];
	}
}

- (void)loadPreferences
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//URL Settings
	streamURLString = [defaults objectForKey:@"streamURL"];
	streamPortNumber = [defaults objectForKey:@"streamPort"];
	[streamURL setObjectValue:streamURLString];
	[streamPort setObjectValue:streamPortNumber];
	//Intervalsettings
	if([defaults objectForKey:@"interval"] == nil)
	{
		interval = 15;
	}else{
		interval = [[defaults objectForKey:@"interval"] intValue];
		[intervalTextField setObjectValue:[NSString stringWithFormat:@"%d", interval]];
		[intervalSlider setIntValue:interval];		
	}
	//Titelfiltersettings
	if([defaults objectForKey:@"titleFilter"] != nil)
	{
		for(i = 0; i < [[defaults objectForKey:@"titleFilter"] count]; i++)
		{
			[self willChangeValueForKey:@"titleFilter"];
			[titleFilter addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithString:[[defaults objectForKey:@"titleFilter"] objectAtIndex:i]], @"titleFilterString", nil]];
			[self didChangeValueForKey:@"titleFilter"];
		}
	}
	//Playlistfiltersettings
	if([defaults objectForKey:@"playlistFilter"] != nil)
	{
		for(i = 0; i < [[defaults objectForKey:@"playlistFilter"] count]; i++)
		{
			[self willChangeValueForKey:@"playlistFilter"];
			[playlistFilter addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithString:[[defaults objectForKey:@"playlistFilter"] objectAtIndex:i]], @"playlistFilterString", nil]];
			[self didChangeValueForKey:@"playlistFilter"];
		}
	}
	
	//statBar einbauen
	if([defaults objectForKey:@"showStatBar"])
	{
		if([[defaults objectForKey:@"showStatBar"]isEqualToString:@"YES"])
		{
			showStatBar = YES;
		}
		if([[defaults objectForKey:@"showStatBar"]isEqualToString:@"NO"])
		{
			showStatBar = NO;
			[statusBarState setSelectedSegment:1];
		}
	}
}

- (void)awakeFromNib
{
	[self loadPreferences];
	if(showStatBar)
	{
		statBar = [[StatusBar alloc]init];
		[statBar setItem];
	}
	
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *)application hasVisibleWindows:(BOOL) visibleWindows
{
	NSLog(@"hallo2");
    if (![mainWindow isVisible])
	{
		NSLog(@"Hallo");
        [mainWindow makeKeyAndOrderFront:nil];
	}
    return NO;
}

- (IBAction)changeStatusBarState:(id)sender
{
	if([statusBarState selectedSegment] == 0)
	{
		if(!showStatBar)
		{
			statBar = [[StatusBar alloc]init];
			[statBar setItem];
			//	[statBar setMenu:statusBarMenu];
			/*NSImage *statBarImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection_error" ofType:@"png"]];
			NSImage *statBarAltImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection_error_alt" ofType:@"png"]];
			[statBar setImage:statBarImage withAltImage:statBarAltImage];
			[statBarImage release];
			[statBarAltImage release];*/
		}
		showStatBar = YES;
	}
	if([statusBarState selectedSegment] == 1)
	{
		[statBar removeItem];
		showStatBar = NO;
	}
}

- (void)setListeners:(NSString*)listeners
{
	[listenerCountTextField setObjectValue:listeners];
	if(showStatBar)
	{
		[statBar changeItem:[listenerCountTextField objectValue]];
	}
	/*	if(showStatBar)
	{
		NSImage *statBarImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"listeners" ofType:@"png"]];
		NSImage *statBarAltImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection_error_alt" ofType:@"png"]];
		[statBar setImage:statBarImage withAltImage:statBarAltImage];
		[statBarImage release];
		[statBarAltImage release];
	}*/
}

//*******************
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//    [connection release];
	//    [receivedData release];
	if(checkURL)
	{
		[testURLProInd stopAnimation:self];
		[testImg setHidden:NO];
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test_no" ofType: @"png"]];
		[testImg setImage:image];
		[image release];
	}else{
		[aktTextField setObjectValue:@"Aufzeichnung inaktiv. URL vielleicht falsch."];
		[getTitleProInd stopAnimation:self];
		if(showStatBar)
		{
			NSImage *statBarImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection_error" ofType:@"png"]];
			NSImage *statBarAltImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection_error_alt" ofType:@"png"]];
			[statBar setImage:statBarImage withAltImage:statBarAltImage];
			[statBarImage release];
			[statBarAltImage release];
		}
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// do something with the data
	//	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
    // release the connection, and the data object
	//    [connection release];
	//    [receivedData release];
	[aktTextField setObjectValue:@"Aufzeichnung aktiv"];
	if(checkURL)
	{
		[testURLProInd stopAnimation:self];
		[testImg setHidden:NO];
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test_yes" ofType: @"png"]];
		[testImg setImage:image];
		[image release];
		checkURL = NO;
	}else{
		[getTitleProInd stopAnimation:self];
		if(receivedData != nil)
		{
			NSArray *infoArray;
			NSString *returnString = [[NSString alloc] initWithData:receivedData encoding:4];
			NSArray *split = [returnString componentsSeparatedByString:@"<body>"];
			if([split count] != 0)
			{
				NSArray *split2 = [[split objectAtIndex:1] componentsSeparatedByString:@"</body"];
				NSArray *data = [[split2 objectAtIndex:0] componentsSeparatedByString:@","];
				if([[aktTextField objectValue]isEqualToString:@"Aufzeichnung aktiv: Server nicht erreichbar"])
				{
					[aktTextField setObjectValue:@"Aufzeichnung aktiv"];
				}
				if([[data objectAtIndex:1] isEqualTo:@"1" ])
				{
					infoArray = [NSArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
						[self titleFilter:[data objectAtIndex:6]], @"title",
						[data objectAtIndex:0], @"listeners",
						[data objectAtIndex:4], @"uListeners",
						[NSDate date], @"time", nil]];
					[self willChangeValueForKey:@"titInfo"];
					[titInfo addObject:[infoArray objectAtIndex:0]];
					[self didChangeValueForKey:@"titInfo"];
					//HörerInnen TextFeld
					//		[listenerCountTextField setObjectValue:[[infoArray objectAtIndex:0] objectForKey:@"uListeners"]];
					//StatusBar
					/*	if(showStatBar)
					{
						[statBar changeItem:[listenerCountTextField objectValue]];
					}*/
					[self setListeners:[[infoArray objectAtIndex:0] objectForKey:@"uListeners"]];
				}else{
					
					NSLog(@"Stream offline");
				}
			}else{
				//möglicherweise URL falsch
				[aktTextField setObjectValue:@"Aufzeichnung inaktiv. URL moeglicherweise falsch."];
			}
		}else{
			[aktTextField setObjectValue:@"Aufzeichnung aktiv: Server nicht erreichbar"];
		}
	}
}
// ******************
- (void)windowWillClose:(NSNotification *)aNotification
{
	[self savePreferences];
}

- (void)dealloc
{
	[super dealloc];
}
@end
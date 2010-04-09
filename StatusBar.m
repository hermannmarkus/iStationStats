//iStationStats - Statistiken für Shoutcast-Streams
//
//Copyright (C) 2010 Markus Hermann
//
//This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
//
//  StatusBar.m
//  iRadioStats
//
//  Created by Markus Hermann on 16.01.09.
//

#import "StatusBar.h"


@implementation StatusBar

- (id)init
{
	return self;
}

- (void)setItem
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:42] retain];
}
- (void)removeItem
{
	[statusItem release];
}
- (void)changeItem:(NSString *)itemString
{
	[statusItem setImage:nil];
	[statusItem setAlternateImage:nil];
	[statusItem setLength:42];
	[statusItem setTitle:itemString];
}
- (void)setMenu:(NSMenu *)menu
{
	[statusItem popUpStatusItemMenu:menu];
	[statusItem setHighlightMode:YES];
}
- (void)setImage:(NSImage *)image withAltImage:(NSImage *)altImage
{
	[statusItem setLength:32];
	[statusItem setImage:image];
	[statusItem setAlternateImage:altImage];
}

@end

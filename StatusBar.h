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
//  StatusBar.h
//  iRadioStats
//
//  Created by Markus Hermann on 16.01.09.
//

#import <Cocoa/Cocoa.h>


@interface StatusBar : NSObject {
	NSStatusItem *statusItem;
}

- (void)setItem;
- (void)removeItem;
- (void)changeItem:(NSString *)itemString;
- (void)setMenu:(NSMenu *)menu;
- (void)setImage:(NSImage *)image withAltImage:(NSImage *)altImage;
@end

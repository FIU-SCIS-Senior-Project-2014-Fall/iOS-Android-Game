//
//  Tile.h
//  Mod10
//
//  Created by Lorenzo Castillo on 7/21/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "cocos2d.h"

@interface Tile : CCSprite
-(id) initAtLocation:(CGPoint)location withIndex:(int)i andValue:(int)val;
-(void) moveTo:(CGPoint)destination;
-(int*)getAdjacents;
-(BOOL) isAdjacentTo:(int)dx;
-(int) touchTileAndGetValue;
-(int) releaseTileAndGetValue;

@property (nonatomic,readwrite) int index;
@property (nonatomic,readwrite) int value;
@property (nonatomic, readwrite) BOOL isLocked;
@property (nonatomic, readwrite) int curRow;

@end

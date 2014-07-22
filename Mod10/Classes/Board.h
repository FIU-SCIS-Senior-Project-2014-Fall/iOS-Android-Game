//
//  Board.h
//  Mod10
//
//  Created by Lorenzo Castillo on 7/21/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "cocos2d.h"
#import "Tile.h"
@interface Board : CCSprite

@property (nonatomic,readwrite) int curCounter;

-(id) initAtLocation:(CGPoint)location andSpritesheet:(CCSpriteBatchNode*)s;
-(void) findIndex:(CGPoint)pt;
-(void) countTiles;
@end

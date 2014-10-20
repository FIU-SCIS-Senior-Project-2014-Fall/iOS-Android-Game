//
//  Board.h
//  Mod10
//
//  Created by Lorenzo Castillo on 7/21/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "cocos2d.h"
#import "Tile.h"
#import "Constants.h"
#import "Move.h"

@interface Board : CCSprite

@property (nonatomic,readwrite) int curCounter;
@property (nonatomic, readwrite) int score;
@property (nonatomic, readwrite) int movesLeft;
@property (nonatomic, readwrite) int timeLeft;
@property (nonatomic, readwrite) BOOL usesRandom;
@property (strong) Move * move;
@property (readwrite) BOOL isMyTurn;

-(id) initAtLocation:(CGPoint)location andSpritesheet:(CCSpriteBatchNode*)s;
-(void) findIndex:(CGPoint)pt;
-(BOOL) countTiles;
-(void)cleanUpBoard;
-(void) newGame;
-(void) selectTileAtIndex:(int)index;

@end

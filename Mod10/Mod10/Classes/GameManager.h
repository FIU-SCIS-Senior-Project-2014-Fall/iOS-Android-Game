//
//  GameManager.h
//  Mod10
//
//  Created by Lorenzo Castillo on 7/26/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"

@interface GameManager : NSObject

@property (readwrite,nonatomic) GameModes curMode;
@property (readwrite, nonatomic) int highScoreTimed;
@property (readwrite, nonatomic) int highScoreMoves;

+(GameManager*)sharedGameManager;
-(int) updateHighScore:(int)newScore;

@end

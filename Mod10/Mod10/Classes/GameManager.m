//
//  GameManager.m
//  Mod10
//
//  Created by Lorenzo Castillo on 7/26/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "GameManager.h"
#import "GameState.h"

@implementation GameManager

static GameManager* _sharedGameManager = nil;

+(GameManager*)sharedGameManager {
    @synchronized([GameManager class])                             // 2
    {
        if(!_sharedGameManager) {                                   // 3
            _sharedGameManager =  [[self alloc] init];
        }
        return _sharedGameManager;                                 // 4
    }
    return nil;
}

+(id)alloc
{
    @synchronized ([GameManager class])                            // 5
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocated a second instance of the Game Manager singleton");                                          // 6
        _sharedGameManager = [super alloc];
        return _sharedGameManager;                                 // 7
    }
    return nil;
}
-(void) saveGame{
    [[GameState sharedInstance] save];
}
-(int) updateHighScore:(int)newScore{
    
    int highScore = 0;
    switch (self.curMode) {
            
        case kMovesMode:
            highScore = self.highScoreMoves;
            if (newScore >= self.highScoreMoves){
                CCLOG(@"HIGH SCORE MOVES %i", newScore);
                self.highScoreMoves = newScore;

            }
            break;
        case kTimedMode:
            highScore = self.highScoreTimed;

            if (newScore >= self.highScoreTimed){
                CCLOG(@"HIGH SCORE TIMED %i", newScore);
                self.highScoreTimed = newScore;
                            }
            break;
        default:
            break;
    }
    [self saveGame];
    return  highScore;
}

-(id)init {
    self = [super init];
    if (self != nil) {
        // Game Manager initialized
        CCLOG(@"Game Manager Singleton, init");
        
        [GameState sharedInstance];
        
        self.curMode = kTimedMode;
        
    }
    return self;
}
@end

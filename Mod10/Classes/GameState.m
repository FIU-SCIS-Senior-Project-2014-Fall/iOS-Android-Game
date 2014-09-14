//
//  GameState.m
//  Mod10
//
//  Created by Lorenzo Castillo on 7/26/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "GameState.h"
#import "GameManager.h"
#import "GCDatabase.h"

@implementation GameState

static GameState *sharedInstance = nil;
+(GameState*)sharedInstance {
    @synchronized([GameState class])
    {
        if(!sharedInstance) {
            CCLOG(@"LOAD DATA");
            sharedInstance = loadData(@"GameState");
            if (!sharedInstance) {
                CCLOG(@"NOW INIT");
                sharedInstance = [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil;
}
+(id)alloc {
    @synchronized ([GameState class])
    {NSAssert(sharedInstance == nil, @"Attempted to allocate a \
              second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}
- (void)save {
    saveData(self, @"GameState");
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:[[GameManager sharedGameManager] highScoreMoves] forKey:@"highScoreMoves"];
    [encoder encodeInt:[[GameManager sharedGameManager] highScoreTimed] forKey:@"highScoreTimed"];
    
}
- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init])) {
        
        CCLOG(@"Encoder being init");
        
        [GameManager sharedGameManager].highScoreMoves =[decoder decodeIntForKey:@"highScoreMoves"];
        [GameManager sharedGameManager].highScoreTimed = [decoder decodeIntForKey:@"highScoreTimed"];
        
        CCLOG(@"Current high score for MOVES is: %i", [[GameManager sharedGameManager] highScoreMoves]);
        CCLOG(@"Current high score for TIMED is: %i", [[GameManager sharedGameManager] highScoreTimed]);
        
    }
    return self;
}
@end

//
//  Match.h
//  Mod10
//
//  Created by Lorenzo Castillo on 10/5/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Board.h"

typedef enum {
    MatchStateActive = 0,
    MatchStateGameOver
} MatchState;

@interface Match : NSObject

@property  MatchState state;
@property (strong) NSArray *players;
@property (strong) Board *board;
@property (readwrite) int turn;

- (id)initWithState:(MatchState)state players:(NSArray*)players;
-(void)updateTurn;

@end

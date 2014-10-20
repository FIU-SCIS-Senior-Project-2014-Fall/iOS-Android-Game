//
//  Match.m
//  Mod10
//
//  Created by Lorenzo Castillo on 10/5/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import "Match.h"
#import "Player.h"

@implementation Match

-(void)updateTurn{
    self.turn = (self.turn + 1)%2;
}

- (id)initWithState:(MatchState)state players:(NSArray*)players
{
    if ((self = [super init])) {
        self.state = state;
        self.players = [players copy];
        self.turn = 0;
        CCLOG(@"INIT MATCH");
        for (Player * p in players){
            
            CCLOG(@"%@",p.playerId);
            
        }
    }
    return self;
}


@end

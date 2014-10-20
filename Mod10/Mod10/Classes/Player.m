//
//  Player.m
//  Mod10
//
//  Created by Lorenzo Castillo on 10/5/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import "Player.h"


@implementation Player


- (id)initWithPlayerId:(NSString*)playerId alias:(NSString*)alias
{
    if ((self = [super init])) {
        self.playerId = [playerId copy];
        self.alias = [alias copy];

    }
    return self;
}

@end

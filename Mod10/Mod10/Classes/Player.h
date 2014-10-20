//
//  Player.h
//  Mod10
//
//  Created by Lorenzo Castillo on 10/5/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : NSObject

@property (strong) NSString *playerId;
@property (strong) NSString *alias;

- (id)initWithPlayerId:(NSString*)playerId alias:(NSString*)alias;

@end

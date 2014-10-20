//
//  MultiplayerScene.h
//  Mod10
//
//  Created by Lorenzo Castillo on 10/5/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "Match.h"
#import "NetworkController.h"

@interface MultiplayerScene : CCScene <NetworkControllerDelegate>

@property (strong) Match *match;

+ (MultiplayerScene *)scene;
- (id)init;
@end

//
//  MainMenuScene.m
//  Mod10
//
//  Created by Lorenzo Castillo on 9/28/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import "MainMenuScene.h"
#import "AppDelegate.h"
#import "NetworkController.h"

@implementation MainMenuScene


+ (MainMenuScene *)scene
{
    
    return [[self alloc] init];
}
- (void)stateChanged:(NetworkState)state {
}
- (void)setNotInMatch {
    CCAppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [[NetworkController sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.navController];
}

- (id)init
{
    
    self = [super init];
    if (!self) return(nil);
    
    [NetworkController sharedInstance].delegate = self;
    [self stateChanged:[NetworkController sharedInstance].state];
    
    return self;
    
}
@end

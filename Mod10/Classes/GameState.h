//
//  GameState.h
//  Mod10
//
//  Created by Lorenzo Castillo on 7/26/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject <NSCoding>
+ (GameState *) sharedInstance;
- (void)save;

@end

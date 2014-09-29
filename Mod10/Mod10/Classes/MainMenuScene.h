//
//  MainMenuScene.h
//  Mod10
//
//  Created by Lorenzo Castillo on 9/28/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NetworkController.h"

@interface MainMenuScene : CCScene <NetworkControllerDelegate>{
    
}
+ (MainMenuScene *)scene;
-(id) init;
@end

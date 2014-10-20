//
//  Move.h
//  Mod10
//
//  Created by Lorenzo Castillo on 10/6/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Move : NSObject {
    
}

@property (strong) NSMutableArray * indices;
@property (strong) NSMutableArray * tileVals;
@property (readwrite) int score;

-(instancetype) init;
-(void) cleanup;

@end

//
//  Move.m
//  Mod10
//
//  Created by Lorenzo Castillo on 10/6/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import "Move.h"


@implementation Move


-(void)cleanup{
    
    self.score = 0;
    [self.indices removeAllObjects];
    [self.tileVals removeAllObjects];
    
}

-(instancetype) init{
    
    self = [super init];
    if (!self) return(nil);
    
    
    self.tileVals = [NSMutableArray array];
    self.indices = [NSMutableArray array];
    self.score = 0;
    
    return self;
}

@end

//
//  Tile.m
//  Mod10
//
//  Created by Lorenzo Castillo on 7/21/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "Tile.h"

#define SCREEN_WIDTH 640
#define SPEED_FACTOR 1000

@implementation Tile{
   int adjacents[4]; //top, bottom, right, left
}

-(int) touchTileAndGetValue{

    if ([self numberOfRunningActions] == 0){
    CCActionScaleTo * scaleUp = [CCActionScaleTo actionWithDuration:0.1 scale:1.2];
    CCActionScaleTo * scaleDown = [CCActionScaleTo actionWithDuration:0.2 scale:1.1];
    CCActionSequence *sequence = [CCActionSequence actionOne:scaleUp two:scaleDown];
    [self runAction:sequence];
    }
    return self.value;
}

-(int) releaseTileAndGetValue{
    [self stopAllActions];
    self.scale = 1.0;
    return self.value;
}

-(BOOL) isAdjacentTo:(int)dx{
    for (int i = 0; i < 4; i++) {
        if (adjacents[i] == dx){
            return true;
        }
    }
    return false;
}
-(int*)getAdjacents{
    return adjacents;
}
-(void)setAdjacents{
    int top = (((self.index + 5) < (5 * 5 )) ? (self.index + 5) : - 1);
    int bottom = ((self.index - 5) >= 0) ? (self.index - 5) : -1;
    int right = ((self.index + 1) < 5 * (self.curRow + 1)) ? (self.index + 1) : -1;
    int left = ((self.index - 1) >= (5 * self.curRow)) ? (self.index - 1) : -1;
    //CCLOG(@"curRow %i curIndex %i",self.curRow, self.index);
    
    adjacents[0] = top;
    adjacents[1] = bottom;
    adjacents[2] = right;
    adjacents[3] = left;
    
}

-(void)lockTile{
    self.isLocked = false;
}
-(void) moveTo:(CGPoint)destination{
    
    if (self.isLocked)
        return;
    
    [self setAdjacents];
    
    float distance = ccpDistanceSQ(destination, self.position);
    
    //try to give a uniform speed for all times
    float time = distance/(SCREEN_WIDTH*SPEED_FACTOR);
    if (time < 0.1)
        time = 0.1; //Make sure that it's not too fast so it doesnt teleport
    
    self.isLocked = true;
    
    CCActionMoveTo *actionMove = [CCActionSequence actionOne:[CCActionMoveTo actionWithDuration:time position:destination] two: [CCActionCallFunc actionWithTarget:self selector:@selector(lockTile)]];
    
    [self runAction:actionMove];

}
-(void) setTileNumber{
    
    if (self.value >= 0 && self.value <10){
        [self setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"Tile%i.png",self.value]]];
    }
    else{
        CCLOG(@"ERROR, no such tile found");
    }
}

-(id) initAtLocation:(CGPoint)location withIndex:(int)i andValue:(int)val
{
    if( (self=[super init]) )
    {
        self.value = val;
        self.index = i;
        self.isLocked = false;
        [self setTileNumber ];
        CCLOG(@"INITVAL: %i, INDEX: %i",self.value, self.index);
        self.position=location;

        for (int i = 0; i < 4; i++)
            adjacents[i] = -1;

    }
    return self;
}

@end

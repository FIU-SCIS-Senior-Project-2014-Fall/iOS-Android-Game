//
//  Tile.m
//  Mod10
//
//  Created by Lorenzo Castillo on 7/21/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "Tile.h"

#define SCREEN_WIDTH 640
#define SPEED_FACTOR 10

@implementation Tile{
    int adjacents[4]; //top, bottom, right, left
    int zValues[25];
}

- (int)getRandomNumberBetween:(int)min maxNumber:(int)max
{
    return min + arc4random() % (max - min + 1);
}

-(int) touchTileAndGetValue{
    
    
    [self setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"Tile%i-touched.png",self.value]]];
    
    
    [self setIsTouched:true];
    return self.value;
}

-(int) releaseTileAndGetValue{
    [self setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"Tile%i.png",self.value]]];
    [self setIsTouched: false ];
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
    
    
    
    //    if (self.isLocked)
    //        return;
    
    [self setAdjacents];
    
    
    CCLOG(@"DEST %f POS %f", destination.y, self.position.y);
    float distance = ccpDistance(destination, self.position);
    
    
    
    float time = (SCREEN_WIDTH / distance) * 0.5 ;
    
    if (time < 0.1 || distance < SCREEN_WIDTH)
        time = 0.1; //Make sure that it's not too fast so it doesnt teleport
    
    
    self.isLocked = true;
    
    CCLOG(@"MoveTo: VALUE: %i INDEX: %i with time: %f distance %f",self.value, self.index, time,distance);
    
    [self setZOrder:  zValues[self.index]];
    
    CCActionMoveTo *actionMove = [CCActionSequence actionOne:[CCActionMoveTo actionWithDuration:time position:destination] two: [CCActionCallFunc actionWithTarget:self selector:@selector(lockTile)]];
    
    [self runAction:actionMove];
    
}

-(void) setTileNumber{
    
    self.value = [self getRandomNumberBetween:1 maxNumber:9];
    
    if (self.value >= 0 && self.value <10){
        
        [self setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"Tile%i.png",self.value]]];
    }
    else{
        CCLOG(@"ERROR, no such tile found");
    }
}
- (void) deleteTile{
    CCActionScaleTo * scale = [CCActionScaleTo actionWithDuration:0.10 scale:0];
    
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:.5 position:ccp(self.position.x  - 1000,self.position.y)];
    CCActionSequence *sequence = [CCActionSequence actionOne:scale two:[CCActionCallFunc actionWithTarget:self selector:@selector(removeFromParent)]];
    
    
    [self runAction:sequence];
    
    //[self removeFromParentAndCleanup:TRUE];
}
-(id) initAtLocation:(CGPoint)location withIndex:(int)i
{
    if( (self=[super init]) )
    {
        
        self.index = i;
        self.isLocked = false;
        self.isTouched = false;
        
        [self setTileNumber ];
        
        CCLOG(@"INITVAL: %i, INDEX: %i",self.value, self.index);
        self.position=location;
        
        for (int i = 0; i < 4; i++)
            adjacents[i] = -1;
        
        //int zValues [25] = {20,21,22,23,24,15,16,17,18,19,10,11,12,13,14,5,6,7,8,9,0,1,2,3,4};
        
        int k = 0;
        for (int j = 20; j >= 0; j-=5)
            for (int i = 0; i < 5; i ++){
                zValues[k++] = j + i;
            }
        
        
    }
    return self;
}

@end

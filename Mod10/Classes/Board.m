//
//  Board.m
//  Mod10
//
//  Created by Lorenzo Castillo on 7/21/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "Board.h"
#define TILE_SIZE 64
#define ROWS 5
#define COLUMNS 5
#define LOW_BOUND 100
#define SPAWNHEIGHT 1200 //height the tiles should appear when they are created


/*
 The board's indexes are as follows:
 
     C0          C4
    ----------------
 R4| 20 21 22 23 24
   | 15 16 17 18 19
   | 10 11 12 13 14
   | 05 06 07 08 09
 R0| 00 01 02 03 04
    ----------------
 
 */
@implementation Board{

    Tile *tiles[25];
    CCSpriteBatchNode *spritesheet;
    BOOL fillingBoard;
    int curIndex;
    int stack[25], stackPtr;

}
- (NSInteger)getRandomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random() % (max - min + 1);
}

/**
 Determines the y coordinate for a particular row
 */
-(float) getYForRow:(int)row{
    return LOW_BOUND+TILE_SIZE/2 + (TILE_SIZE * row);
}

/**
 Determines the x coordinate for a particular column
 */
-(float) getXForColumn:(int)column{
    return TILE_SIZE/2 + (TILE_SIZE * column);
}


/*
 STACK METHODS
 Methods that handle the stack that we use to track the
 tiles that we have currently selected
 
 */
-(void) pushIndex:(int)i{
    stack[++stackPtr] = i;
}
-(int) popIndex{
    if (stackPtr == -1)
        return -1;
    return stack[stackPtr--];
}
-(int) getLastIndex{
    if (stackPtr < 0 )
        return -1;
    return stack[stackPtr-1];
}


/**
 Creates a tile at a column and with a particular target index
 */
-(void) createTileAtColumn:(int)column andIndex:(int)index{
    
    
    int randomNum = (int) [self getRandomNumberBetween:1 maxNumber:9];
    
    Tile * newTile = [[Tile alloc] initAtLocation:ccp([self getXForColumn:column],SPAWNHEIGHT * (1+(index-column)%COLUMNS)) withIndex:index andValue:randomNum];
    tiles[index] = newTile;
    [spritesheet addChild:newTile];
    
}

/*
 Fills a column of the board.
 
 Algorithm:
 Start from the bottom row and work way up the column.
Look for non-empty tiles and send them down. When you 
 reach the top row, and if it is empty, create a new tile 
 and send it down.
 */
-(void) fillColumn:(int) column{
    
    for (int j = 0 ; j < ROWS; j++){
        
        int index = column+(j*(COLUMNS)); //WHERE THE TILES SHOULD MOVE TO  
        
        if (!tiles[index]){
            for (int k = j; k< ROWS; k++){
                if (tiles[column + (k*(COLUMNS))]){
                    CCLOG(@"A goto: %i",index);

                    
                    tiles[index] = tiles[column + (k*(COLUMNS))];
                    tiles[index].index = index;
                    
                    [tiles[index] setPosition:ccp([self getXForColumn:column],tiles[index].position.y)];
                    
                    if (tiles[index].isLocked){
                        [tiles[index] stopAllActions];
                        [tiles[index] setIsLocked:false];
                    }
                    [tiles[index] setCurRow:j];
                    
                    [tiles[index] moveTo:ccp(tiles[index].position.x,[self getYForRow:j])];

                    tiles[column + (k*(COLUMNS))] = NULL;
                    
                    break;
                }
                if (k == ROWS-1){ //When the top row is empty
                    CCLOG(@"B");

                    [self createTileAtColumn:column andIndex:index];
                    
                    [tiles[index] setCurRow:j];
                    
                    [tiles[index]moveTo:ccp(tiles[index].position.x,[self getYForRow:j])];

                }
            }
            
        }
    }
    
}

/**
 Starts the process of filling out the board, 
 column by column
 */
-(void)fillBoard{
    if (fillingBoard)
        return;
    
    fillingBoard=true;
    
    for (int i = 0; i < COLUMNS; i ++){
        [self fillColumn:i ];
    }
    
    fillingBoard=false;
}


/**
 Figures out which column is being touched based on an x coordinate
 */
-(int) findColumn:(float)x{
    
    if ( x <= TILE_SIZE*1){
        return 0;
    }
    else if (x > TILE_SIZE*1 && x <= TILE_SIZE*2){
        return 1;
    }
    else if (x > TILE_SIZE*2 && x <= TILE_SIZE*3){
        return 2;
    }
    else if (x > TILE_SIZE*3 && x <= TILE_SIZE*4){
        return 3;
    }
    else if (x > TILE_SIZE*4 && x <= TILE_SIZE*5){
        return 4;
    }
    return -1;
}

/**
 Figures out which row is being touched based on an y coordinate
 LOW_BOUND is the point in which the lowest tile touches. Increasing the
 LOW_BOUND will result in the board being higher on the screen.
 */
-(int) findRow:(float)y{
    
    float startPoint = LOW_BOUND;
    
    if (y > startPoint && y <= startPoint + TILE_SIZE*1){
        return 0;
    }
    else if (y > startPoint + TILE_SIZE*1 && y <= startPoint + TILE_SIZE*2){
        return 1;
    }
    else if (y > startPoint + TILE_SIZE*2 && y <= startPoint + TILE_SIZE*3){
        return 2;
    }
    else if (y > startPoint + TILE_SIZE*3 && y <= startPoint + TILE_SIZE*4){
        return 3;
    }
    else if (y > startPoint + TILE_SIZE*4 && y <= startPoint + TILE_SIZE*5){
        return 4;
    }
    return -1;
    
}



-(BOOL) validateRows:(int) row columns:(int)column andIndex:(int)index{
    
    BOOL rowsCheck = row >= 0 && row < ROWS;
    BOOL colsCheck = column >= 0 && column < COLUMNS;
    BOOL indexCheck = index >= 0 && index < ROWS * COLUMNS;
    
    return rowsCheck && colsCheck && indexCheck;
}
/**
 
 Based on @pt, we figure out which tile is being touched.
 We decide if this is an eligible tile by checking if it is adjacent
 to the previous tile that was touched. We push/pop things from the
 stack of indexes. 
 
 */
-(void) findIndex:(CGPoint)pt{
    
    int row = [self findRow:pt.y];
    
    int column = [self findColumn:pt.x];
    
    int index = column + (row*(COLUMNS));
    
    //CCLOG(@"ROW: %i,COL: %i",row,column);
    
    BOOL validVals = [self validateRows:row columns:column andIndex:index];
    
    if (validVals && !tiles[index].isLocked && !fillingBoard){
        
        if (curIndex == -1 || [tiles[index]isAdjacentTo:curIndex]) {
            CCLOG(@"VALUE: %i, INDEX: %i",tiles[index].value, index);
            
            if (index == [self getLastIndex]){ //Checks to see if you went to the previous selected tile
                CCLOG(@"POP");
                int res = [self popIndex];
                
                if (res != -1){

                    self.curCounter -= [tiles[curIndex] releaseTileAndGetValue];
                    
                    curIndex = stack[stackPtr];
                }
                else{
                    CCLOG(@"POP INDEX: -1");
                    curIndex = -1;
                }
                
            }
            else{
                CCLOG(@"PUSH");
                self.curCounter = (self.curCounter + [tiles[index] touchTileAndGetValue]);
                curIndex = index;
                [self pushIndex:index];
                
            }
            
            
        }
    }
}


/**
 Called when a user lifts up his/her finger
 Should do basic clean-up, and remove the tiles
 if the curCounter%10 == 0;
 
 */
-(void) countTiles{
    
    CCLOG(@"self.curCounter: %i", self.curCounter);
    if (self.curCounter%10 == 0 ){
        int i = [self popIndex];
        while (i != -1) {
            CCLOG(@"INDEX TO BE REMOVED: %i",i);
            [tiles[i] removeFromParentAndCleanup:TRUE];
            tiles[i] = NULL;
            i = [self popIndex];
        }
        
    }
    
    [self fillBoard];
    
    self.curCounter = 0;
    curIndex = -1;
    

    
    for (int i = 0; i <= stackPtr; i++){
        if (tiles[stack[i]])
            [tiles[stack[i]] releaseTileAndGetValue];
        stack[i] = -1;
    }
    stackPtr = -1;
    
}

-(id) initAtLocation:(CGPoint)location andSpritesheet:(CCSpriteBatchNode*)s
{
    if( (self=[super init]) )
    {
        spritesheet = s;
        self.position=location;
        fillingBoard = false;
        curIndex = -1;
        stackPtr = -1;
        
        for (int i = 0; i < 25; i++)
            stack[i] = -1;
        
        [self fillBoard];
        
    }
    return self;
}

@end

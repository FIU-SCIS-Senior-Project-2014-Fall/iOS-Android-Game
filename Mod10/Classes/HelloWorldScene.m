//
//  HelloWorldScene.m
//  Mod10
//
//  Created by Lorenzo Castillo on 7/21/14.
//  Copyright Lorenzo Castillo 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "Tile.h"
#import "Board.h"
#import "GameManager.h"
#import "Constants.h"
// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_sprite;
    Board *board;
    CCLabelTTF *counterLabel, *scoreLabel, *timeLabel,*moveLabel;
    CCSpriteBatchNode * gameSpriteBatchNode;
    BOOL isGameOver;
    CCProgressNode * clock;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

-(void) countdown{
    CCLOG(@"Countdown %i",board.timeLeft);
    board.timeLeft -= 1;
}

-(void) updateHUD{
    
    switch ([[GameManager sharedGameManager] curMode]) {
        case kMovesMode:
            [moveLabel setString:[NSString stringWithFormat:@"%i",[board movesLeft]]];
            [clock setPercentage: ((float)[board movesLeft] / MAX_MOVES)*100];
            break;
        case kTimedMode:
            [timeLabel setString:[NSString stringWithFormat:@"%i",[board timeLeft]]];
            [clock setPercentage: ((float)[board timeLeft] / MAX_TIME)*100];
            break;
        default:
            break;
    }
    
}

-(void) checkGameOver{
    if (([board timeLeft]   == 0 && [[GameManager sharedGameManager] curMode] == kTimedMode)||
        ([board movesLeft]  == 0 && [[GameManager sharedGameManager] curMode] == kMovesMode)){
        
        isGameOver = true;
        
        CCLOG(@"GameOver");
        [self unscheduleAllSelectors];
        [[GameManager sharedGameManager] updateHighScore:[board score]];
        
    }
}

-(void) update:(CCTime)delta {
    
    if (isGameOver)
        return;
    [self updateHUD];
    [self checkGameOver];
}

-(void) setupHUD{
    
    CGPoint pos = ccp(self.contentSize.width*.5,self.contentSize.height*.85);
    
    CCSprite *HUD = [[CCSprite alloc] initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"clock-score.png"]];
    [gameSpriteBatchNode addChild:HUD z:100];
    [HUD setPosition:pos];
    
    
    clock = [[CCProgressNode alloc] initWithSprite:[CCSprite spriteWithImageNamed:@"clock-meter.png"]];
    [clock setType:CCProgressNodeTypeRadial];
    [clock setPercentage:100];
    [clock setReverseDirection:true];
    [clock setPosition:pos];
    [self addChild:clock z:10000];
    
    scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Verdana-Bold" fontSize:48];
    [scoreLabel setColor:[CCColor colorWithCcColor3b:ccc3(241, 198, 19)]];
    [self addChild:scoreLabel z:1000];
    //scoreLabel.anchorPoint = ccp(scoreLabel.anchorPoint.x,0);
    [scoreLabel setPosition:ccp(pos.x,pos.y + HUD.contentSize.height*0.1)];
    
    if ([[GameManager sharedGameManager] curMode] == kTimedMode){
        
        [self schedule:@selector(countdown) interval:1.0];//Start the countdown
        
        timeLabel = [CCLabelTTF labelWithString:@"Time: 10" fontName:@"Verdana-Bold" fontSize:24];
        
        [timeLabel setColor:[CCColor colorWithCcColor3b:ccc3(241, 198, 19)]];
        [self addChild:timeLabel z:1000];
        [timeLabel setPosition:ccp(self.contentSize.width*.2,self.contentSize.height*.85)];
    }
    else if ([[GameManager sharedGameManager] curMode] == kMovesMode){
        moveLabel = [CCLabelTTF labelWithString:@"Moves: 30" fontName:@"Verdana-Bold" fontSize:24];
        [moveLabel setColor:[CCColor colorWithCcColor3b:ccc3(241, 198, 19)]];
        [self addChild:moveLabel z:1000];
        [moveLabel setPosition:ccp(self.contentSize.width*.2,self.contentSize.height*.85)];
    }
    
}
- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Create a colored background
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    [self addChild:background z: -100];
//
    
//    // Create a back button
//    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
//    backButton.positionType = CCPositionTypeNormalized;
//    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
//    [backButton setTarget:self selector:@selector(onBackClicked:)];
//    [self addChild:backButton];
    
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"TileSpritesheet.plist"];
    gameSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"TileSpritesheet.png"];
    
    [self addChild:gameSpriteBatchNode z:100];
    
    board = [[Board alloc] initAtLocation:ccp(self.contentSize.width/2,self.contentSize.height*0.4) andSpritesheet:gameSpriteBatchNode];
    [gameSpriteBatchNode addChild:board z: -1000];
    
    
    [self setupHUD];
    
    

    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInteractionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (isGameOver)
        return;
    
    CGPoint touchLoc = [touch locationInNode:self];
    [board findIndex:touchLoc];
    [counterLabel setString:[NSString stringWithFormat:@"Counter: %i",board.curCounter%10]];
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (isGameOver)
        return;
    
    CGPoint touchLoc = [touch locationInNode:self];
    [board findIndex:touchLoc];
    [counterLabel setString:[NSString stringWithFormat:@"Counter: %i",board.curCounter%10]];
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (isGameOver)
        return;
    [board countTiles];
    [counterLabel setString:[NSString stringWithFormat:@"Counter: %i",board.curCounter%10]];
    [scoreLabel setString:[NSString stringWithFormat:@"%i",board.score]];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
//    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
//                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
@end

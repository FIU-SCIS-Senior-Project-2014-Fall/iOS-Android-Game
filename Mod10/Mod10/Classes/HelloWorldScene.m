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
    CCSprite *highScore;
    Board *board;
    CCLabelTTF *counterLabel, *scoreLabel, *timeLabel,*moveLabel, *gameoverLabel;
    CCSpriteBatchNode * gameSpriteBatchNode;
    BOOL isGameOver;
    CCProgressNode * clock;
    SceneStates sceneState;
    CCProgressNode *gameoverMeter;
    int tempScore;
}

+ (HelloWorldScene *)scene
{

    return [[self alloc] init];
}


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
        //[self unscheduleAllSelectors];

        
    }
}

- (void) countScore{
    
    if ([board score] == 0) {
        [self unschedule:@selector(countScore)];
        return;
    }
    
    [gameoverLabel setString:[NSString stringWithFormat:@"%i",++tempScore]];
    
    int bestScore = [[GameManager sharedGameManager] updateHighScore:0];
    if (bestScore < 1)
        bestScore = 1;
    
    [gameoverMeter setPercentage:((float)tempScore/bestScore) * 100];
    
    if (tempScore > [[GameManager sharedGameManager] highScoreMoves]){
        CCLOG(@"YOU GOT A HIGH SCORE!!");
        [highScore setVisible:true];

    }
    
    if (tempScore == [board score]){
        CCLOG(@"UNSCHED COUNTSCORE");
        [[GameManager sharedGameManager] updateHighScore:[board score]];
        [self unschedule:@selector(countScore)];
        tempScore = 0;
        
    }
    
}
- (void) handleGameOver{
    CCLOG(@"HANDLING GAME OVER");
    sceneState = kGameOverScene;
    isGameOver = false;
    
    [board cleanUpBoard];
    
    [gameoverLabel setString:@"0"];
    
    tempScore = 0;
    
    [self schedule:@selector(countScore) interval:0.05];
    

}
-(void) update:(CCTime)delta {
    
    if (isGameOver && sceneState != kChangingScenes){
        CCLOG(@"Game OVer");
        sceneState = kChangingScenes;
        CCActionSequence *sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:0.5],[CCActionMoveTo actionWithDuration:0.25 position:ccp(-self.contentSize.width,self.position.y)],[CCActionCallFunc actionWithTarget:self selector:@selector(handleGameOver)], nil];
        [self runAction:sequence];
        return;
    }
    else if (sceneState == kGameLayerScene){
        [self updateHUD];
        [self checkGameOver];
    }
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
- (void) startGame{
    sceneState = kGameLayerScene;
    [board newGame];
    [highScore setVisible:false];
    [gameoverMeter setPercentage:0];
    [gameoverLabel setString:@"0"];
}
- (void) playAgainButton:(id)sender{
    CCLOG(@"PLAY AGAIN");
    if (sceneState == kChangingScenes)
        return;
    
    [board setScore:0];
    [scoreLabel setString:@"0"];
    
    sceneState = kChangingScenes;
    
    CCActionSequence *sequence = [CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.25 position:ccp(0,self.position.y)],[CCActionCallFunc actionWithTarget:self selector:@selector(startGame)], nil];
    [self runAction:sequence];
    [self setupGameLayer];

    
    

}
- (void) menuButton:(id)sender{
    CCLOG(@"MENU BUTTON");
    
}
- (void) setupGameOver{
    
    CGPoint firstPoint = ccp(self.contentSize.width*1.5, self.contentSize.height*.1);
    

    
    
    CCButton *playAgain = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"playagain-button.png"]];
    [playAgain setTarget:self selector:@selector(playAgainButton:)];
    [playAgain setPosition:firstPoint];
    [self addChild:playAgain];
    
    CCButton *menu = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"menu-button.png"]];
    [menu setTarget:self selector:@selector(menuButton:)];
    [menu setPosition:ccp(firstPoint.x,firstPoint.y + menu.contentSize.height*1.25)];
    [self addChild:menu];
    
    
    CGPoint pos = ccp(self.contentSize.width*1.5,self.contentSize.height*.65);
    
    
    CCSprite *HUD = [[CCSprite alloc] initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"clock-gameover.png"]];
    [gameSpriteBatchNode addChild:HUD z:100];
    [HUD setPosition:pos];
    
    highScore = [[CCSprite alloc] initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"highscore.png"] ];
    [gameSpriteBatchNode addChild:highScore];
    [highScore setPosition:ccp(pos.x,pos.y + highScore.contentSize.height*2)];
    [highScore setVisible:false];
    
    gameoverMeter = [[CCProgressNode alloc] initWithSprite:[CCSprite spriteWithImageNamed:@"gameover-meter.png"]];
    [gameoverMeter setType:CCProgressNodeTypeRadial];
    [gameoverMeter setPercentage:0];
    [gameoverMeter setReverseDirection:true];
    [gameoverMeter setPosition:pos];
    [self addChild:gameoverMeter z:10000];
    
    gameoverLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Verdana-Bold" fontSize:60];
    [gameoverLabel setColor:[CCColor colorWithCcColor3b:ccc3(241, 198, 19)]];
    [self addChild:gameoverLabel z:1000];
    [gameoverLabel setPosition:ccp(pos.x,pos.y + HUD.contentSize.height*0.1)];

    
}
-(void) setupGameLayer{

    board = [[Board alloc] initAtLocation:ccp(self.contentSize.width/2,self.contentSize.height*0.4) andSpritesheet:gameSpriteBatchNode];
    [gameSpriteBatchNode addChild:board z: -1000];

}
- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);

    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"TileSpritesheet.plist"];
    gameSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"TileSpritesheet.png"];
    
    [self addChild:gameSpriteBatchNode z:100];
    

    [self setupGameOver];
    
    sceneState = kGameLayerScene;
    
    [self setupGameLayer];
    
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
    self.color = [CCColor whiteColor];
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

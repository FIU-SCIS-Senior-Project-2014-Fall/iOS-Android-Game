//
//  MultiplayerScene.m
//  Mod10
//
//  Created by Lorenzo Castillo on 10/5/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import "MultiplayerScene.h"
#import "Board.h"
#import "Player.h"
#import "AppDelegate.h"

@implementation MultiplayerScene{
    CCSprite *highScore;
    Board *board;
    CCLabelTTF *counterLabel, *scoreLabel, *timeLabel,*moveLabel, *gameoverLabel,*scoreLabel2,*turnLabel;
    CCSpriteBatchNode * gameSpriteBatchNode;
    BOOL isGameOver;
    CCProgressNode * clock;
    SceneStates sceneState;
    CCProgressNode *gameoverMeter;
    int tempScore;
    
    CCLabelBMFont *player1Label;
    CCLabelBMFont *player2Label;
    Player *player1, *player2;
    BOOL isPlayer1;
    int player2Score;
}

+ (MultiplayerScene *)scene
{
    
    return [[self alloc] init];
}

- (void)stateChanged:(NetworkState)state {
}
- (void)setNotInMatch {
    
    CCAppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    [[NetworkController sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.navController];
}

// Replace update with the following
- (void)update:(CCTime)delta {

}

-(void)sendMove{
    CCLOG(@"Sending move: ");
    
    [self.match updateTurn];
    [self setTurnLabel];
    
    [[NetworkController sharedInstance] sendMove:board.move];
    CCLOG(@"Score: %i, Num Indices: %lu, Num of tile vals: %lu",board.move.score,(unsigned long)board.move.indices.count,(unsigned long)board.move.tileVals.count);
    [board.move cleanup];
    
}

// Add before dealloc
-(void)setTurnLabel{
    if ([self isMyTurn]){

        [turnLabel setString:@"YOUR TURN"];
    }
    else{

        [turnLabel setString:@"OPPONENT'S TURN"];
    }
}
- (void)matchStarted:(Match *)theMatch andArr:(NSArray * ) tileVals{
    
    self.match = theMatch;
    
    Player *p1 = [self.match.players objectAtIndex:0];
    Player *p2 = [self.match.players objectAtIndex:1];
    
    if ([p1.playerId compare:[GKLocalPlayer localPlayer].playerID] == NSOrderedSame) {
        isPlayer1 = YES;
    } else {
        isPlayer1 = NO;
    }
    
    board.move.tileVals = [tileVals mutableCopy];
    
    [board newGame];
    [self setTurnLabel];
    self.match.board = board;
    
    
    
//    player1.position = ccp(p1.posX, player1.position.y);
//    player2.position = ccp(p2.posX, player2.position.y);
//    player1.moveTarget = player1.position;
//    player2.moveTarget = player2.position;
    
//    if (player1Label) {
//        [player1Label removeFromParentAndCleanup:YES];
//        player1Label = nil;
//    }
//    player1Label = [CCLabelBMFont labelWithString:p1.alias fntFile:@"Arial.fnt"];
//    [self addChild:player1Label];
//    
//    if (player2Label) {
//        [player2Label removeFromParentAndCleanup:YES];
//        player2Label = nil;
//    }
//    player2Label = [CCLabelBMFont labelWithString:p2.alias fntFile:@"Arial.fnt"];
//    [self addChild:player2Label];
}

- (void)player:(unsigned char)playerIndex moved:(Move*)move{
    
    CCLOG(@"Finalizing the move: %i",playerIndex);
    
    Player * p = ((Player*)[self.match.players objectAtIndex:playerIndex]);
    
    CCLOG(@"%@",p.playerId);
    
    player2Score += move.score;
    [scoreLabel2 setString:[NSString stringWithFormat:@"Other Score: %i",move.score]];
    
    board.usesRandom = false;
    board.move.tileVals = [move.tileVals mutableCopy];
    for (NSNumber * num in move.indices){
        CCLOG(@"%i",[num intValue]);
        [board selectTileAtIndex:[num intValue]];
    }
    [board countTiles];
    
    [board.move cleanup];
    
    [self.match updateTurn];
    [self setTurnLabel];
    
}
-(void) setupHUD{
    
    CGPoint pos = ccp(self.contentSize.width*.5,self.contentSize.height*.9);
    scoreLabel = [CCLabelTTF labelWithString:@"My Score: 0" fontName:@"Verdana-Bold" fontSize:24];
    [scoreLabel setColor:[CCColor colorWithCcColor3b:ccRED]];
    [self addChild:scoreLabel z:1000];
    [scoreLabel setPosition:ccp(pos.x,pos.y)];
    
    scoreLabel2 = [CCLabelTTF labelWithString:@"Other Score: 0" fontName:@"Verdana-Bold" fontSize:24];
    [scoreLabel2 setColor:[CCColor colorWithCcColor3b:ccBLUE]];
    [self addChild:scoreLabel2 z:1000];
    [scoreLabel2 setPosition:ccp(pos.x,pos.y*.9)];
    
    
    turnLabel = [CCLabelTTF labelWithString:@"turn" fontName:@"Verdana-Bold" fontSize:24];
    [turnLabel setColor:[CCColor colorWithCcColor3b:ccBLACK]];
    [self addChild:turnLabel z:1000];
    [turnLabel setPosition:ccp(pos.x,pos.y*.8)];
    
}
-(void) setupGameLayer{
    
    board = [[Board alloc] initAtLocation:ccp(self.contentSize.width/2,self.contentSize.height*0.4) andSpritesheet:gameSpriteBatchNode];
    [gameSpriteBatchNode addChild:board z: -1000];
    board.usesRandom = false;
    player2Score = 0;
    
    
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
    
    
    
    [NetworkController sharedInstance].delegate = self;
    [self stateChanged:[NetworkController sharedInstance].state];
    
    
    
    ///[self setupGameOver];
    
    //sceneState = kGameLayerScene;
    
    [self setupGameLayer];
    
    [self setupHUD];

    
    
    return self;
}
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


#pragma mark - Touch Handler
// -----------------------------------------------------------------------
-(BOOL) isMyTurn{
    
    return (isPlayer1 && self.match.turn == 0) || (!isPlayer1 && self.match.turn == 1);
    
}
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
 

    if (self.match == nil || self.match.state != MatchStateActive) return;
    
    //[[NetworkController sharedInstance] sendMovedSelf:4];
    
    if (isGameOver)
        return;
    
    if ([self isMyTurn]){
        CGPoint touchLoc = [touch locationInNode:self];
        [board findIndex:touchLoc];
    }

//    [counterLabel setString:[NSString stringWithFormat:@"Counter: %i",board.curCounter%10]];
    
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (isGameOver)
        return;
    
    if ([self isMyTurn]){
        CGPoint touchLoc = [touch locationInNode:self];
        [board findIndex:touchLoc];
    }

//    [counterLabel setString:[NSString stringWithFormat:@"Counter: %i",board.curCounter%10]];
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    
    if (isGameOver)
        return;
    
    if ([self isMyTurn]){
        
        board.usesRandom = true;
        
        board.isMyTurn = TRUE;
        BOOL movesFound = [board countTiles];
        board.isMyTurn = FALSE;
        if (movesFound){
            
            [self sendMove];
            
            
        }
    
    }
    


    
    
//    [counterLabel setString:[NSString stringWithFormat:@"Counter: %i",board.curCounter%10]];
    [scoreLabel setString:[NSString stringWithFormat:@"My Score: %i",board.score]];
}
@end

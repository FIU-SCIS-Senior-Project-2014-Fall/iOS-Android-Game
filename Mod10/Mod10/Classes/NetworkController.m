//
//  NetworkController.m
//  Mod10
//
//  Created by Lorenzo Castillo on 9/28/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//
#import "NetworkController.h"
#import "MessageWriter.h"
#import "MessageReader.h"
#import "Match.h"
#import "Player.h"

@interface NetworkController (PrivateMethods)
- (BOOL)writeChunk;
@end

typedef enum {
    MessagePlayerConnected = 0,
    MessageNotInMatch,
    MessageStartMatch,
    MessageMatchStarted,
    MessageMovedSelf,
    MessagePlayerMoved,
    MessageGameOver,
    MessageNotifyReady,
} MessageType;

@implementation NetworkController

@synthesize state = _state;


#pragma mark - Helpers

static NetworkController *sharedController = nil;
+ (NetworkController *) sharedInstance {
    if (!sharedController) {
        sharedController = [[NetworkController alloc] init];
    }
    return sharedController;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void)setState:(NetworkState)state {
    _state = state;
    if (self.delegate) {
        [self.delegate stateChanged:_state];
    }
}

- (void)dismissMatchmaker {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
    self.mmvc = nil;
    self.presentingViewController = nil;
}

#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
        [self setState:_state];
        self.gameCenterAvailable = [self isGameCenterAvailable];
        if (self.gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)sendNotifyReady:(NSString *)inviter {
    MessageWriter * writer = [[MessageWriter alloc] init];
    [writer writeByte:MessageNotifyReady];
    [writer writeString:inviter];
    [self sendData:writer.data];
}

- (void)processMessage:(NSData *)data {
    NSLog(@"PROCESS MESSAGE");
    
    MessageReader * reader = [[MessageReader alloc] initWithData:data] ;
    
    unsigned char msgType = [reader readByte];
    
    if (msgType == MessageNotInMatch) {
        NSLog(@"PROCESS: MESSAGENOTINMATCH");
        [self setState:NetworkStateReceivedMatchStatus];
        [self.delegate setNotInMatch];
    }
    else if (msgType == MessageMatchStarted) {
        
        [self setState:NetworkStateMatchActive];
        [self dismissMatchmaker];
        unsigned char matchState = [reader readByte];
        NSMutableArray * players = [NSMutableArray array];
        
        NSString *turn = [reader readString];
        
        if ([turn isEqualToString:[GKLocalPlayer localPlayer].playerID]){
            
            CCLOG(@"MY TURN");
            
        }
        else{
            CCLOG(@"NOT MY TURN");
        }
        
        unsigned char numPlayers = [reader readByte];
        for(unsigned char i = 0; i < numPlayers; ++i) {
            NSString *playerId = [reader readString];
            NSString *alias = [reader readString];
            int posX = [reader readInt];
            Player *player = [[Player alloc] initWithPlayerId:playerId alias:alias];
            [players addObject:player];
        }
        
        int tilesNum = [reader readInt];
        NSLog(@"Num of tiles: %i",tilesNum);
        
        NSMutableArray * tileVals = [NSMutableArray arrayWithCapacity:25];
        
        for (int i = 0; i < tilesNum; i++){
            
            int tileVal = [reader readInt];
            [tileVals addObject:[NSNumber numberWithInt:tileVal] ];
            NSLog(@"Tile: %i",tileVal);
            
        }
        
        Match * match = [[Match alloc] initWithState:matchState players:players];

        [_delegate matchStarted:match andArr:tileVals];
        
    }
    else if (msgType == MessagePlayerMoved && _state == NetworkStateMatchActive) {
        
        unsigned char playerIndex = [reader readByte];
        
        
        Move *move = [Move new];
        
        int score = [reader readInt];
        move.score = score;
        CCLOG(@"Score: %i",score);
        
    
        int numIndices = [reader readInt];
        CCLOG(@"num indices: %i",numIndices);
        for (int i = 0; i < numIndices; i++){
            int index = [reader readInt];
            CCLOG(@"%i", index);
            [move.indices addObject:[NSNumber numberWithInt:index]];
        }
        
        int numTiles = [reader readInt];
        CCLOG(@"numTiles: %i", numTiles);
        for (int i = 0; i < numTiles; i++){
            int val = [reader readInt];
            CCLOG(@"%i",val);
            [move.tileVals addObject:[NSNumber numberWithInt:val]];

        }
        
        [_delegate player:playerIndex moved:move];
        
        
        
    } else if (msgType == MessageGameOver && _state == NetworkStateMatchActive) {
        unsigned char winnerIndex = [reader readByte];
        [_delegate gameOver:winnerIndex];
    }
    else if (msgType == MessageNotifyReady) {
        NSString *playerId = [reader readString];
        NSLog(@"Player %@ ready", playerId);
        if (_mmvc != nil) {
            //[_mmvc setHostedPlayerReady:playerId];
            [_mmvc setHostedPlayer:playerId connected:TRUE];
        }
    }
    
}

#pragma mark - Message sending / receiving

- (void)sendData:(NSData *)data {
    
    if (self.outputBuffer == nil) return;
    
    int dataLength = data.length;
    dataLength = htonl(dataLength);
    [self.outputBuffer appendBytes:&dataLength length:sizeof(dataLength)];
    [self.outputBuffer appendData:data];
    if (self.okToWrite) {
        [self writeChunk];
        NSLog(@"Wrote message");
    } else {
        NSLog(@"Queued message");
    }
}

- (void)sendPlayerConnected:(BOOL)continueMatch {
    [self setState:NetworkStatePendingMatchStatus];
    
    MessageWriter * writer = [[MessageWriter alloc] init] ;
    [writer writeByte:MessagePlayerConnected];
    [writer writeString:[GKLocalPlayer localPlayer].playerID];
    [writer writeString:[GKLocalPlayer localPlayer].alias];
    [writer writeByte:continueMatch];
    [self sendData:writer.data];
}
- (void)sendStartMatch:(NSArray *)players {
    [self setState:NetworkStatePendingMatchStart];
    
    MessageWriter * writer = [[MessageWriter alloc] init];
    [writer writeByte:MessageStartMatch];
    [writer writeByte:players.count];
    for(NSString *playerId in players) {
        [writer writeString:playerId];
    }
    [self sendData:writer.data];
}


/**
 
 Message: tag, int currScore, int sizeofindicies, indices, int sizeoftileVals, tileVals
 
 **/
-(void)sendMove:(Move*) move{
    
    NSLog(@"SEND MOVE");
    
    MessageWriter * writer = [[MessageWriter alloc] init];
    [writer writeByte:MessageMovedSelf];
    [writer writeInt:move.score];
    [writer writeInt:move.indices.count];
    
    NSLog(@"INDICES");
    for (NSNumber * num in move.indices) {
        NSLog(@"%i",[num intValue]);
        [writer writeInt:[num intValue]];
    }
    
    [writer writeInt:move.tileVals.count];
    
    NSLog(@"TILE VALS");
    for (NSNumber * num in move.tileVals) {
        NSLog(@"%i",[num intValue]);
        [writer writeInt:[num intValue]];
    }
    
    [self sendData:writer.data];
    NSLog(@"ENDSENDMOVE");
    
}
- (void)sendMovedSelf:(int)posX {
    
    MessageWriter * writer = [[MessageWriter alloc] init];
    [writer writeByte:MessageMovedSelf];
    [writer writeInt:posX];
    [self sendData:writer.data];
    
}

#pragma mark - Server communication

- (void)connect {
    
    self.outputBuffer = [NSMutableData data];
    self.inputBuffer = [NSMutableData data];
    
    [self setState:NetworkStateConnectingToServer];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.2.107", 1955, &readStream, &writeStream);
    
    self.inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    self.outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [self.outputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

- (void)disconnect {
    
    [self setState:NetworkStateConnectingToServer];
    
    if (self.inputStream != nil) {
        self.inputStream.delegate = nil;
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream close];
        self.inputStream = nil;
        self.inputBuffer = nil;
    }
    if (self.outputStream != nil) {
        self.outputStream.delegate = nil;
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream close];
        self.outputStream = nil;
        self.outputBuffer = nil;
    }
}

- (void)reconnect {
    [self disconnect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self connect];
    });
}

- (void)inputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"Opened input stream");
            self.inputOpened = YES;
            if (self.inputOpened && self.outputOpened && _state == NetworkStateConnectingToServer) {
                [self setState:NetworkStateConnected];
                BOOL continueMatch = _pendingInvite == nil;
                [self sendPlayerConnected:continueMatch];
            }
        }
        case NSStreamEventHasBytesAvailable: {
            if ([self.inputStream hasBytesAvailable]) {
                NSLog(@"Input stream has bytes...");
                NSInteger       bytesRead;
                uint8_t         buffer[32768];
                
                bytesRead = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                if (bytesRead == -1) {
                    NSLog(@"Network read error");
                } else if (bytesRead == 0) {
                    NSLog(@"No data read, reconnecting");
                    [self reconnect];
                } else {
                    NSLog(@"Read %d bytes", bytesRead);
                    [self.inputBuffer appendData:[NSData dataWithBytes:buffer length:bytesRead]];
                    [self checkForMessages];
                }
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO); // should never happen for the input stream
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

- (void)checkForMessages {
    NSLog(@"CHECK FOR MESSAGES");
    while (true) {
        if (self.inputBuffer.length < sizeof(int)) {
            return;
        }
        
        int msgLength = *((int *) self.inputBuffer.bytes);
        msgLength = ntohl(msgLength);
        if (self.inputBuffer.length < msgLength) {
            return;
        }
        
        NSData * message = [self.inputBuffer subdataWithRange:NSMakeRange(4, msgLength)];
        
        [self processMessage:message];
        
        int amtRemaining = self.inputBuffer.length - msgLength - sizeof(int);
        if (amtRemaining == 0) {
            self.inputBuffer = [[NSMutableData alloc] init] ;
        } else {
            NSLog(@"Creating input buffer of length %d", amtRemaining);
            self.inputBuffer = [[NSMutableData alloc] initWithBytes:self.inputBuffer.bytes+4+msgLength length:amtRemaining] ;
        }
        
    }
}

- (BOOL)writeChunk {
    
    long amtToWrite = MIN(self.outputBuffer.length, 1024);
    if (amtToWrite == 0) return FALSE;
    
    NSLog(@"Amt to write: %lu/%lu", amtToWrite, self.outputBuffer.length);
    
    long amtWritten = [self.outputStream write:self.outputBuffer.bytes maxLength:amtToWrite];
    if (amtWritten < 0) {
        [self reconnect];
    }
    long amtRemaining = self.outputBuffer.length - amtWritten;
    if (amtRemaining == 0) {
        self.outputBuffer = [NSMutableData data];
    } else {
        NSLog(@"Creating output buffer of length %lu", amtRemaining);
        self.outputBuffer = [NSMutableData dataWithBytes:self.outputBuffer.bytes+amtWritten length:amtRemaining];
    }
    NSLog(@"Wrote %lu bytes, %lu remaining.", amtWritten, amtRemaining);
    self.okToWrite = FALSE;
    return TRUE;
}

- (void)outputStreamHandleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"Opened output stream");
            self.outputOpened = YES;
            if (self.inputOpened && self.outputOpened && _state == NetworkStateConnectingToServer) {
                [self setState:NetworkStateConnected];
                BOOL continueMatch = _pendingInvite == nil;
                [self sendPlayerConnected:continueMatch];
            }
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"Ok to send");
            BOOL wroteChunk = [self writeChunk];
            if (!wroteChunk) {
                self.okToWrite = TRUE;
            }
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (aStream == self.inputStream) {
            [self inputStreamHandleEvent:eventCode];
        } else if (aStream == self.outputStream) {
            [self outputStreamHandleEvent:eventCode];
        }
    });
}

#pragma mark - Authentication

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !self.userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        [self setState:NetworkStateAuthenticated];
        self.userAuthenticated = TRUE;
        [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            NSLog(@"Received invite");
            self.pendingInvite = acceptedInvite;
            self.pendingPlayersToInvite = playersToInvite;
            
            if (_state >= NetworkStateConnected) {
                [self setState:NetworkStateReceivedMatchStatus];
                [_delegate setNotInMatch];
            }
            
        };
        [self connect];
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && self.userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        self.userAuthenticated = FALSE;
        [self setState:NetworkStateNotAvailable];
        [self disconnect];
    }
    
}

- (void)authenticateLocalUser {
    
    if (!self.gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [self setState:NetworkStatePendingAuthentication];
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
}


#pragma mark - Matchmaking

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController {
    
    if (!self.gameCenterAvailable) return;
    
    [self setState:NetworkStatePendingMatch];
    
    self.presentingViewController = viewController;
    [self.presentingViewController dismissModalViewControllerAnimated:NO];
    
    if (_pendingInvite != nil) {
        
        [self sendNotifyReady:_pendingInvite.inviter];
        
        self.mmvc = [[GKMatchmakerViewController alloc] initWithInvite:_pendingInvite] ;
        _mmvc.hosted = YES;
        _mmvc.matchmakerDelegate = self;
        
        [_presentingViewController presentModalViewController:_mmvc animated:YES];
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    } else {
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        
        self.mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        self.mmvc.hosted = YES;
        self.mmvc.matchmakerDelegate = self;
        
        [self.presentingViewController presentModalViewController:self.mmvc animated:YES];
    }
}

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    NSLog(@"matchmakerViewControllerWasCancelled");
    [self dismissMatchmaker];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error.localizedDescription);
    [self dismissMatchmaker];
}

// Players have been found for a server-hosted game, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs {
    
    NSLog(@"didFindPlayers");
    NSLog(@"Local ID %@",[[GKLocalPlayer localPlayer] playerID]);
    
    NSMutableArray * arr = [playerIDs mutableCopy];
    [arr addObject:[[GKLocalPlayer localPlayer] playerID]];
    
    for (NSString *playerID in arr) {
        NSLog(@"%@", playerID);
    }
    if (_state == NetworkStatePendingMatch) {
        [self dismissMatchmaker];
        [self sendStartMatch:arr];
    }
    
}

// An invited player has accepted a hosted invite.  Apps should connect through the hosting server and then update the player's connected state (using setConnected:forHostedPlayer:)
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0) {
    NSLog(@"didReceiveAcceptFromHostedPlayer");
}
@end
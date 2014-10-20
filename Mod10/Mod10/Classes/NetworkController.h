//
//  NetworkController.h
//  Mod10
//
//  Created by Lorenzo Castillo on 9/28/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Move.h"

typedef enum {
    NetworkStateNotAvailable,
    NetworkStatePendingAuthentication,
    NetworkStateAuthenticated,
    NetworkStateConnectingToServer,
    NetworkStateConnected,
    NetworkStatePendingMatchStatus,
    NetworkStateReceivedMatchStatus,
    NetworkStatePendingMatch,
    NetworkStatePendingMatchStart,
    NetworkStateMatchActive,
    
} NetworkState;

@class Match;

@protocol NetworkControllerDelegate
- (void)stateChanged:(NetworkState)state;
- (void)setNotInMatch;
- (void)matchStarted:(Match *)theMatch andArr:(NSArray * ) tileVals;
- (void)player:(unsigned char)playerIndex moved:(Move*)move;
- (void)gameOver:(unsigned char)winnerIndex;
@end

@interface NetworkController : NSObject <NSStreamDelegate, GKMatchmakerViewControllerDelegate> {

}

@property (assign) BOOL gameCenterAvailable;
@property (assign) BOOL userAuthenticated;
@property (assign) id <NetworkControllerDelegate> delegate;
@property (assign,readonly) NetworkState state;
@property (retain) NSInputStream *inputStream;
@property (retain) NSOutputStream *outputStream;
@property (assign) BOOL inputOpened;
@property (assign) BOOL outputOpened;
@property (retain) NSMutableData *outputBuffer;
@property (assign) BOOL okToWrite;
@property (retain) NSMutableData *inputBuffer;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatchmakerViewController *mmvc;
@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;

+ (NetworkController *)sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController;
- (void)sendMovedSelf:(int)posX;
-(void)sendMove:(Move*) move;

@end

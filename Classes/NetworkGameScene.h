//
//  NetworkGameScene.h
//  GoStop
//
//  Created by Sehyun Park on 09. 06. 24.
//  Copyright 2009 i2workshop. All rights reserved.
//
#import "cocos2d.h"
#import "GameScene.h"


@interface NetworkGameScene : GameScene <GKPeerPickerControllerDelegate, GKSessionDelegate>{
	//GameLayer *gLayer; 
	
	NSInteger	gameState;
	NSInteger	peerStatus;
	
	// networking
	GKSession		*gameSession;
	int				gameUniqueID;
	int				gamePacketNumber;
	NSString		*gamePeerId;
	NSDate			*lastHeartbeatDate;
	
	UIAlertView		*connectionAlert;
}
@property(nonatomic) NSInteger		gameState;
@property(nonatomic) NSInteger		peerStatus;

@property(nonatomic, retain) GKSession	 *gameSession;
@property(nonatomic, copy)	 NSString	 *gamePeerId;
@property(nonatomic, retain) NSDate		 *lastHeartbeatDate;
@property(nonatomic, retain) UIAlertView *connectionAlert;

- (void)startPicker;
- (void)invalidateSession:(GKSession *)session;
- (void)startNetworkGame;
- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend;

- (void)turnOver;
- (void)turnDecided:(BOOL)turn;
- (void)thrownCard:(Card *)aCard;
- (void)gainedCard:(Card *)aCard;
@end

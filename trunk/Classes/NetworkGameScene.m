//
//  NetworkGameScene.m
//  GoStop
//
//  Created by Sehyun Park on 09. 06. 24.
//  Copyright 2009 i2workshop. All rights reserved.
//

#import "NetworkGameScene.h"
#import "MenuScene.h"

#define kSessionID @"mintgostop"
//
// various states the game can get into
//
typedef enum {
	kStateStartGame,
	kStatePicker,
	kStateMultiplayer,
	kStateMultiplayerCointoss,
	kStateMultiplayerReconnect
} gameStates;

//
typedef enum {
	kServer,
	kClient
} gameNetwork;

typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
	NETWORK_INITIAL_CARDS,			// cards in deck & hands 
	NETWORK_TURN_DECISION,			// tell the client his first or not 
	NETWORK_CARD_THROWN,			// card thrown
	NETWORK_CARD_GAINED,			// card gained
	NETWORK_SPECIAL_ACTION,			// special action 
	NETWORK_TURN_OVER,				// turn over 
} packetCodes;

@implementation NetworkGameScene

@synthesize gameState, peerStatus;
@synthesize gameSession, gamePeerId, lastHeartbeatDate, connectionAlert; 

- (id) init {
    self = [super init];
    if (self != nil) {
        Sprite * bg = [Sprite spriteWithFile:@"debugBg.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:BG_ZINDEX];
		
		
		gLayer = [GameLayer node];
        [self addChild:gLayer z:GAME_ZINDEX];	
		
		[gLayer setPlayerUser:[[Player alloc] initWithPlayerNumber:0]];					//user
		[self addChild:[gLayer playerUser] z:PLAYER1_ZINDEX];
		
		[gLayer setPlayerCom:[[Player alloc] initWithPlayerNumber:1]];					//here it's not a computer
		[self addChild:[gLayer playerCom] z:PLAYER2_ZINDEX];
		
    }
    return self;
}

- (void)startNetworkGame
{
	gamePacketNumber = 0;
	gameSession = nil;
	gamePeerId = nil;
	lastHeartbeatDate = nil;
	
	NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
	
	gameUniqueID = [uid hash];
	
	
	
	self.isMultiplay = YES;
	
	// In Network Game Mode, Should we make a network game loop? 
	[self startPicker];
}

// SERVER 
- (void)startServer 
{
	NSLog(@"startServer!!");
	//shuffle and let the client know
	[gLayer shuffleCards]; 
	
	int seqContainer[MAX_CARDNUM]; 
	[gLayer shuffleCardsData:seqContainer];
	[self sendNetworkPacket:self.gameSession 
				   packetID:NETWORK_INITIAL_CARDS 
				   withData:seqContainer
				   ofLength:sizeof(int)*MAX_CARDNUM reliable:YES];
	
	//after shuffle the cards, decide who's first 
	[gLayer decisionFirst:nil]; 
}

- (void)turnOver
{
	//NSLog(@"local turnover called");
	int blankData = 0;
	[self sendNetworkPacket:self.gameSession
				   packetID:NETWORK_TURN_OVER 
				   withData:&blankData 
				   ofLength:sizeof(int) 
				   reliable:YES]; 
}

- (void)turnDecided:(BOOL)turn
{
	int sendTurn = !turn;
	[self sendNetworkPacket:self.gameSession 
				   packetID:NETWORK_TURN_DECISION 
				   withData:&sendTurn
				   ofLength:sizeof(int) 
				   reliable:YES]; 
}

- (void)thrownCard:(Card *)aCard 
{
	int cardSeq = [aCard seqOfCard]; 
	[self sendNetworkPacket:self.gameSession 
				   packetID:NETWORK_CARD_THROWN
				   withData:&cardSeq 
				   ofLength:sizeof(int) 
				   reliable:YES]; 
}

- (void)gainedCard:(Card *)aCard 
{
	int cardSeq = [aCard seqOfCard]; 
	[self sendNetworkPacket:self.gameSession 
				   packetID:NETWORK_CARD_GAINED
				   withData:&cardSeq 
				   ofLength:sizeof(int) 
				   reliable:YES]; 
}

// CLIENT 
- (void)startClient
{
	//well client should wait server call
}



#pragma mark -
#pragma mark Peer Picker Related Methods

-(void)startPicker {
	GKPeerPickerController*		picker;
	
	self.gameState = kStatePicker;			// we're going to do Multiplayer!
	
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}

#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker { 
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// autorelease the picker. 
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	if(self.gameSession != nil)	{
		[self invalidateSession:self.gameSession];
		self.gameSession = nil;
	}
	
	// go back to start mode
	self.gameState = kStateStartGame;
	
	//TODO  - Maybe we should go back to the main menu? 
	MenuScene * ms = [MenuScene node];
	[[Director sharedDirector] replaceScene:ms];
} 

/*
 *	Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *		- see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type { 
	GKSession *session = [[GKSession alloc] initWithSessionID:kSessionID displayName:nil sessionMode:GKSessionModePeer]; 
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session { 
	// Remember the current peer.
	self.gamePeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	self.gameSession = session; // retain
	self.gameSession.delegate = self; 
	[self.gameSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
	//self.gameState = kStateMultiplayerCointoss;
	
	[self sendNetworkPacket:self.gameSession packetID:NETWORK_COINTOSS withData:&gameUniqueID ofLength:sizeof(int) reliable:YES];
	
} 

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { 
	static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];
	//
	// developer  check the network time and make sure packets are in order
	//
	int packetTime = pIntData[0];
	int packetID = pIntData[1];
	if(packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
		return;	
	}
	
	lastPacketTime = packetTime;
	switch( packetID ) {
		case NETWORK_COINTOSS:
		{
			NSLog(@"cointoss!!");
			// coin toss to determine roles of the two players
			int coinToss = pIntData[2];
			// if other player's coin is higher than ours then that player is the server
			if(coinToss < gameUniqueID) {
				self.peerStatus = kClient;
				[self startClient]; 
			} else 
			{
				self.peerStatus = kServer; 
				[self startServer]; 
			}
			
			//[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideGameLabel:) userInfo:nil repeats:NO];
		}
			break;
		case NETWORK_INITIAL_CARDS:
		{
			NSMutableArray *newCards = [NSMutableArray array]; 
			for(int i=0; i<MAX_CARDNUM; i++) 
			{
				NSLog(@"Card :%d, %d", i, pIntData[i+2]);
				[newCards addObject:[NSNumber numberWithInt:pIntData[i+2]]];
			}
			[gLayer addReceivedDeckToScene:newCards]; 
		}
			break; 
		case NETWORK_TURN_DECISION:
		{
			if((int)pIntData[2]) 
			{
				//your turn 
				NSLog(@"Client it's my turn!");
				[gLayer dealCards:nil]; 
			}
			else 
			{
				//other player's turn 
				NSLog(@"Client it's server turn!");
				[gLayer reverseDealCards:nil]; 	
			}
		}
			break; 
		case NETWORK_CARD_THROWN: // 상대방이 카드 냄 
		{
			NSLog(@"Other player Thrown Card!");
			[gLayer otherPlayerThrowsCardBySeq:pIntData[2]];
		}
			break;
		case NETWORK_CARD_GAINED: // 상대방이 카드 가져감 
		{
			NSLog(@"Other player Gained Card!");
			[gLayer otherPlayerGainedCardBySeq:pIntData[2]]; 
		}
			break; 
		case NETWORK_SPECIAL_ACTION: // TODO:상대방 특수 액션시 뭐 띄우려고 
		{
			
		}
			break; 
		case NETWORK_TURN_OVER:
		{
			NSLog(@"Turn Over called"); 
			[gLayer turnOver];
		}
			break;
		default:
			// error
			break;
	}
}

- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend {
	// the packet we'll send is resued
	static unsigned char networkPacket[1024];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (1024 - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = gamePacketNumber++;
		pIntData[1] = packetID;
		// copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length ); 
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
		if(howtosend == YES) { 
			[session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataReliable error:nil];
		} else {
			[session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
		}
	}
}

#pragma mark GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state { 
	if(self.gameState == kStatePicker) {
		return;				// only do stuff if we're in multiplayer, otherwise it is probably for Picker
	}
	
	if(state == GKPeerStateDisconnected) {
		// We've been disconnected from the other peer.
		
		// Update user alert or throw alert if it isn't already up
		NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
		if((self.gameState == kStateMultiplayerReconnect) && self.connectionAlert && self.connectionAlert.visible) {
			self.connectionAlert.message = message;
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
			self.connectionAlert = alert;
			[alert show];
			[alert release];
		}
		
		// go back to start mode
		self.gameState = kStateStartGame; 
	} 
} 


@end

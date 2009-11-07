//
//  GameLayer.h
//  GoStop
//
//  Created by Conan Kim on 9/17/09.
//  Copyright 2009 Mintech. All rights reserved.
//
#import "cocos2d.h"
#import "TouchLayer.h"
#import "Player.h"
#import "Card.h"

#import "ConstDefine.h"



@interface GameLayer : TouchLayer {
	NSMutableArray *cardList;													//Deck (뒤집지 않은 모든 카드)
	NSMutableArray *floorCardList;												//바닥에 깔려 있는 카드
	
	NSMutableArray *matchedCardList;											//throw하거나 뒤집어서 매치되는 카드 목록(floor에 있는)
	NSMutableArray *matchedCardThrownList;										//throw하거나 뒤집어서 매치되는 카드 목록(뒤집거나, 사용자가 소유한)
	NSMutableArray *presentedCardList;											//throw하거나 뒤집어서 매치되는 카드 목록(뒤집거나, 사용자가 소유한)
	
	Player *playerUser;															//plyaerUser는 절대적 사용자 User 객체 -> 게임 진행 중 바뀌지 않음
	Player *playerCom;															//playerCom은 절대적 상대방 User 객체 -> 게임 진행 중 바뀌지 않음	
	Player *currentPlayer;														//currentPlayer는 현재 턴인 User 객체 -> 턴마다 바뀜 (사용자 또는 상대방이 될 수 있음)
	Player *waitingPlayer;														//currentPlayer는 현재 턴이 아닌 User 객체 -> 턴마다 바뀜 (사용자 또는 상대방이 될 수 있음)
	
	NSMutableDictionary *scratchDictionary;
	int topZIndex;
	
	//slots map
	//floor slot map
	CGPoint floorSlotMap[MAX_FLOOR_SLOT];	
	BOOL isPopupOn; //팝업 여부
}

@property BOOL isPopupOn; 

- (void)loadData; 

//슬롯 맵 초기화
- (void)initFloorSlotMap;
- (void)shuffleCards;
- (void)dealCards:(id)sender;
- (BOOL)checkDuplicatedCard:(int)num;
- (void)removeAllCardSprites;

- (void)startGameWithUserTurn:(NSNumber *)userTurn;
- (void)giveCardtoUser:(Player *)user;
- (void)giveCardtoUser:(Player *)user withOrder:(int)order;

- (void)openCardWithOrder:(int)order;
- (void)openCard;

- (void)myTurn:(Card *)aCard;

- (int)userPosCardCount;
- (int)comPosCardCount;

- (void)checkUnMatchedCardAndDimmedAfterTimes:(int)times;
- (void)checkUnMatchedCardAndDimmed;

- (BOOL)isCardMatched:(Card *)aCard ;

- (Player *)playerUser;
- (void)setPlayerUser:(Player *)player;
- (Player *)playerCom;
- (void)setPlayerCom:(Player *)player;

- (NSMutableArray *)floorCardList;
- (NSMutableArray *)cardList;

- (void)bezierThrowCard:(Card *)aCard;

- (CGPoint)floorCoordWithIndex:(int)index;

- (BOOL)addToMatchedCardList:(Card *)aCard;
- (void)addToMatchedCardThrownList:(Card *)aCard;

- (CGPoint)findFloorCardPosition:(Card *)thrownCard;
- (CGPoint)findFloorCardPosition:(Card *)thrownCard needGain:(BOOL)needGain;

- (void)setEmptyMatchedCardList;

- (void)verifyGainingCard;
- (void)calcAndCheckPoint;
- (void)decisionGoAndStop:(NSDictionary *)userInfo;
- (void)gainPresentedCard;
- (void)didSelectGainingCard:(NSDictionary *)userInfo;
- (void)gainAllMatchedCard;

- (int)getNewLastZIndex;
- (void)turnOver;

- (BOOL)isUserTurn;
- (void)setIsUserTurn:(BOOL)value;

#pragma mark -
#pragma mark Network Play
- (void)shuffleCardsData:(int *)seqContainer;
- (void)addReceivedDeckToScene:(NSArray *)aCardList;
- (void)otherPlayerGainedCardBySeq:(int)cardSeq;
- (void)otherPlayerThrowsCardBySeq:(int)cardSeq;
- (Card *)cardBySeqNumber:(int)cardSeq fromList:(NSArray *)list;

@end

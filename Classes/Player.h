//
//  Player.h
//  GoStop
//
//  Created by Conan Kim on 5/25/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Card.h"
#import "Popup.h"

#define GOSTOP_POINT 3

enum 
{
	idx25pt = 0,
	idx10pt,
	idx5pt,
	idx1pt
};

@interface Player : Layer {

	NSMutableArray *cardList;													//들고있는 패 (낼 수 있는 패)
	NSMutableArray *gainedCardList;												//따먹은 패	
	
	CGPoint gainedCardSlotMap[4];												//딴 카드 위치(슬롯) 인덱스
	
	int playerNumber;	                                                        //0: user, 1:computer(auto mode), 2:opponet(multiplayer mode) (Player 종류 구분)		
	
	int pointAt1;																//피로 몇점인지 저장
	int pointAt5;																//5점짜리로 몇점인지 저장
	int pointAt10;																//10점짜리로 몇점인지 저장
	int pointAt25;																//광으로 몇점인지 저장		
	
	int prevMaxPoint;															//previous Point 중 가장 컷던 점수 1고이상후 계속 Go를 할 수 있는 지 여부 판단하기 위해	
	int currentPoint;															//current Point
	int goCount;																//고 몇번했는 지 카운트 함
	int shakeCount;																//몇번 흔들었는 지 저장함
	int shitCount;																//몇번 쌌는 지 저장함
	unsigned int gameMoney;																//게임머니
	
	Label *scoreLabel;															//점수표시라벨
	Label *goLabel;																//고 횟수 표시 벨
	Label *shakeLabel;															//흔들기 횟수 표시 라벨
	Label *shitLabel;															//싼 회수 표시 라벨
	
	Label *gameMoneyLabel;														//게임머니 표시 라벨
}


@property int pointAt1;
@property int pointAt5;
@property int pointAt10;
@property int pointAt25;
@property (readonly) int currentPoint;
@property (readonly) int goCount;
@property (readonly) int shakeCount;																//몇번 흔들었는 지 저장함
@property (readonly) int shitCount;																//몇번 쌌는 지 저장함
@property (readonly) unsigned int gameMoney;																//게임머니



- (id)init;
- (id) initWithPlayerNumber:(int)playerNumberValue;

- (void)initLabels;
- (void)initSlotMaps;
- (void)gainCards:(Card *)gainedCard;
- (void)gainCards:(Card *)gainedCard target:(id)target selector:(SEL)selector;

- (int)playerNumber;

- (NSMutableArray *)cardList;
- (NSMutableArray *)gainedCardList;
//- (void)startAutoPlayATurn;
- (void)startATurn;

- (int)calcMyPoint;
- (void)checkShakeAndBomb:(Card *)thrownCard floorCards:(NSMutableArray *)floorCardList;

- (void)throwCardsAsBomb:(NSDictionary *)userInfo;
- (void)throwCards:(NSMutableArray *)throwingCardList;
- (void)shakeCards:(NSDictionary *)userInfo;
- (void)possessCard:(Card *)givenCard;


- (void)checkGoAndStopWithTarget:(id)target selector:(SEL)selector;
- (void)initAllVariables;

- (Card *)presentCard;

- (void)setCurrentPoint:(int)value;
- (void)setGoCount:(int)value;
- (void)setShakeCount:(int)value;
- (void)setShitCount:(int)value;
- (void)setGameMoney:(unsigned int)value;

@end

//
//  Card.h
//  GoStop
//
//  Created by Conan Kim on 5/25/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CompositeActions.h"
#import "SoundManager.h"



#define CARD_MOVING_DURATION 0.1 //카드 날라가는 속도
#define CARD_UP_DURATION 0.1
#define CARD_DOWN_DURATION 0.5
#define CARD_PLAY_INTERVAL 1 //동작 간 간격 시간 (초)

#define TINY_SCALE 0.13		//아주작은카드 (컴퓨터 뒷면)
#define SMALL_SCALE 0.16	//작은카드	(딴 카드)
#define NORMAL_SCALE 0.2	//기본카드
#define LARGE_SCALE 0.3		//큰카드
#define LARGER_SCALE 0.4	//더큰카드

#define FLOOR_SLIDED_MARGIN 10	//중첩된 카드 중첩 비끼기 사이즈 (우/하)
#define GAIN_SLIDED_MARGIN 15 //딴 화투 중첩 비끼가 사이즈 (우)

@class GameLayer;

typedef enum CardTag
{
	kUserCardTag = 2000,
	kComCardTag,
	kUserGainCardTag,
	kComGainCardTag,
	kFloorCardTag,
	kDeckCardTag,
	kSunCardTag,
} CardTag;

typedef enum CardPoint
{
	mk25point = 0, //광
	mk10point, //10점
	mk5point, //5점
	mk1point, //피
} CardPoint;

@interface Card : Sprite  {
	
	int numberOfCard;															//카드번호(숫자)
	int seqOfCard;																//이미지번호
	int cardStatus;
	int slotIndex;																//해당카드가 자기 영역에서 위치하는 슬롯의 인덱스 값
	
	int indexOfCard; 
	CardPoint pointOfCard;														//Card point
	
	Action *scheduledAction;
	BOOL isFlipped;
	BOOL isClicked;
	
	BOOL isShaked;																//흔든 패인지 확인 여부 흔든 카드의 경우 폭탄/흔들기 체크를 하지 않는다.
	NSString *frontTextureFile;
}

@property (retain, nonatomic) NSString *frontTextureFile; 
@property BOOL isFlipped; 
@property BOOL isClicked;
@property BOOL isShaked;
@property (retain) Action *scheduledAction; 
@property int slotIndex; 
@property int indexOfCard; 

@property CardPoint pointOfCard;

 
- (id)initWithSeqNumber:(int)cardNumber;

- (int)numberOfCard;
- (void)setNumberOfCard:(int)value;

- (int)seqOfCard;
- (void)setSeqOfCard:(int)value;
				   
- (void)moveToUserAfterTimes:(int)times;
- (void)moveToUser;
- (void)moveToComAfterTimes:(int)times;
- (void)moveToCom;
- (void)moveToFloorAfterTimes:(int)times;
- (void)moveToFloor;


- (void)throw;
- (void)throwWithCallBackObject:(id)object selector:(SEL)callBack;
- (void)flipFromDeck;
- (void)flipFromDeckCallBackObject:(id)object selector:(SEL)callBack;
- (void)throwWithCallBackObject:(id)object selector:(SEL)callBack needGain:(BOOL)needGain;

- (void)putUp;
- (void)putDown;


- (void)flyingCardToX:(int)x Y:(int)y scale:(float)scale duration:(float)duration withFlip:(BOOL)withFlip;
- (void)flyingCardToX:(int)x Y:(int)y scale:(float)scale duration:(float)duration withFlip:(BOOL)withFlip object:(id)object callBack:(SEL)callBack;
//- (void)moveToUser:(Player *)player;

- (BOOL)isFlipped; 
- (Action *)flipAction;
- (void)flipCardWithDelay:(float)delay;
- (void)flipCard; 
- (NSString *)frontTextureFile;
- (void)setFrontTextureFile:(NSString *)aPath; 


- (void)changeTag:(CardTag)newTag;
- (void)removeSelfFromPreList;
- (void)addSelfToNewList;

- (void)dimmed;
- (void)notDimmed;

- (id)initWithDictionary:(NSDictionary *)cardDictionary;
- (NSDictionary *)dictionaryToSave;

- (void)scaleDownByTouch;
- (void)scaleDownImmediately;
- (void)scaleUpByTouch;


#pragma mark Touch callback method
- (void)receiveTouchesBegin:(UIEvent *)event;
- (void)receiveTouchesMoved:(UIEvent *)event;
- (void)receiveTouchesEnd:(UIEvent *)event;

//-(id) initWithCoder: (NSCoder *) decoder;
//-(void) encodeWithCoder: (NSCoder *) encoder; 


@end

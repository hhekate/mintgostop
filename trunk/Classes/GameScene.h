//
//  GameScene.h
//  GoStop
//
//  Created by Idiel on 5/20/09.
//  Copyright 2009 Code4Mac. All rights reserved.
//

#import <GameKit/GameKit.h> 
#import "cocos2d.h"
#import "GameLayer.h"
#import "Popup.h"
#import "CharacterAnimation.h"


/////////////////////Game Scene Class/////////////////////

@interface GameScene : Scene {
	GameLayer *gLayer;
	Popup *currentPopup;
	
	BOOL isMultiplay;
}

@property BOOL isMultiplay; 

- (void)loadGame; 
- (void)startGame; 
- (NSMutableDictionary *)transCardListPerMonth:(NSMutableArray *)givenCardList;	//일반 카드 목록을 월별 딕셔너리에 넣어줌
- (void)performAnimation:(int)animationKey;

- (GameLayer *)getGameLayer;
/*
- (void)didSelectCard:(Card *)aCard;
- (void)openPopupWithCardList:(NSArray *)aCardList;
- (void)openPopupWithCardList:(NSArray *)aCardList target:(id)target selector:(SEL)selector;
*/
@end
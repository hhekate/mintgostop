//
//  GameScene.m
//  GoStop
//
//  Created by Idiel on 5/20/09.
//  Copyright 2009 Code4Mac. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

@synthesize isMultiplay;

- (id)init 
{
    if (self = [super init]) {
		Sprite * bg = [Sprite spriteWithFile:@"debugBg.png"];
		[bg setPosition:ccp(240, 160)];
		[self addChild:bg z:BG_ZINDEX];
		
		gLayer = [GameLayer node];
		[self addChild:gLayer z:GAME_ZINDEX];
		
		[gLayer setPlayerUser:[[Player alloc] initWithPlayerNumber:0]];					//user
		[self addChild:[gLayer playerUser] z:PLAYER1_ZINDEX];
		
		if(self.isMultiplay)
			[gLayer setPlayerCom:[[Player alloc] initWithPlayerNumber:2]];					//opponent (network opponent player)
		else
			[gLayer setPlayerCom:[[Player alloc] initWithPlayerNumber:1]];					//computer (auto player)
		
		[self addChild:[gLayer playerCom] z:PLAYER2_ZINDEX];
    }
    return self;
}

-(GameLayer *)getGameLayer
{
	return gLayer;
}


- (void)loadGame
{
	NSLog(@"Load!");
	[gLayer loadData];
}

- (void)startGame
{
	[gLayer dealCards:nil];
}

/*
- (void)didSelectCard:(Card *)aCard
{
	NSLog(@"selected card :%@", aCard); 
	[self removeChild:currentPopup cleanup:YES];
	gLayer.isPopupOn = NO;
}

- (void)openPopupWithCardList:(NSArray *)aCardList
{	
	[self openPopupWithCardList:(NSArray *)aCardList target:self selector:@selector(didSelectCard:)];
}

- (void)openPopupWithCardList:(NSArray *)aCardList target:(id)target selector:(SEL)selector
{
	gLayer.isPopupOn = YES;
	
	currentPopup = [[Popup alloc] initWithTitle:@"어떤 패를 가져가시겠습니까?" 
										   card:aCardList
										 hasYes:NO hasNo:NO 
										 target:target 
									   selector:selector];
	[self addChild:currentPopup z:POP_ZINDEX];	 
}
*/

- (void)performAnimation:(int)animationKey
{
	gLayer.isPopupOn = YES;
	CharacterAnimation *newCharacterAnimation = [CharacterAnimation newCharacterAnimation];
	[self addChild:newCharacterAnimation z:ANI_ZINDEX];
	[newCharacterAnimation startCharacterAnimation:animationKey];
}

//패 목록을 받아 월별로 딕셔너리에 넣어서 반환한다.
- (NSMutableDictionary *)transCardListPerMonth:(NSMutableArray *)givenCardList
{
	NSMutableDictionary *monthDictionary = [[[NSMutableDictionary alloc] init] autorelease];
	
	for(Card *aCard in givenCardList){
		//월([aCard numberOfCard])갑 별로 카드를 정렬한다.
		NSNumber *cardMonthNumber = [NSNumber numberWithInt:[aCard numberOfCard]];
		NSMutableArray *cardsByMonth = [monthDictionary objectForKey:cardMonthNumber];
		[aCard setIsFlipped:YES];
		
		//Dictionary를 뒤져서 해당 월 키의 배열이 있으면 그 배열에 추가
		if(cardsByMonth == nil){
			[monthDictionary setObject:[NSMutableArray arrayWithObject:aCard] forKey:cardMonthNumber];
		} else { //있으면 해당 배열에 추가
			[cardsByMonth addObject:aCard];
		}
	}
	
	return monthDictionary;
}

@end


//
//  SunLayer.m
//  GoStop
//
//  Created by Conan Kim on 9/17/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "SunLayer.h"



@implementation SunLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		//Touch사용하기
		isTouchEnabled = YES;
		
		//선정하기 라벨
		Label *titleLabel = [Label labelWithString:@"선 결정하기" dimensions:CGSizeMake(380,30) alignment:UITextAlignmentCenter fontName:@"Courier" fontSize:28];
		[titleLabel setPosition:ccp(240,280)];
		[self addChild:titleLabel z:0];
		
		[self shuffleSunCard];				
    }
    return self;
}


- (void)shuffleSunCard
{
	sunPlayer = -1; //초기화 (invalid value)
	
	int seqOfCard1  = -1, seqOfCard2 = -1;
	
	[self removeAllCardSprites];
	
	srandom(time(NULL));
	
	seqOfCard1 = (random() % MAX_CARDNUM) + 1;
	Card *firstCard = [[Card alloc] initWithSeqNumber:seqOfCard1];
	//Card *firstCard = [[Card alloc] initWithSeqNumber:1];
	
	do{
		seqOfCard2 = (random() % MAX_CARDNUM) + 1;
	} while (seqOfCard1 == seqOfCard2);
	
	Card *secondCard = [[Card alloc] initWithSeqNumber:seqOfCard2];
	//Card *secondCard = [[Card alloc] initWithSeqNumber:20];
	
	[firstCard setTag:kSunCardTag];
	[secondCard setTag:kSunCardTag];
	
	[firstCard setPosition:ccp(140,160)];
	[secondCard setPosition:ccp(340,160)];
	
	firstCard.scale = 0.5;
	secondCard.scale = 0.5;
	
	[self addChild:firstCard z:1];
	[self addChild:secondCard z:2];
}

- (void)decisionFirst:(Card *)selectedCard
{
	//자신의 카드를 뒤집고 1초 후 상대방 카드도 뒤집는다.
	//상대방 카드 가져오기
	Card *oppCard;
	
	for(CocosNode *aNode in [self children]){
		if([aNode isMemberOfClass:[Card class]]){
			if(aNode != selectedCard){
				oppCard = (Card *)aNode;
				break;
			}
		}
	}
	
	[selectedCard flipCard];	
	[oppCard flipCardWithDelay:0]; //1초뒤
	
	if([selectedCard numberOfCard] > [oppCard numberOfCard]){ //내가선
		sunPlayer = 1;
	} else if ([selectedCard numberOfCard] == [oppCard numberOfCard]) { //같은월의 카드라면 점수로 승패 따진다.
		if ([selectedCard pointOfCard] < [oppCard pointOfCard]) { //내가선 
			sunPlayer = 1;
		} else if ([selectedCard pointOfCard] == [oppCard pointOfCard]){ //무승 부 다시해야함
			//[self shuffleSunCard];
			//[self performSelector:@selector(shuffleSunCard) withObject:nil afterDelay:3];
			sunPlayer = 2;
		} else { //상대방이 선
			sunPlayer = 0;
		}		
	} else { //상대방이 선
		sunPlayer = 0;
	}
	
	if(sunPlayer != -1){ //선이 정해진 경우 팝업을 띄운다.
		
		[self performSelector:@selector(popupWithSunDecision) withObject:nil afterDelay:3]; //3초뒤
	}
}

- (void)popupWithSunDecision
{
	if(sunPlayer == 1){
		[Popup popUpWithTitle:@"당신이 선입니다." hasYes:YES hasNo:YES target:self selector:@selector(moveToGameScene:)];
	} else if(sunPlayer == 0){
		[Popup popUpWithTitle:@"상대방이 선입니다." hasYes:YES hasNo:YES target:self selector:@selector(moveToGameScene:)];
	} else if(sunPlayer == 2){
		[Popup popUpWithTitle:@"다시 선을 정합니다." hasYes:YES hasNo:NO target:self selector:@selector(shuffleSunCard)];
	} else {
		//오류
		[Popup popUpWithTitle:@"선 결정 중 오류가 발생했습니다." hasYes:YES hasNo:YES target:self selector:@selector(shuffleSunCard)];
	}
}

- (void)removeAllCardSprites
{
	int i = 0;
	int lastIndexOfCards = [[self children] count] - 1;
	
	for(i = lastIndexOfCards ; i >= 0 ; i--){
		Sprite *aSprite = [[self children] objectAtIndex:i];
		//카드 스프라이트는 다 지움
		if([aSprite isMemberOfClass:[Card class]]) {			
			//지움
			[self removeChild:aSprite cleanup:YES];
		}
	}
}

- (void)moveToGameScene:(NSDictionary *)userInfo
{
	int modalResult = [[userInfo objectForKey:MTPopUpModalResultKey] intValue];
	
	if(modalResult == kPopupOKButton){
		GameScene * gs = [GameScene node];
		[[Director sharedDirector] replaceScene:[SlideInRTransition transitionWithDuration:0.4 scene:gs]];
		
		[(GameLayer *)[gs getGameLayer] startGameWithUserTurn:[NSNumber numberWithInt:sunPlayer]];
		//[(GameLayer *)[gs getGameLayer] performSelector:@selector(startGameWithUserTurn:) withObject:[NSNumber numberWithInt:sunPlayer] afterDelay:0.4];
	} else {
		//메뉴로 이동 또는 종료하시겠습니까?
		[self shuffleSunCard];
	}
}

@end
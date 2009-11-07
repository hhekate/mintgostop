//
//  GameLayer.m
//  GoStop
//
//  Created by Conan Kim on 9/17/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "GameLayer.h"
#import "GameScene.h"
#import "NetworkGameScene.h"


@implementation GameLayer

@synthesize isPopupOn;

- (id) init {
    self = [super init];
    if (self != nil) {
        isTouchEnabled = YES;
		
		cardList = [[NSMutableArray alloc] init];
		floorCardList = [[NSMutableArray alloc] init];
		matchedCardList = [[NSMutableArray alloc] init];
		matchedCardThrownList = [[NSMutableArray alloc] init];
		presentedCardList = [[NSMutableArray alloc] init];
		
		[self removeAllCardSprites];											//Sprites 초기화
		[self initFloorSlotMap];												//Floor 슬롯 맵 초기화		
		
		scratchDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)saveData
{
	
	//Simplified Save
	NSMutableArray *cardsToSave = [NSMutableArray array]; 
	
	NSArray *deckCards = [self cardList]; 
	for(Card* aCard in deckCards) 
	{
		[cardsToSave addObject:[aCard dictionaryToSave]]; 
	}
	
	NSArray *floorCards = [self floorCardList]; 
	for(Card* aCard in floorCards) 
	{
		[cardsToSave addObject:[aCard dictionaryToSave]]; 
	}
	
	NSArray *userCardsInHand = [[self playerUser] cardList];
	for(Card* aCard in userCardsInHand) 
	{
		[cardsToSave addObject:[aCard dictionaryToSave]]; 
	}
	
	NSArray *userCardsGained = [[self playerUser] gainedCardList]; 
	for(Card* aCard in userCardsGained) 
	{
		[cardsToSave addObject:[aCard dictionaryToSave]]; 
	}
	
	NSArray *comCardsInHand = [[self playerCom] cardList];
	for(Card* aCard in comCardsInHand) 
	{
		[cardsToSave addObject:[aCard dictionaryToSave]]; 
	}
	
	NSArray *comCardsGained = [[self playerCom] gainedCardList]; 
	for(Card* aCard in comCardsGained) 
	{
		[cardsToSave addObject:[aCard dictionaryToSave]]; 
	}
	
	[[NSUserDefaults standardUserDefaults] setValue:cardsToSave
											 forKey:@"SavedCards"];	
	
	/* save at the beginning of the user turn 
	 [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:[gLayer isUserTurn]] 
	 forKey:@"isUserTurn"];
	 */
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] 
											 forKey:@"GameSaved"];
	//Remaining Data to Handle 
	//	고					//GoCount
	//흔들기				//ShakeCount
	//싸기				//ShitCount 
	
}


- (void)loadData 
{
	//Simplified Data Load
	NSArray *savedCardList = [[NSUserDefaults standardUserDefaults] valueForKey:@"SavedCards"]; 
	for(NSDictionary *aDict in savedCardList) 
	{
		switch([[aDict valueForKey:@"tag"] intValue])
		{
			case	kUserCardTag:
			{
				Card *aCard = [[Card alloc] initWithDictionary:aDict]; 
				
				aCard.scale = LARGE_SCALE;
				[self addChild:aCard z:topZIndex++ tag:kUserCardTag];
				
				[aCard moveToUser]; 				
			}
				break; 
			case	kComCardTag:
			{
				Card *aCard = [[Card alloc] initWithDictionary:aDict]; 
				
				aCard.scale = SMALL_SCALE;
				[self addChild:aCard z:topZIndex++ tag:kComCardTag];
				aCard.isFlipped = NO;
				[aCard moveToCom]; 
				
			}
				break; 
			case	kUserGainCardTag:
			{
				Card *aCard = [[Card alloc] initWithDictionary:aDict]; 
				aCard.scale = SMALL_SCALE;
				aCard.isFlipped = NO;
				[aCard flipCard];
				[self addChild:aCard z:topZIndex++ tag:kUserGainCardTag];
				[playerUser gainCards:aCard]; 
			}
				break; 
			case	kComGainCardTag:
			{
				Card *aCard = [[Card alloc] initWithDictionary:aDict]; 
				aCard.scale = SMALL_SCALE;
				aCard.isFlipped = NO;
				[aCard flipCard];
				[self addChild:aCard z:topZIndex++ tag:kComGainCardTag];
				[playerCom gainCards:aCard]; 
			}
				break; 
			case	kFloorCardTag:
			{
				Card *aCard = [[Card alloc] initWithDictionary:aDict]; 
				aCard.scale = NORMAL_SCALE; 
				aCard.isFlipped = NO;
				[self addChild:aCard z:topZIndex++ tag:kFloorCardTag];
				[aCard setPosition:ccp(150, 170)];
				//position cards 
				[aCard moveToFloor];// positionFloorCards]; 
				[floorCardList addObject:aCard]; 
			}
				break; 
			case	kDeckCardTag:
			{
				Card *aCard = [[Card alloc] initWithDictionary:aDict]; 
				aCard.scale = NORMAL_SCALE;
				[self addChild:aCard z:topZIndex++ tag:kDeckCardTag];
				[aCard setPosition:ccp(150 - topZIndex/8, 170 + topZIndex/8)]; 
				[cardList addObject:aCard];
			}
				break; 
		}
		
	}
	//Who's turn? 
	//Always user turn 
	[self setIsUserTurn:YES];
	[self checkUnMatchedCardAndDimmed];
}

//Floor slot맵 초기화
- (void)initFloorSlotMap
{
	//floor slot map T:210, M:160, B:110 C:150
	int ty = 220; //top Y
	int my = 170; //middle Y
	int by = 120; //bottom Y
	int cx = 150; //center X
	int sx = 50;  //span x
	int mx = 15;  //margin x
	//-sx <-   -> +sx
	// 9  4  0  6  10  13 
	// 8  1  C  2  12  14
	// 11 5  3  7
	
	floorSlotMap[0] = CGPointMake(cx, ty);
	floorSlotMap[1] = CGPointMake(cx - sx - mx, my);
	floorSlotMap[2] = CGPointMake(cx + sx + mx, my);
	floorSlotMap[3] = CGPointMake(cx, by);
	floorSlotMap[4] = CGPointMake(cx - sx, ty);
	floorSlotMap[5] = CGPointMake(cx - sx, by);
	floorSlotMap[6] = CGPointMake(cx + sx, ty);
	floorSlotMap[7] = CGPointMake(cx + sx, by);
	floorSlotMap[8] = CGPointMake(cx - sx - sx -mx, my);
	floorSlotMap[9] = CGPointMake(cx - sx -sx, ty);
	floorSlotMap[10] = CGPointMake(cx + sx + sx, ty);
	floorSlotMap[11] = CGPointMake(cx -sx -sx, by);
	floorSlotMap[12] = CGPointMake(cx + sx + sx + mx, my);
	floorSlotMap[13] = CGPointMake(cx + sx + sx + sx, ty);
	floorSlotMap[14] = CGPointMake(cx + sx + sx + sx + mx, my);
}


- (void)dealloc
{
	[cardList release]; 
	cardList = nil; 
	
	[floorCardList release]; 
	floorCardList = nil; 
	
	[matchedCardList release]; 
	matchedCardList = nil; 
	
	[matchedCardThrownList release];
	matchedCardThrownList = nil;
	
	[presentedCardList release];
	presentedCardList = nil;
	
	[playerUser release];
	playerUser = nil;
	
	[playerCom release];
	playerCom = nil;
	
	[scratchDictionary release]; 
	scratchDictionary = nil; 
	
	[super dealloc]; 
}

- (void)startGameWithUserTurn:(NSNumber *)userTurn
{
	//NSLog(@"will start game after selecting who's go first");
	if([(GameScene *)[self parent] isMultiplay]) {
		NSLog(@"is it server turn? %d", [userTurn intValue]); 
		[(NetworkGameScene *)parent turnDecided:[userTurn boolValue]]; 
	}
	
	//plyaerUser는 절대적 사용자 User 객체 -> 게임 진행 중 바뀌지 않음
	//playerCom은 절대적 상대방 User 객체 -> 게임 진행 중 바뀌지 않음	
	//currentPlayer는 현재 턴인 User 객체 -> 턴마다 바뀜 (사용자 또는 상대방이 될 수 있음)
	//waitinPlayer는 현재 턴이 아닌 User 객체 -> 턴마다 바뀜 (사용자 또는 상대방이 될 수 있음)
	currentPlayer = [userTurn boolValue] ? playerUser : playerCom;
	waitingPlayer = ![userTurn boolValue] ? playerUser : playerCom;
	
	[self dealCards:nil];
}



- (void)shuffleCards
{	
	[self removeAllCardSprites];
	
	srandom(time(NULL));
	
	int seqOfCard;
	int countOfCard = 0;
	
	while(countOfCard < MAX_CARDNUM){
		
		seqOfCard = (random() % MAX_CARDNUM) + 1;
		
		/*
		 do { //test code
		 seqOfCard = (random() % MAX_CARDNUM) + 1;
		 } while ((seqOfCard == 46 || seqOfCard == 47 || seqOfCard == 48) && countOfCard < 45); //test code
		 */
		
		if(![self checkDuplicatedCard:seqOfCard]){
			
			NSLog(@"%d, %d",seqOfCard, countOfCard);
			Card *aCard = [[Card alloc] initWithSeqNumber:seqOfCard];
			aCard.scale = NORMAL_SCALE;
			[self addChild:aCard z:topZIndex++ tag:kDeckCardTag];
			[aCard setPosition:ccp(150 - topZIndex/8, 170 + topZIndex/8)]; 
			
			[cardList addObject:aCard];
			
			[aCard release];
			countOfCard ++;
		}
	}
	
}

//카드가 중복되어 들어가지 않도록
- (BOOL)checkDuplicatedCard:(int)num
{
	int i = 0;
	for(i = 0 ; i < [cardList count] ; i++){
		if([[cardList objectAtIndex:i] seqOfCard] == num){
			return YES;
		}
	}
	return NO;
}

//카드 모두 제거하고 초기화 하기
- (void)removeAllCardSprites
{
	topZIndex = 1;																//카드의 제일 상단 zIndex값 초기화
	
	int i = 0;
	int lastIndexOfCards = [[self children] count] - 1;
	
	for(i = lastIndexOfCards ; i >= 0 ; i--){
		Sprite *aSprite = [[self children] objectAtIndex:i];
		//카드 스프라이트는 다 지움
		if([aSprite tag] == kUserCardTag 
		   || [aSprite tag] == kComCardTag 
		   || [aSprite tag] == kUserGainCardTag 
		   || [aSprite tag] == kComGainCardTag 
		   || [aSprite tag] == kDeckCardTag
		   || [aSprite tag] == kFloorCardTag ) {
			
			//지움
			[self removeChild:aSprite cleanup:YES];
		}
	}
	
	[cardList removeAllObjects]; //데크목록삭제
	[floorCardList removeAllObjects]; //Floor 카드 목록 삭제
	
	[playerUser initAllVariables];
	[playerCom initAllVariables];
}

- (void) dealCards:(id)sender
{	
	if(![(GameScene *)[self parent] isMultiplay])
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] 
												 forKey:@"GameSaved"];
	
	//deal cards! 
	int i = 0; //카드 iterator
	int j = 0; //순차
	
	//카드 섞기
	[self shuffleCards];
	
	j += 10; //슬라이딩 애니메이션이 있기 때문에 나눠주는 건 시간이 흐른 뒤에함
	
	//선이 아닌 User 부터 5장 돌리기
	for(i = 0 ; i < 5 ; i++){
		[self giveCardtoUser:waitingPlayer withOrder:j++];
	}
	
	j += 3;
	
	//선인 User 5장 돌리기
	for(i = 0 ; i < 5 ; i++){
		[self giveCardtoUser:currentPlayer withOrder:j++];
	}
	
	j += 3;		
	
	//판깔기 4장
	for(i = 0 ; i < 4 ; i++){
		[self openCardWithOrder:j++];
	}
	
	j += 3;
	
	//선이 아닌 User 부터 5장 돌리기
	for(i = 0 ; i < 5 ; i++){
		[self giveCardtoUser:waitingPlayer withOrder:j++];
	}
	
	j += 3;
	
	//선인 User 5장 돌리기
	for(i = 0 ; i < 5 ; i++){
		[self giveCardtoUser:currentPlayer withOrder:j++];
	}
	
	j += 3;
	
	//판깔기 4장
	for(i = 0 ; i < 4 ; i++){
		[self openCardWithOrder:j++];
	}
	
	//매칭되는 카드 있는 지 확인하여 Dimmed 처리
	[self checkUnMatchedCardAndDimmedAfterTimes:j++];
	
	[currentPlayer performSelector:@selector(startATurn) withObject:nil afterDelay:(j++ * CARD_MOVING_DURATION)];
}


//카드 주기
- (void)giveCardtoUser:(Player *)user
{
	[self giveCardtoUser:user withOrder:0];
}

- (void)giveCardtoUser:(Player *)user withOrder:(int)order
{
	Card *lastCard = [cardList lastObject];
	
	if(lastCard != nil){		
		switch([user playerNumber]){
			case 0: //user
				[lastCard moveToUserAfterTimes:order];
				break;
			case 1: //com
			case 2: //Opponent
				[lastCard moveToComAfterTimes:order];					
				break;
			default:
				break;
		}
		
		//Deck에서 카드 삭제
		[cardList removeObject:lastCard];
	} else {
		NSLog(@"No more cards %s %u", __FILE__, __LINE__);						//카드 없음
	}
}

//카드 깔기
- (void)openCard
{
	[self openCardWithOrder:0];
}

//순차적으로 카드를 floor에 깔기
- (void)openCardWithOrder:(int)order
{
	Card *lastCard = [cardList lastObject];
	
	if(lastCard != nil){
		[lastCard moveToFloorAfterTimes:order];		
		[cardList removeObject:[cardList lastObject]];
	} else {
		//카드 없음
		NSLog(@"No more cards %s %u", __FILE__, __LINE__);
	}
}

//FlipCard Test 01 
- (void)flipCard:(Sprite *)aCard withFile:(NSString *)filePath
{
	id flipAction = [ScaleTo actionWithDuration:0.2 scaleX:0.0 scaleY:0.65];
	
	Animation* animation = [Animation animationWithName:@"changeTexture" delay:0.0];
	[animation addFrameWithFilename:filePath];
	id textureAction = [Animate actionWithAnimation: animation];
	
	id nextAction = [ScaleTo actionWithDuration:0.2 scaleX:0.7 scaleY:0.7]; 
	
	//구성된 액션 전체 길이가 1초가 넘지 않으면 모든게 순식간에 진행되어버림
	id timeFiller = [ScaleTo actionWithDuration:0.6 scaleX:0.7 scaleY:0.7]; 
	[aCard runAction:[Repeat actionWithAction:[Sequence actions:flipAction, textureAction, nextAction, timeFiller, nil] times:1]]; 
}

//ease in/out
- (void)throwCard:(Card *)aCard 
{
	id move = [MoveTo actionWithDuration:0.2 position:ccp(300,200)];
	id easeOut = [EaseOut actionWithAction:move
									  rate:2.0f];
	
	[aCard runAction:easeOut]; //[Repeat actionWithAction:[Sequence actions:easeIn, move, nil] times:1]]; 
}

//bezier throw
- (void)bezierThrowCard:(Card *)aCard 
{
	ccBezierConfig bezier;
	bezier.startPosition = aCard.position; 
	bezier.controlPoint_1 = ccp(0, -20);
	bezier.controlPoint_2 = ccp(-30, -10);
	bezier.endPosition = ccp(-10, -20);
	
	id bezierForward = [BezierBy actionWithDuration:1 bezier:bezier];
	[aCard runAction:bezierForward]; 
}

/*
 - (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 //popup은 touchEnabled로 처리하고
 //userTurn도 touchEnabled로 처리하고
 //touchEnabled 는 자체적으로 동작하므로 주석 처리함 kmaku 09/07/02
 //if(self.isPopupOn || !self.isUserTurn || !self.isTouchEnabled) //사용자 차례가 아니거나 팝업이 켜져있는경우 터치 이벤트 무시  //|| ![self isUserTurn]
 //	return kEventIgnored;
 
 UITouch *touch = [touches anyObject];
 
 CGPoint location = [touch locationInView: [touch view]];
 CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
 
 for(Sprite *aSprite in [self children])
 {
 
 if(([aSprite tag] == kUserCardTag ||
 [aSprite tag] == kDeckCardTag ||
 [aSprite tag] == kFloorCardTag ||
 [aSprite tag] == kComCardTag ||
 [aSprite tag] == kUserGainCardTag || 
 [aSprite tag] == kComGainCardTag) 
 && [(Card *)aSprite isFlipped]) //앞면 있는 카드일 때만 
 {
 
 //Size Fix
 CGSize s = aSprite.contentSize;
 s.width *= aSprite.scale; 
 s.height *= aSprite.scale;
 
 CGRect r = CGRectMake( aSprite.position.x - 
 s.width/2,
 aSprite.position.y-s.height/2,
 s.width, s.height);
 
 if( CGRectContainsPoint( r, convertedLocation ) )
 {
 
 [scratchDictionary setValue:aSprite forKey:@"InitiallyTouchedCard"]; //터치 시작 카드 
 [scratchDictionary setValue:aSprite forKey:@"PreviouslyTouchedCard"]; //터치 이동 시 체크용
 [(Card *)aSprite scaleUpByTouch];
 
 break;
 }			
 }
 }	
 
 return kEventHandled;
 }
 
 - (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { 
 //popup은 touchEnabled로 처리하고
 //userTurn도 touchEnabled로 처리하고
 //touchEnabled 는 자체적으로 동작하므로 주석 처리함 kmaku 09/07/02
 //if(self.isPopupOn || !self.isUserTurn || !self.isTouchEnabled)
 //	return kEventIgnored;
 
 UITouch *touch = [touches anyObject];
 
 CGPoint location = [touch locationInView: [touch view]];
 CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
 
 BOOL touchedCard = NO;
 for(Sprite *aSprite in [self children])
 {
 if(([aSprite tag] == kUserCardTag ||
 [aSprite tag] == kDeckCardTag ||
 [aSprite tag] == kFloorCardTag ||
 [aSprite tag] == kComCardTag ||
 [aSprite tag] == kUserGainCardTag || 
 [aSprite tag] == kComGainCardTag) 
 && [(Card *)aSprite isFlipped]) 
 {
 CGSize s = aSprite.contentSize;
 s.width *= aSprite.scale; 
 s.height *= aSprite.scale;
 
 CGRect r = CGRectMake( aSprite.position.x - 
 s.width/2,
 aSprite.position.y-s.height/2,
 s.width, s.height);
 
 if( CGRectContainsPoint( r, convertedLocation ) ) //클릭한 스프라이트 발견 
 {
 
 Card *prevCard = [scratchDictionary valueForKey:@"PreviouslyTouchedCard"];
 if(aSprite == prevCard) //이전카드 그대로 암것도 안함 
 {
 ; 
 } else //이전 카드 축소, 새 카드 확대 
 {
 
 [prevCard scaleDownByTouch]; 
 
 [scratchDictionary setValue:aSprite forKey:@"PreviouslyTouchedCard"]; 
 [(Card *)aSprite scaleUpByTouch];
 
 }
 touchedCard = YES; 
 break; 
 }
 }
 }
 
 if(!touchedCard) //카드가 아닌 다른쪽으로 마우스가 나갔을 경우, 현재 카드 최소화 
 {
 Card *prevCard = [scratchDictionary valueForKey:@"PreviouslyTouchedCard"];
 [prevCard scaleDownByTouch]; 
 [scratchDictionary setValue:nil forKey:@"PreviouslyTouchedCard"]; 
 }
 
 return kEventHandled;
 }
 
 
 - (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 
 //popup은 touchEnabled로 처리하고
 //userTurn도 touchEnabled로 처리하고
 //touchEnabled 는 자체적으로 동작하므로 주석 처리함 kmaku 09/07/02
 //사용자 차례가 아니거나 팝업이 켜져있는경우 터치 이벤트 무시 
 //if(self.isPopupOn || !self.isUserTurn || !self.isTouchEnabled)
 //	return kEventIgnored;
 
 UITouch *touch = [touches anyObject];
 
 CGPoint location = [touch locationInView: [touch view]];
 CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
 
 for(Sprite *aSprite in [self children])
 {
 if(([aSprite tag] == kUserCardTag 
 || [aSprite tag] == kDeckCardTag 
 || [aSprite tag] == kFloorCardTag 
 || [aSprite tag] == kComCardTag 
 || [aSprite tag] == kUserGainCardTag 
 || [aSprite tag] == kComGainCardTag) 
 && [(Card *)aSprite isFlipped]) 
 {
 //NSLog(@"will check loop in");
 //Size Fix
 CGSize s = aSprite.contentSize;
 s.width *= aSprite.scale; 
 s.height *= aSprite.scale;
 
 CGRect r = CGRectMake( aSprite.position.x - 
 s.width/2,
 aSprite.position.y-s.height/2,
 s.width, s.height);
 
 if( CGRectContainsPoint( r, convertedLocation ) )
 {
 Card *initialCard = [scratchDictionary valueForKey:@"InitiallyTouchedCard"]; 
 Card *prevCard = [scratchDictionary valueForKey:@"PreviouslyTouchedCard"]; 
 
 if(aSprite == initialCard && [aSprite tag] == kUserCardTag)
 {
 [self myTurn:(Card *)aSprite];
 [prevCard scaleDownImmediately]; 
 
 } else {
 [prevCard scaleDownByTouch];
 }
 
 
 [scratchDictionary setValue:nil forKey:@"InitiallyTouchedCard"]; 
 [scratchDictionary setValue:nil forKey:@"PreviouslyTouchedCard"]; 
 
 break;
 }			
 }
 }	
 return kEventHandled; 
 }
 */

- (void)checkUnMatchedCardAndDimmedAfterTimes:(int)times
{
	[self performSelector:@selector(checkUnMatchedCardAndDimmed) withObject:nil afterDelay:((float)times * CARD_MOVING_DURATION)];
}

- (void)checkUnMatchedCardAndDimmed
{
	BOOL isMatched = NO;
	for(Card *aCard in [playerUser cardList]){
		isMatched = NO;
		for(Card *fCard in floorCardList){
			if([aCard numberOfCard] == [fCard numberOfCard]){
				//원래 opacity
				[aCard notDimmed];
				isMatched = YES;
				break;
			}			
		}
		//Dimmed
		if(!isMatched)
			[aCard dimmed];
	}
}

- (BOOL)isCardMatched:(Card *)aCard 
{
	BOOL isMatched = NO; 
	for(Card *fCard in floorCardList){
		if([aCard numberOfCard] == [fCard numberOfCard]){
			isMatched = YES;
			break;
		}			
	}
	return isMatched;
}


- (int)userPosCardCount
{
	return [[playerUser cardList] count];
}

- (int)comPosCardCount
{
	return [[playerCom cardList] count];
}

- (Player *)playerUser
{
	return playerUser;
}

- (void)setPlayerUser:(Player *)player
{
	if(playerUser != nil)
		[playerUser release];
	playerUser = player;
}

- (Player *)playerCom
{
	return playerCom;
}

- (void)setPlayerCom:(Player *)player
{
	if(playerCom != nil)
		[playerCom release];
	playerCom = player;
}


- (NSMutableArray *)floorCardList
{
	return floorCardList;
}

- (NSMutableArray *)cardList
{
	return cardList;
}

//짝이 맞는 패를 넣어둠 - throw했을 때 짝이 맞으면 넣어두고 gain한 후 setEmptyMatchedCardList로 비워버리
- (BOOL)addToMatchedCardList:(Card *)aCard
{
	if(![matchedCardList containsObject:aCard]){ //이미 리스트에 있는 카드는 추가로 넣지 않음		
		//이미 카드를 내서 찜되어 있는 카드 목록에 없는 것만 추가함
		if(![matchedCardThrownList containsObject:aCard])
			[matchedCardList addObject:aCard];
		else
			return NO; //찜되어 있는 카드 추가 못함
	}
	
	return YES;
}

- (void)addToMatchedCardThrownList:(Card *)aCard
{
	if(![matchedCardThrownList containsObject:aCard]) //이미 리스트에 있는 카드는 추가로 넣지 않음
		[matchedCardThrownList addObject:aCard];
}

- (void)addToPresentedCardList:(Card *)aCard
{
	if(![presentedCardList containsObject:aCard])
		[presentedCardList addObject:aCard];
}

//짝이 맞는 패를 넣어둔 목록을 비움 - 한 턴의 gain후 수행
- (void)setEmptyMatchedCardList
{
	[matchedCardList removeAllObjects];
	[matchedCardThrownList removeAllObjects];
	[presentedCardList removeAllObjects];
}

//인덱스 값으로 floor에 깔린 카드 가져오기
- (CGPoint)floorCoordWithIndex:(int)index
{
	NSAssert(index >= 0, @"index must be positive");
	NSAssert(index <= 14, @"index must be lower than 15");
	return floorSlotMap[index];
}

//제일 위의 z index를 반환하고 증가시켜 놓는다.
- (int)getNewLastZIndex
{
	return topZIndex++;
}

#pragma mark -
#pragma mark Network Play

//네트웍 플레이 시 섞은 덱 받아 집어넣기 
- (void)addReceivedDeckToScene:(NSArray *)aCardList 
{
	
	[self removeAllCardSprites];
	for(NSNumber *cardNumber in aCardList) 
	{
		Card *aCard = [[Card alloc] initWithSeqNumber:[cardNumber intValue]];
		aCard.scale = NORMAL_SCALE;
		
		[self addChild:aCard z:topZIndex++ tag:kDeckCardTag];
		[aCard setPosition:ccp(150 - topZIndex/8, 170 + topZIndex/8)]; 
		
		[cardList addObject:aCard];
		[aCard release]; 
	}
}

- (void)shuffleCardsData:(int *)seqContainer
{
	//int cardCount = [cardList count]; 
	//int cardData[cardCount]; 
	int i; 
	for(i=0; i<MAX_CARDNUM; i++) 
	{
		seqContainer[i] = [[cardList objectAtIndex:i] seqOfCard]; 
	}
	//return cardData; 
}

- (void)otherPlayerThrowsCardBySeq:(int)cardSeq
{
	[[self cardBySeqNumber:cardSeq fromList:[playerCom cardList]] throwWithCallBackObject:nil selector:nil needGain:YES];
	
	//[self myTurn:[self cardBySeqNumber:cardSeq fromList:[playerCom cardList]]];
}

- (void)otherPlayerGainedCardBySeq:(int)cardSeq 
{
	[playerCom gainCards:[self cardBySeqNumber:cardSeq fromList:[self floorCardList]]]; 
}

- (Card *)cardBySeqNumber:(int)cardSeq fromList:(NSArray *)list 
{
	for(Card *aCard in list)
	{
		if([aCard seqOfCard] == cardSeq)
			return aCard;
	}
	return nil;
}

//자신의 카드가 던져질(floor에) 위치좌표 찾기
- (CGPoint)findFloorCardPosition:(Card *)thrownCard
{
	return [self findFloorCardPosition:thrownCard needGain:NO];
}

//throw할 때 매칭되는 카드가 있으면 match카드 목록에 넣어두는 것 까지 수행
- (CGPoint)findFloorCardPosition:(Card *)thrownCard needGain:(BOOL)needGain
{
	CGPoint cardPos;
	int matchedCardCount = 0; //Match 되는 카드 숫자 저장될 변수
	int minPositionIndex = 0; //빈슬롯 중 최소 슬롯 인덱스 저장할 변수
	int matchedCardPositionIndex = -1; //Match되는 카드 위치 인덱스
	
	BOOL floorSlotOccMap[MAX_FLOOR_SLOT] = {NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO,NO};
	
	//throw한 카드와 floor에 깔린 카드와 일치하는 것이 있는 지 확인함
	for(Card *aCard in floorCardList){
		
		if([aCard numberOfCard] == [thrownCard numberOfCard]){ //짝이 맞는 카드가 있다면
			if(needGain){ //가져갈 카드 체크해 둠
				if([self addToMatchedCardList:aCard]){ //매치목록에 추가해둠
					[self addToMatchedCardThrownList:thrownCard]; //짝이 맞은 경우, 낸(thrown)카드도 그 목록에 추가해둠
				}
			}			
			
			matchedCardPositionIndex = [aCard slotIndex];
			if(aCard != thrownCard) //자기자신이 매칭되는 경우는 matchedCardCount를 증가시키지 않음
				matchedCardCount ++;
		}
		//floor slot 해당 인덱스 채워졌다는 표시함
		floorSlotOccMap[[aCard slotIndex]] = YES;		
	}
	
	if(matchedCardPositionIndex != -1){ //일치하는 카드가 floor에 있는 경우
		cardPos = [self floorCoordWithIndex:matchedCardPositionIndex];
		cardPos = CGPointMake((cardPos.x + (FLOOR_SLIDED_MARGIN * matchedCardCount)), cardPos.y); //일치하는 카드가 1장 이상이면 카드가 중첩된 경우이므로 x좌표를 오른쪽으로 약간 이동한다.
		
		//설정된 slot index
		[thrownCard setSlotIndex:matchedCardPositionIndex];
		
	} else { //일치하는 카드가 floor에 없는 경우
		
		//floor slot 인덱스 중 비어있는 슬롯중 가장 작은 인덱스 찾기
		for(minPositionIndex = 0 ; minPositionIndex < MAX_FLOOR_SLOT ; minPositionIndex++){
			if(!floorSlotOccMap[minPositionIndex])
				break;
		}
		
		NSAssert(minPositionIndex < 15, @"minPositionIndex floor must be lower than 15, No more floor space to allot");
		cardPos = [self floorCoordWithIndex:minPositionIndex];
		
		//설정된 slot index
		[thrownCard setSlotIndex:minPositionIndex];
	}
	
	return cardPos;	
}


#pragma mark -
#pragma mark Composite Logic Actions
////////////////////////////////////////////////////////////////////////////////
//카드 내고 뒤집고 가져오기 시작
////////////////////////////////////////////////////////////////////////////////
- (void)myTurn:(Card *)aCard
{
	self.isTouchEnabled = NO;
	
	if([(GameScene *)[self parent] isMultiplay]) {//멀티플레이 
		/*
		 if([self isUserTurn]) {
		 //자신이 낸 카드가 무엇인지 상대방에게 알려준다. 
		 
		 [currentPlayer checkShakeAndBomb:aCard floorCards:floorCardList];
		 [(NetworkGameScene *)parent thrownCard:aCard];//여기서 parent는 NetworkGameScene
		 }
		 else{
		 //TODO : 멀티플레이시 상대방이 낸 것을 보여준다.
		 //여기서는 패 내는 애니메이션과 패 넘김 애니메이션만 하고 
		 //상대방이 무엇을 먹었는지는 다른 메서드에서 결정한다. 
		 //[aCard throw]; 
		 //[currentPlayer checkShakeAndBomb:aCard floorCards:floorCardList]; 
		 ; 
		 }
		 */
		
		[currentPlayer checkShakeAndBomb:aCard floorCards:floorCardList];
		[(NetworkGameScene *)parent thrownCard:aCard];//여기서 parent는 NetworkGameScene
	} else {// 싱글플레이 
		//먼저 흔들지 여부 확인
		[currentPlayer checkShakeAndBomb:aCard floorCards:floorCardList];		
	}
}
- (void)flipDeckCard
{
	Card *lastCard = [cardList lastObject];
	if(lastCard != nil)
		[lastCard flipFromDeckCallBackObject:self selector:@selector(verifyGainingCard)];
	else 
		NSLog(@"No more deck card to flip");
}

- (void)verifyGainingCard
{
	//가져갈 패가 없으면 본 메소드를 빠져나간다.
	if([matchedCardList count] > 0 && [matchedCardThrownList count] > 0) { 
		
		NSAssert((GameScene *)[self parent] != nil, @"(GameScene *)self.parent must not be nil");
		NSMutableDictionary *monthDictionary = [(GameScene *)[self parent] transCardListPerMonth:matchedCardList];
		NSMutableDictionary *monthThrownDictionary = [(GameScene *)[self parent] transCardListPerMonth:matchedCardThrownList];
		
		for(NSNumber *monthNumber in monthDictionary){
			NSAssert([monthDictionary objectForKey:monthNumber] != nil, @"[monthDictionary objectForKey:monthNumber] must not be null");
			
			if([monthThrownDictionary objectForKey:monthNumber] != nil){ 
				NSArray *gainedFloorCardsPerMonth = [monthDictionary objectForKey:monthNumber];
				switch([gainedFloorCardsPerMonth count]){
					case 1: //바닥에 깔린 매치하는 패가 1인 경우				
						switch([[monthThrownDictionary objectForKey:monthNumber] count]){
							case 1:
								//1) 달을 내고 깔려있는 달을 딴 경우
								//2) 뒤집어서 달이 나왔는데 깔려있는 달을 딴 경우
								//3) 달이 깔려있지 않은데 달을 그냥 내고 뒤집어서 달이 나와 달을 딴 경우(쪽)
								//한장씩 애니메이션
								
								
								break;
							case 2: 
								//1) 달을 내고, 달을 따고나서 뒤집었는데 또 달이 나온 경우 (쌌다)
								NSLog(@"Shit");
								//해당월 다 가져올 리스트에서 제거
								[matchedCardList removeObjectsInArray:gainedFloorCardsPerMonth];
								[matchedCardThrownList removeObjectsInArray:[monthThrownDictionary objectForKey:monthNumber]];
								
								currentPlayer.shitCount += 1; //싼 경우 현재 플레이어 싼 카운트 증가
								
								//쌌다 애니메이션
								[(GameScene *)[self parent] performAnimation:kAnimationShit]; 
								
								break;
							default:
								//오류, 3장 이상 낼 수가 없음 - 낸 카드, 뒤집은 카드 2장이 최대이어야 함 - 만약 조커가 있다면 적용되지 않음
								NSLog(@"Thrown card cannot be greater than 2");
								break;
						}
						break;
					case 2:
						switch([[monthThrownDictionary objectForKey:monthNumber] count]){
							case 1:
								//1)달이 바닥에 2장 깔려 있는데 달을 내서 딴 경우 - 가져올 카드 선택
								//2)달이 바닥에 2장 깔려 있는데 초를 내고 뒤집어 달이 나와 달을 딴 경우 - 가져올 카드 선택
								NSLog(@"Select card from here : %@",gainedFloorCardsPerMonth);
								
								if(currentPlayer == playerUser) {
									//선택해야하는 카드 두장을 다 버리고 다음 팝업에서 didSelectGainigCard: 메소드에서 사용자가 선택한 카드를 다시 matchedCardList에 추가해줌
									[matchedCardList removeObjectsInArray:gainedFloorCardsPerMonth]; 
									//[(GameScene *)[self parent] openPopupWithCardList:gainedFloorCardsPerMonth target:self selector:@selector(didSelectGainigCard:)];
									//[Popup popUpWithTitle:@"Select a card" hasYes:NO hasNo:NO target:self selector:@selector(didSelectGainigCard:)];
									[Popup popUpWithTitle:@"Select a card" card:gainedFloorCardsPerMonth hasYes:NO hasNo:NO target:self selector:@selector(didSelectGainingCard:)];

									return; //더 이상 아래 진행되지 않도록 스톱함 didSelectGainigCard: 메소드에서 받아 계속 진행
								} else {
									// TODO: 임의로 하나 버림 -  A.I.
									[matchedCardList removeObject:[gainedFloorCardsPerMonth lastObject]];
								}
								
								break;
							case 2: 
								//1)달이 바닥에 2장 깔려 있는데 달을 내서 따고 뒤집어서 다시 달이 나온 경우 (따닥)
								NSLog(@"Dadak");
								
								break;
							default:
								//오류, 3장 이상 낼 수가 없음 - 낸 카드, 뒤집은 카드 2장이 최대이어야 함 - 만약 조커가 있다면 적용되지 않음
								NSLog(@"Thrown card cannot be greater than 2");
								break;
						}
						break;
					case 3:
						switch([[monthThrownDictionary objectForKey:monthNumber] count]){
							case 1:
								//1)달이 바닥에 3장 깔려 있는데 달을내서 딴 경우 (한장씩)
								//2)달이 바닥에 3장 깔려 있는데 뒤집어서 달이 나와 딴 경우 (한장씩)
								// TODO: 한장식 애니메이션								
								[self gainPresentedCard];		
								
								break;
							default:
								//오류, 3장을 따 온 경우 2장 이상 낼 수가 없음
								NSLog(@"Thrown card cannot be greater than 1 when you gain 3 cards");
								break;
						}
						break;
					default:
						NSLog(@"Cannot gain all 4 cards");
						break;
				}
			} else {
				//오류, 따먹은 카드는 있는데 낸 카드가 없는 경우
				NSLog(@"[monthThrownDictionary objectForKey:monthNumber] must not be null");
			}
		}
	}
	
	//gainAllMatchedCard는 위 월별 루프가 다 종료되면 한번만 실행되어야 함으로 루프 밖에서 호출 되어야 함
	[self gainAllMatchedCard]; 
}


- (void)gainPresentedCard
{
	Card *presentedCard = [waitingPlayer presentCard];
	//nil인 경우는 줄 카드가 없는 경우
	if(presentedCard != nil)
		[self addToPresentedCardList:presentedCard];
}

- (void)didSelectGainingCard:(NSDictionary *)userInfo
{
	Card *aCard = [userInfo objectForKey:MTPopUpSelectedCardKey];
	NSAssert(aCard != nil , @"[userInfo objectForKey:MTPopUpSelectedCardKey] must not be nil");
	[self addToMatchedCardList:aCard];
	[self verifyGainingCard]; //다시 verify과정을 거침
}


//일반적인 상황일 때 카드가져오기 애니메이션
- (void)gainAllMatchedCard
{	
	if([matchedCardList count] > 0 || [matchedCardThrownList count] > 0 || [presentedCardList count] > 0){
		NSArray *sumArray = [[matchedCardList arrayByAddingObjectsFromArray:matchedCardThrownList] arrayByAddingObjectsFromArray:presentedCardList];
		int i = 0;
		for(i = 0 ; i < [sumArray count] ; i++){
			if(i != ([sumArray count] - 1))
				[currentPlayer gainCards:[sumArray objectAtIndex:i]];
			else
				[currentPlayer gainCards:[sumArray objectAtIndex:i] target:self selector:@selector(calcAndCheckPoint)];
			
			//멀티플레이 + 사용자 턴일때만 얻어온 카드를 날려줍니다 
			if([(GameScene *)[self parent] isMultiplay] && (currentPlayer == playerUser)) 
			{
				[(NetworkGameScene *)parent gainedCard:[sumArray objectAtIndex:i]];
			}
		}
	} else {
		[self calcAndCheckPoint];
	}
}

- (void)calcAndCheckPoint
{
	//점수계산
	[playerUser calcMyPoint];
	[playerCom calcMyPoint];
	
	[currentPlayer checkGoAndStopWithTarget:self selector:@selector(decisionGoAndStop:)];
	
	//floor에 같은 패가 있는 지 확인하여 없으면 dimmed처리
	[self checkUnMatchedCardAndDimmedAfterTimes:0.1];
}

- (void)decisionGoAndStop:(NSDictionary *)userInfo
{
	int popupResult = [[userInfo objectForKey:MTPopUpModalResultKey] intValue];
	if(popupResult == kPopupOKButton) {
		// TODO: Go Animation
		[(GameScene *)[self parent] performAnimation:kAnimationGo]; 
		
		//턴바꾸기 - 게임 계속 진행
		int curGo = [currentPlayer goCount];
		[currentPlayer setGoCount:++curGo]; //고 카운트 증가
		[self turnOver];
		
	} else if(popupResult == kPopupContinue){ //Go - OK이거나 계속 진행이거나
		
		//턴바꾸기 - 게임 계속 진행
		[self turnOver];
		
	} else { //stop
		
		// TODO: Stop Animation
		NSLog(@"Stop this game");
	}
}

////////////////////////////////////////////////////////////////////////////////
//카드 내고 뒤집고 가져오기 끝
////////////////////////////////////////////////////////////////////////////////

//턴 변경
- (void)turnOver
{
	NSLog(@"Turn over at GameLayer");
	
	[self setEmptyMatchedCardList];
	[self setIsUserTurn:![self isUserTurn]]; //턴 변경	
	
	if([self isUserTurn]) { //User player's turn
		NSLog(@"My Turn!");
		//save at the beginning of the user turn
		if(![(GameScene *)[self parent] isMultiplay]) //Do not save in the multiplay mode for now 
			[self saveData]; 
		
		self.isTouchEnabled = YES;
		
	} else { //Opponent player's turn
		
		NSLog(@"Your Turn!");
		
		self.isTouchEnabled = NO;
		
		if([(GameScene *)[self parent] isMultiplay])
			[(NetworkGameScene *)parent turnOver];
		else
			[playerCom performSelector:@selector(startATurn) withObject:nil afterDelay:TURN_CHANGE_GAP];
		//Now it's the other user's turn 
		//Wait the other user's action
	}
}

- (BOOL)isUserTurn
{
	return (currentPlayer == playerUser);
}

- (void)setIsUserTurn:(BOOL)value
{
	currentPlayer = value ? playerUser : playerCom;
	waitingPlayer = !value ? playerUser : playerCom;
}

@end

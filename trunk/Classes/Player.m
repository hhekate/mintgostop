//
//  Player.m
//  GoStop
//
//  Created by Conan Kim on 5/25/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "Player.h"
#import "GameLayer.h"
#import "GameScene.h"

@implementation Player

@synthesize currentPoint;
@synthesize pointAt1;
@synthesize pointAt5;
@synthesize pointAt10;
@synthesize pointAt25;
@synthesize goCount;
@synthesize shakeCount;
@synthesize shitCount;
@synthesize gameMoney;


- (id) init
{
	if(self = [self initWithPlayerNumber:0]){
		
		return self;
	}
	
	return nil;
}

- (id) initWithPlayerNumber:(int)playerNumberValue
{
	if(self = [super init]){
		
		playerNumber = playerNumberValue;
		
		cardList = [[NSMutableArray alloc] init];
		gainedCardList = [[NSMutableArray alloc] init];
				
		[self initSlotMaps];
		[self initLabels];
		
		[self initAllVariables];
		
		gameMoney = 100000; //10만원
		return self;
	} 
	return nil;
}

- (void)dealloc
{
	[cardList release];
	cardList = nil;
	
	[gainedCardList release];
	gainedCardList = nil;
	
	[super dealloc];	
}

- (void)initLabels
{
	int baseW = 0, baseH = 0, baseX = 0, baseY = 0, fSize = 0, span = 0;
	
	switch(playerNumber){
		case 1: //computer
			baseW = 50;
			baseH = 13;
			baseX = 430;
			baseY = 255;
			fSize = 13;
			span = 4;
			break;
		case 0: //user			
		default:
			baseW = 50;
			baseH = 20;
			baseX = 380;
			baseY = 150;
			fSize = 15;
			span = 5;
			break;
	}
	
	scoreLabel = [Label labelWithString:@"0점" dimensions:CGSizeMake(baseW, baseH) alignment:UITextAlignmentRight fontName:@"Courier" fontSize:fSize];
	goLabel = [Label labelWithString:@"0고" dimensions:CGSizeMake(baseW, baseH) alignment:UITextAlignmentRight fontName:@"Courier" fontSize:fSize];
	shakeLabel = [Label labelWithString:@"0흔" dimensions:CGSizeMake(baseW, baseH) alignment:UITextAlignmentRight fontName:@"Courier" fontSize:fSize];
	shitLabel = [Label labelWithString:@"0뻑" dimensions:CGSizeMake(baseW, baseH) alignment:UITextAlignmentRight fontName:@"Courier" fontSize:fSize];
	
	switch(playerNumber){
		case 0: //user			
			[scoreLabel setPosition:ccp(baseX, baseY)];
			[goLabel setPosition:ccp(baseX + baseW + span, baseY)]; //오른쪽으로 한블럭
			[shakeLabel setPosition:ccp(baseX, baseY + baseH + span)]; //오른쪽으로 한블럭
			[shitLabel setPosition:ccp(baseX + baseW + span, baseY + baseH + span)]; //오른쪽으로 한블럭			
			break;
		case 1: //computer
		case 2: //opponent
		default:
			[scoreLabel setPosition:ccp(baseX, baseY)];
			[goLabel setPosition:ccp(baseX , baseY + baseH + span)]; //위로 한블럭
			[shakeLabel setPosition:ccp(baseX , baseY + ((baseH + span) * 2))]; //위로 두블럭
			[shitLabel setPosition:ccp(baseX , baseY + ((baseH + span) * 3))]; //위로 세블럭
			
			break;
	}
	
	[self addChild:scoreLabel];
	[self addChild:goLabel];
	[self addChild:shakeLabel];
	[self addChild:shitLabel];
	
}

- (void)initSlotMaps
{
	switch(playerNumber){
		case 0: //User		
			gainedCardSlotMap[idx25pt] = CGPointMake(15 ,88); //광
			gainedCardSlotMap[idx10pt] = CGPointMake(15 ,53); //10
			gainedCardSlotMap[idx5pt] = CGPointMake(15 ,18); //5
			gainedCardSlotMap[idx1pt] = CGPointMake(150 ,18); //피			
			break;
		case 1: //Computer
		case 2: //Opponent
		default:
			gainedCardSlotMap[idx25pt] = CGPointMake(15, 265); //광
			gainedCardSlotMap[idx10pt] = CGPointMake(80 ,300); //10
			gainedCardSlotMap[idx5pt] = CGPointMake(80, 265); //5
			gainedCardSlotMap[idx1pt] = CGPointMake(190, 265); //피			
			break;
	}
}

- (CGPoint)gainCardBaseCoordWithPoint:(CardPoint)point
{
	/*
	mk25point = 25, //광
	mk20point = 20, //비광
	mk10point = 10, //10점
	mk5point = 5, //5점
	mk2point = 2, //쌍피
	mk1point = 1, //피
	*/
	
	switch(point){
		case mk25point:
			return gainedCardSlotMap[idx25pt];
			break;
		case mk10point:
			return gainedCardSlotMap[idx10pt];
			break;
		case mk5point:
			return gainedCardSlotMap[idx5pt];
			break;
		case mk1point:
		default:
			return gainedCardSlotMap[idx1pt];
			break;
	}
}

- (void)startATurn
{
	switch(playerNumber){
		case 0: //user player
			break;
		case 2: //network opp player
			break;
		case 1: //computer player
		default: //AI is needed			
			if([cardList count] > 0){
				BOOL matched = NO;
				for(Card *aCard in cardList){
					if([(GameLayer *)[aCard parent] isCardMatched:aCard]){
						[(GameLayer *)[aCard parent] myTurn:aCard];
						matched = YES;
						break;
					}
				}
				
				if(!matched){
					[(GameLayer *)parent myTurn:[[self cardList] objectAtIndex:0]];	
				}
			} else {
				//Computer has no card!
				NSLog(@"GOSTOP Error : com has no card");
			}			
			break;
	}	
}

- (void)gainCards:(Card *)gainedCard
{
	[self gainCards:gainedCard target:nil selector:nil];
}


- (void)gainCards:(Card *)gainedCard target:(id)target selector:(SEL)selector
{
	int samePointCardCount = 0;	
		
	CGPoint cardBasePos = [self gainCardBaseCoordWithPoint:[gainedCard pointOfCard]];
	
	for(Card *aCard in [self gainedCardList]){
		if([aCard pointOfCard] == [gainedCard pointOfCard]){
			samePointCardCount++;
		}		
	}
	//NSLog(@"samePointCardCount %d : %d : %d",playerNumber, [self pointOfCard], samePointCardCount);
	
	int newY = 0;
	
	if([gainedCard pointOfCard] == mk1point){ //1점짜리일경우 5장이 넘어가면 위로 쌓는다
		newY = cardBasePos.y + (18 * (samePointCardCount / 5));
	} else {
		newY = cardBasePos.y;
	}
	
	int newX = 0;
	
	if([gainedCard pointOfCard] == mk1point){ //1점짜리일경우 5장이 넘어가면 위로 쌓는다
		newX = cardBasePos.x + (GAIN_SLIDED_MARGIN * (samePointCardCount % 5));
	} else {
		newX = cardBasePos.x + GAIN_SLIDED_MARGIN * samePointCardCount;
	}
	
	
	[gainedCard flyingCardToX: newX
							Y: newY
						scale: SMALL_SCALE
					 duration: CARD_MOVING_DURATION
					 withFlip: NO
					   object:target
					 callBack:selector];
	
	[gainedCard setSlotIndex:-1];
	
	//태그 체인지
	if(playerNumber == 0) //user
		[gainedCard changeTag:kUserGainCardTag];
	else //computer, opponent
		[gainedCard changeTag:kComGainCardTag];
		
}


//점수 계산하여 반환
- (int)calcMyPoint
{	
	int countAt1 = 0, countAt5 = 0, countAt10 = 0, countAt25 = 0;
	
	pointAt25 = 0;
	pointAt10 = 0;
	pointAt5 = 0;
	pointAt1 = 0;
	
	for(Card *aCard in gainedCardList){
		switch([aCard pointOfCard]){
			case(mk25point): //광
				if(++countAt25 >= 3){ //광은 3장 이상부터 점수로 여김
					pointAt25 = countAt25; //3장 모이면 3점 -> 비광이 낀 경우는 1점
				}
				break;
			case(mk10point):
				if(++countAt10 >= 5){ //10점짜리는 10장부터 1점으로 여김
					pointAt10 = countAt10 - 4;
				}
				break;
			case(mk5point):
				if(++countAt5 >= 5){ //10점짜리는 10장부터 1점으로 여김
					pointAt5 = countAt5 - 4;
				}
				break;
			case(mk1point):
				if(++countAt1 >= 10){ //피는 10장부터 1점으로 여김
					pointAt1 = countAt1 - 9;
				}
				break;
		}
	}
	
	[self setCurrentPoint:pointAt25 + pointAt10 + pointAt5 + pointAt1];
	
	NSLog(@"%@'s Count is 25:%d, 10:%d, 5:%d, 1:%d",self, countAt25,countAt10,countAt5,countAt1);
	NSLog(@"%@'s Point is 25:%d, 10:%d, 5:%d, 1:%d, totalPoint:%d",self, pointAt25,pointAt10,pointAt5,pointAt1,currentPoint);
	

	return currentPoint;
}

//고/스톱 결정
//target은 반드시 GameScene의 child인 GameLayer이어야 함
- (void)checkGoAndStopWithTarget:(id)target selector:(SEL)selector
{
	//7점 이상이고, 먼저 고 했던 점수 이상이면 고 & 스톱 선택할 수 있음
	if(currentPoint >= GOSTOP_POINT && currentPoint > prevMaxPoint){
		if(playerNumber == 0){ 
			//target은 반드시 GameScene의 child인 GameLayer이어야 함
			[Popup popUpWithTitle:@"Go 하시겠습니까?" hasYes:YES hasNo:YES target:target selector:selector];
		} else { //컴퓨터
			// TODO: A.I Go & stop 선택
			//target은 반드시 GameScene의 child인 GameLayer이어야 함
			[Popup popUpWithTitle:@"Go 하시겠습니까?" hasYes:YES hasNo:YES target:target selector:selector];
		}
		
		if(currentPoint > prevMaxPoint) prevMaxPoint = currentPoint;
	} else { //고스톱 상황 아니면 계속 진행
		if([target respondsToSelector:selector]){
			[target performSelector:selector withObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kPopupContinue] forKey:MTPopUpModalResultKey]];
		}
	}
}

//흔들거나 폭탄여부 체크
- (void)checkShakeAndBomb:(Card *)thrownCard floorCards:(NSMutableArray *)floorCardList
{
	NSAssert(thrownCard != nil, @"thrownCard must not be nil");
	//1) 판 시작 후 흔들 지 여부 (thrownCard == nil)
	//2) 깔린 판에 먹을 패가 없을 때 흔들지 여부 
	//3) 칼린 판에 먹을 패가 있을 때 폭탄 투하할 지 여부
	
	//터치한 패가 3장 이상이면 흔들지 여부를 결정한다.
	
	//NSAssert((GameScene *)self.parent != nil, @"(GameScene *)self.parent must not be nil");
	//NSMutableDictionary *monthDictionary = [(GameScene *)self.parent transCardListPerMonth:cardList];
	
	
	NSMutableArray *matchedCardList = [[NSMutableArray alloc] init];
	
	for(Card *aCard in  cardList){
		if([thrownCard numberOfCard] == [aCard numberOfCard]){
			[matchedCardList addObject:aCard];
		}
	}
	
	if([matchedCardList count] >= 3){ //3장 이상 갖고 있고
		BOOL isExistMatchedCard = NO;
		
		//바닥에 나머지 한장이 있는 지 체크
		for(Card *aCard in floorCardList){
			if([thrownCard numberOfCard] == [aCard numberOfCard]){
				isExistMatchedCard = YES;
				break;
			}
		}
		
		NSMutableDictionary *myUserInfo = [[[NSMutableDictionary alloc] init] autorelease];
		[myUserInfo setObject:thrownCard forKey:MTPopUpSelectedCardKey];
		
		if(isExistMatchedCard){ //바닥에 나머지 한장이 있으면 폭탄 묻기
			//폭탄으로 내시겠습니까? - YES:세장 다 내기 , NO:한장만 내기
			
			// case A
			if(!thrownCard.isShaked){ //아직흔들지 않은 경우는 폭탄으로 던질 지 물어봄
				[Popup popUpWithTitle:@"Throw all Cards as a bomb?" //폭탄으로 던지시겠습니까?
								 card:matchedCardList
							   hasYes:YES 
								hasNo:YES
							   target:self 
							 selector:@selector(throwCardsAsBomb:) 
							 userInfo:myUserInfo];
			} else { //이미 흔든 경우는 무조건 폭탄으로 던짐
				[self throwCards:matchedCardList];
			}
			
			// case B - code blocking popup
			
			/*
			if([Popup popUpWithTitle:@"Throw all Cards as a bomb?" card:matchedCardList hasYes:YES hasNo:NO gameScene:(GameScene *)[self parent]]){ //If user cliked YES
				//Throw all cards at matchedCardList(NSArray)
				NSLog(@"All cards thrown - bomb");
				[self throwCards:matchedCardList];
			} else { //If user clicked NO
				//Do nothing 
				NSLog(@"No bomb card");
				[thrownCard throwWithCallBackObject:[(GameScene *)self.parent getGameLayer] selector:@selector(flipDeckCard)]; 
			}
			*/
					
			
		} else { //바닥에 나머지 한장이 없으면 흔들기 묻기 (흔든 후에는 나중에 바닥에 카드가 있으면 무조건 폭탄으로 던져야 함)
			//흔드시겠습니까? - YES:Check Shaked card, NO:nothing
			//이미 흔든 카드는 체크하지 않는다.
			if(!thrownCard.isShaked){
				[Popup popUpWithTitle:@"흔드시겠습니까?" 
								 card:matchedCardList
							   hasYes:YES 
								hasNo:YES
							   target:self 
							 selector:@selector(shakeCards:) 
							 userInfo:myUserInfo];
				
			} else { //이미흔든카드는 그냥 낸다.
				[thrownCard throwWithCallBackObject:[(GameScene *)self.parent getGameLayer] selector:@selector(flipDeckCard)]; //제일 마지막 장을 던진 다음에는 flipDeckCard를 수행한다.
			}	
		}
	} else { //3장 이상이 아닌 경우 그냥 내기
		[thrownCard throwWithCallBackObject:[(GameScene *)self.parent getGameLayer] selector:@selector(flipDeckCard)]; //제일 마지막 장을 던진 다음에는 flipDeckCard를 수행한다.
	}
	
	[matchedCardList release];	
}

- (void)throwCardsAsBomb:(NSDictionary *)userInfo
{
	int modalResult = [[userInfo objectForKey:MTPopUpModalResultKey] intValue];
	if(modalResult == kPopupOKButton){ //폭탄일 경우
		//이미 흔든 카드일 경우는 흔들지 않는다.
		if(![[[userInfo objectForKey:MTPopUpCardListKey] objectAtIndex:0] isShaked]){
			self.shakeCount += 1; //폭탄도 흔드는 케이스임
		}
		NSLog(@"Bomb");
		//폭탄 애니메이션
		[(GameScene *)self.parent performAnimation:kAnimationBomb];
		[self throwCards:[userInfo objectForKey:MTPopUpCardListKey]];
		//한장씩
		[[(GameScene *)self.parent getGameLayer] gainPresentedCard];
		
	} else { //폭탄 아닐 경우
		NSLog(@"Didn't select Bomb");
		[[userInfo objectForKey:MTPopUpSelectedCardKey] throwWithCallBackObject:[(GameScene *)self.parent getGameLayer] selector:@selector(flipDeckCard)]; 
	}
}

- (void)throwCards:(NSMutableArray *)throwingCardList
{
	if([throwingCardList count] > 0){ //카드가 한장 이상일 때
		int i = 0;
		for(i = 0 ; i < [throwingCardList count] - 1 ; i++){
			[[throwingCardList objectAtIndex:i] throw]; //카드가 여러장이면 마지막 장을 제외하곤 그냥 throw만한다.
		}
		[[throwingCardList objectAtIndex:i] throwWithCallBackObject:[(GameScene *)self.parent getGameLayer] selector:@selector(flipDeckCard)]; //제일 마지막 장을 던진 다음에는 flipDeckCard를 수행한다.
	}
}

- (void)shakeCards:(NSDictionary *)userInfo
{
	int modalResult = [[userInfo objectForKey:MTPopUpModalResultKey] intValue];
	if(modalResult == kPopupOKButton){ //흔들었을 경우
		NSLog(@"Shaking");
		//흔들기 애니메이션
		//[(GameScene *)self.parent performAnimation:kAnimationOtherThree];
		self.shakeCount += 1; 
		//세장 모드 Shaked 체크, 카드는 내지 않음
		for(Card *aCard in [userInfo objectForKey:MTPopUpCardListKey]){
			//원래 위치로 되돌리기 - (shaking mark달고-optional)
			[aCard setIsShaked:YES];
			[self possessCard:aCard];
			[(GameScene *)self.parent getGameLayer].isTouchEnabled = YES; //턴은 바뀌지 않고 계속 카드를 낼 수 있는 상태로 처리
		}
	} else { //폭탄 아닐 경우
		NSLog(@"Didn't Shake Cards");
		[[userInfo objectForKey:MTPopUpSelectedCardKey] throwWithCallBackObject:[(GameScene *)self.parent getGameLayer] selector:@selector(flipDeckCard)]; 
	}
}

//카드 받기
- (void)possessCard:(Card *)givenCard
{
	switch(playerNumber){
		case 0: //Me player
			[givenCard flyingCardToX: (270 + ((45) * (givenCard.slotIndex % 5)))
								   Y: (105 - ((givenCard.slotIndex / 5) * 70))
							   scale:LARGE_SCALE
							duration:CARD_MOVING_DURATION
							withFlip:YES];
			break;
		case 1: //Op player
		default:
			[givenCard flyingCardToX: (320 + ((22) * (givenCard.slotIndex % 5)))
								   Y: (300 - ((givenCard.slotIndex/5) * 30))
							   scale:TINY_SCALE
							duration:CARD_MOVING_DURATION
							withFlip:NO];
			break;
	}	
	//태그 체인지
	[givenCard changeTag:kUserCardTag];
}


- (void)initAllVariables
{
	[cardList removeAllObjects];
	[gainedCardList removeAllObjects];
	
	prevMaxPoint = 0; //previous Point 중 가장 컷던 점수 1고이상후 계속 Go를 할 수 있는 지 여부 판단하기 위해
	
	[self setGoCount:0]; //Go count 이니셜라이징
	[self setCurrentPoint:0]; //점수 이니셜라이징
}


- (NSMutableArray *)cardList;
{
	return cardList;
}

- (NSMutableArray *)gainedCardList
{
	return gainedCardList;
}

- (int)playerNumber
{
	return playerNumber;
}

- (void)setCurrentPoint:(int)value
{
	NSAssert(scoreLabel != nil, @"scoreLabel must not be nil");
	currentPoint = value;
	if(currentPoint < 0) currentPoint = 0;
	[scoreLabel setString:[NSString stringWithFormat:@"%d점", currentPoint]];	
}

- (void)setGoCount:(int)value
{
	NSAssert(goLabel != nil, @"goLabel must not be nil");
	goCount = value;
	[goLabel setString:[NSString stringWithFormat:@"%d고",goCount]];	
}

- (void)setShakeCount:(int)value
{
	NSAssert(shakeLabel != nil, @"shakeLabel must not be nil");
	shakeCount = value;
	[shakeLabel setString:[NSString stringWithFormat:@"%d흔",shakeCount]];	
	
}

- (void)setShitCount:(int)value
{
	NSAssert(shitLabel != nil, @"shitLabel must not be nil");
	shitCount = value;
	[shitLabel setString:[NSString stringWithFormat:@"%d뻑",shitCount]];	
}

- (void)setGameMoney:(unsigned int)value
{
	NSAssert(gameMoneyLabel != nil, @"gameMoneyLabel must not be nil");
	gameMoney = value;
	[gameMoneyLabel setString:[NSString stringWithFormat:@"%d칩",gameMoney]];	
}

//피 한장 주기
- (Card *)presentCard
{
	for(Card *aCard in gainedCardList){
		if([aCard pointOfCard] == mk1point){
			return aCard;
		}
	}
	return nil; //피 없음
}

//description overriding
- (NSString *)description
{
	if(playerNumber == 0) //사용자
		return @"User";
	else if(playerNumber == 1) //computer
		return @"Computer";
	else if(playerNumber == 2) //Opponent
		return @"Opponent";
	else 
		return @"Unknown";
}




@end

//
//  Card.m
//  GoStop
//
//  Created by Conan Kim on 5/25/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "Card.h"
#import "GameLayer.h"
#import "SunLayer.h"

@implementation Card

@synthesize frontTextureFile; 
@synthesize isFlipped; 
@synthesize isClicked;
@synthesize isShaked;
@synthesize scheduledAction; 
@synthesize slotIndex;
@synthesize indexOfCard; 
@synthesize pointOfCard;


- (id)initWithSeqNumber:(int)seqNumber 
{
	if(self = [super initWithFile:@"back.jpg"]) {
		
		self.frontTextureFile = [NSString stringWithFormat:@"%02d.jpg", seqNumber];
		self.tag = kDeckCardTag; 
		
		[self setSeqOfCard:seqNumber];
		numberOfCard = ((seqNumber - 1) / 4) + 1;								//카드숫자번호
		slotIndex = -1;															//슬롯번호 (각 카드의 tag값에 따라 다른 값으로 사용됨)
		isFlipped = NO;
		isClicked = NO;
		isShaked = NO;
		
		switch((seqNumber - 1) % 4){
			case 0:
				switch(numberOfCard){
					case 1: //일광
					case 3: //삼광
					case 8: //팔광
					case 11: //똥광
						pointOfCard = mk25point;
						break;
					case 12: //비광
						pointOfCard = mk25point;
						break;
					default: //일반10점
						pointOfCard = mk10point;
						break;
				}
				break;
			case 1:
				switch(numberOfCard){
					case 8: //팔 고도리
						pointOfCard = mk10point;
						break;
					case 11: //똥 쌍피
						pointOfCard = mk1point;
						break;
					case 12: //비 나가리
						pointOfCard = mk10point;
						break;
					default: //일반5점
						pointOfCard = mk5point;
						break;
				}					
				break;
			case 2:
				switch(numberOfCard){
					case 12: //비 나가리5
						pointOfCard = mk5point;
						break;
					default: //일반 피
						pointOfCard = mk1point;
						break;
				}
				break;
			case 3:
				switch(numberOfCard){
					case 12: //비 쌍피
						pointOfCard = mk1point;
						break;
					default: //일반 피
						pointOfCard = mk1point;
						break;
				}
				break;
		}		
		return self;
	} 
	return nil;
}

- (int)numberOfCard
{
	return numberOfCard;
}

- (void)setNumberOfCard:(int)value
{
	numberOfCard = value;
}

- (int)seqOfCard
{
	return seqOfCard;
}

- (void)setSeqOfCard:(int)value
{
	seqOfCard = value;
}


- (void)moveToUserAfterTimes:(int)times
{
	if(times == 0){
		[self moveToUser];
	} else {
		[self performSelector:@selector(moveToUser) withObject:nil afterDelay:((float)times * CARD_MOVING_DURATION)];
	}
}

//사용자가 들고 있는 곳으로 이동(주로 데크로 부터)
- (void)moveToUser
{	
	self.slotIndex = [(GameLayer *)self.parent userPosCardCount];
	
	[self flyingCardToX: (270 + ((45) * (self.slotIndex % 5)))
					  Y: (105 - ((self.slotIndex / 5) * 70))
				  scale:LARGE_SCALE
			   duration:CARD_MOVING_DURATION
			   withFlip:YES];
	[self setIsFlipped:YES];
	//태그 체인지
	[self changeTag:kUserCardTag];
}

- (void)moveToComAfterTimes:(int)times
{
	if(times == 0){
		[self moveToCom];
	} else {
		[self performSelector:@selector(moveToCom) withObject:nil afterDelay:((float)times * CARD_MOVING_DURATION)];
	}
}

//컴퓨터가 들고 있는 곳으로 이동(주로 데크로 부터)
- (void)moveToCom
{	
	self.slotIndex = [[[(GameLayer *)[self parent] playerCom] cardList] count];
	[self flyingCardToX: (320 + ((22) * (self.slotIndex % 5)))
					  Y: (300 - ((self.slotIndex/5) * 30))
				  scale:TINY_SCALE
			   duration:CARD_MOVING_DURATION
			   withFlip:NO];
	
	//태그 체인지
	[self changeTag:kComCardTag];
}

- (void)moveToFloorAfterTimes:(int)times
{
	if(times==0){
		[self moveToFloor];
	} else {
		[self performSelector:@selector(moveToFloor) withObject:nil afterDelay:((float)times * CARD_MOVING_DURATION)];
	}
}


//Floor에 깔음 (데크로 부터 순차적으로 - scheduler)
- (void)moveToFloor
{
	//matched Card list (needGain : NO) 에 넣어두지 않는다.
	[self throwWithCallBackObject:nil selector:nil needGain:NO];
}


//플레이어 소유한 카드를 낸다.
- (void)throw
{
	//matched Card list (needGain : NO) 에 넣어둔다.
	[self throwWithCallBackObject:nil selector:nil];
}

- (void)throwWithCallBackObject:(id)object selector:(SEL)callBack
{
	//matched Card list (needGain : NO) 에 넣어둔다.
	[[SoundManager sharedManager] throwSound];
	[self throwWithCallBackObject:object selector:callBack needGain:YES];
}


//Deck에서 카드를 뒤집는다.
- (void)flipFromDeck
{
	//matched Card list (needGain : NO) 에 넣어둔다.
	[self flipFromDeckCallBackObject:nil selector:nil];
}

- (void)flipFromDeckCallBackObject:(id)object selector:(SEL)callBack
{
	//matched Card list (needGain : NO) 에 넣어둔다.
	[self throwWithCallBackObject:object selector:callBack needGain:YES];
}

- (void)throwWithCallBackObject:(id)object selector:(SEL)callBack needGain:(BOOL)needGain
{
	BOOL withFlip = NO;
	
	if(!isFlipped) withFlip = YES;												//throw할 때는 카드를 무조건 뒤집니다.(앞면이 나오도록 한다.)
	
	[self setIsFlipped:YES];
	CGPoint cardPos = [(GameLayer *)[self parent] findFloorCardPosition:self needGain:needGain];
	
	[self flyingCardToX: cardPos.x
					  Y: cardPos.y
				  scale:NORMAL_SCALE
			   duration:CARD_MOVING_DURATION
			   withFlip:withFlip
				 object:object
			   callBack:callBack];
	
	//태그 체인지
	[self changeTag:kFloorCardTag];
	
	isClicked = NO;
}

- (void)scaleDownImmediately
{
	if(isClicked == YES) {
		float scale; 
		switch(self.tag) 
		{
			case kUserCardTag:
				scale = LARGE_SCALE; 
				break;
			case kUserGainCardTag:
				scale = SMALL_SCALE; 
				break;
			case kComGainCardTag:
				scale = SMALL_SCALE; 
				break;
			case kFloorCardTag: 
				scale = NORMAL_SCALE; 
				break; 
			default:
				return;
		}
		//id moveAction	= [MoveTo actionWithDuration:CARD_DOWN_DURATION position:ccp(self.position.x, self.position.y - 20)];	
		id downAction	= [ScaleTo actionWithDuration:0.1 scaleX:scale scaleY:scale];
		
		//[self runAction:moveAction];
		[self runAction:downAction];
	}
	isClicked = NO;
	
	[parent reorderChild:self z:self.indexOfCard]; 
}

- (void)scaleDownByTouch
{
	if(isClicked == YES) {
		float scale; 
		switch(self.tag) 
		{
			case kUserCardTag:
				scale = LARGE_SCALE; 
				break;
			case kUserGainCardTag:
				scale = SMALL_SCALE; 
				break;
			case kComGainCardTag:
				scale = SMALL_SCALE; 
				break;
			case kFloorCardTag: 
				scale = NORMAL_SCALE; 
				break; 
			default:
				return;
		}
		//id moveAction	= [MoveTo actionWithDuration:CARD_DOWN_DURATION position:ccp(self.position.x, self.position.y - 20)];	
		id downAction	= [ScaleTo actionWithDuration:CARD_DOWN_DURATION scaleX:scale scaleY:scale];
		
		//[self runAction:moveAction];
		[self runAction:downAction];
	}
	isClicked = NO;
	
	[parent reorderChild:self z:self.indexOfCard]; 
}	

- (void)scaleUpByTouch
{
	self.indexOfCard = [self zOrder];
	NSLog(@"index of card : %d", self.indexOfCard); 
	[parent reorderChild:self z:1000]; 
	
	if(isClicked == NO){
		float scale; 
		switch(self.tag) 
		{
			case kUserCardTag:
				scale = LARGER_SCALE; 
				break;
			case kUserGainCardTag:
				scale = LARGE_SCALE; 
				break;
			case kComGainCardTag:
				scale = LARGE_SCALE; 
				break;
			case kFloorCardTag: 
				scale = LARGE_SCALE; 
				break; 
			default:
				return;
		}
		//id moveAction	= [MoveTo actionWithDuration:CARD_UP_DURATION position:ccp(self.position.x, self.position.y + 20)];	
		id upAction		= [ScaleTo actionWithDuration:CARD_UP_DURATION scaleX:scale scaleY:scale];
		
		//[self runAction:moveAction];
		[self runAction:upAction];
	}
	isClicked = YES;
	
}

//패를 선택하기위해 클릭다운하는 순간 패를 들어 올린다.
- (void)putUp
{
	if(isClicked == NO){
		id moveAction	= [MoveTo actionWithDuration:CARD_UP_DURATION position:ccp(self.position.x, self.position.y + 20)];	
		id upAction		= [ScaleTo actionWithDuration:CARD_UP_DURATION scaleX:self.scaleX*1.6 scaleY:self.scaleY*1.6];
		
		[self runAction:moveAction];
		[self runAction:upAction];
	}
	isClicked = YES;
}

- (void)putDown
{
	if(isClicked == YES) {
		id moveAction	= [MoveTo actionWithDuration:CARD_UP_DURATION position:ccp(self.position.x, self.position.y - 20)];	
		id downAction	= [ScaleTo actionWithDuration:CARD_UP_DURATION scaleX:self.scaleX*0.625 scaleY:self.scaleY*0.625];
		
		[self runAction:moveAction];
		[self runAction:downAction];
	}
	isClicked = NO;
}



//Call Composite Action
- (void)flyingCardToX:(int)x Y:(int)y scale:(float)scale duration:(float)duration withFlip:(BOOL)withFlip
{
	[self flyingCardToX:x Y:y scale:scale duration:duration withFlip:withFlip object:nil callBack:nil];
}

- (void)flyingCardToX:(int)x Y:(int)y scale:(float)scale duration:(float)duration withFlip:(BOOL)withFlip object:(id)object callBack:(SEL)callBack
{
	self.indexOfCard = [(GameLayer *)[self parent] getNewLastZIndex];
	[[self parent] reorderChild:self z:self.indexOfCard];
	
	[self runAction:[ScaledFlipMoveTo actionWithDuration:duration position:ccp(x, y) scale:scale withFlip:withFlip object:object callBack:callBack]];
	[self setIsFlipped:withFlip];
	[self notDimmed]; //밝기를 오리지날로 바꾼다.
}

- (void)performScheduledAction
{
	[self runAction:self.scheduledAction];
	//[self unschedule:@selector(performScheduledAction)];
	NSLog(@"performing scheduled action");
}

- (Action *)flipAction
{
	float currentScale = self.scale;
	id flipAction = [ScaleTo actionWithDuration:0.2 scaleX:0.0 scaleY:currentScale];
	
	Animation* animation = [Animation animationWithName:@"changeTexture" delay:0.0];
	[animation addFrameWithFilename:self.frontTextureFile];
	id textureAction = [Animate actionWithAnimation: animation];
	
	id nextAction = [ScaleTo actionWithDuration:0.2 scaleX:currentScale scaleY:currentScale]; 
	
	//구성된 액션 전체 길이가 1초가 넘지 않으면 모든게 순식간에 진행되어버림 
	id timeFiller = [ScaleTo actionWithDuration:0.6 scaleX:currentScale scaleY:currentScale]; 
	return [Repeat actionWithAction:[Sequence actions:flipAction, textureAction, nextAction, timeFiller, nil] times:1]; 
}

- (void)flipCardWithDelay:(float)delay
{
	[self performSelector:@selector(flipCard) withObject:nil afterDelay:delay+1]; 
	//[self schedule:@selector(flipCard) interval:delay+1];
}

- (void)flipCard
{
	if(!self.isFlipped) //뒤집히지 않았을 때만 뒤집는다. 
	{
		[self runAction:[self flipAction]];
		self.isFlipped = YES;
	}
}

//카드가 속해 있던 기존 array에서 제거하고 Tag에 맞는 새로운 array에 add를 수행한다.
- (void)changeTag:(CardTag)newTag
{	
	//기존 카드 리스트에서 제거
	[self removeSelfFromPreList];
	//새로운 테그값 부여
	[self setTag:newTag];
	//새로운 카드 리스트에 추가
	[self addSelfToNewList];
}

- (void)dimmed
{
	[self runAction:[TintTo actionWithDuration:0.2 red:140 green:140 blue:140]];
}

- (void)notDimmed
{
	[self runAction:[TintTo actionWithDuration:0.2 red:255 green:255 blue:255]];
}

- (void)removeSelfFromPreList
{	
	//기존 리스트에서 제거 //컴퓨터 카드와 Deck카드는 뒤집어서 throw함,
	switch([self tag]){
		case kUserCardTag: //사용자가 들고 있는 화투
			[[[(GameLayer *)[self parent] playerUser] cardList] removeObject:self];
			break;
		case kComCardTag: //컴퓨터가 들고 있는 화투
			[[[(GameLayer *)[self parent] playerCom] cardList] removeObject:self];
			break;
		case kUserGainCardTag: //사용자가 딴 화투
			[[[(GameLayer *)[self parent] playerUser] gainedCardList] removeObject:self];
			break;
		case kComGainCardTag: //컴퓨터가 딴 화투
			[[[(GameLayer *)[self parent] playerCom] gainedCardList] removeObject:self];
			break;
		case kFloorCardTag: //판에 깔려 있는 화투
			[[(GameLayer *)[self parent] floorCardList] removeObject:self];
			break;
		case kDeckCardTag: //데크에 아직 뒤집지 않은 화투
			[[(GameLayer *)[self parent] cardList] removeObject:self];
			break;
		default:
			//Do nothing
			break;
	}
}

- (void)addSelfToNewList
{
	//기존 리스트에서 제거 //컴퓨터 카드와 Deck카드는 뒤집어서 throw함,
	switch([self tag]){
		case kUserCardTag: //사용자가 들고 있는 화투
			[[[(GameLayer *)[self parent] playerUser] cardList] addObject:self];
			break;
		case kComCardTag: //컴퓨터가 들고 있는 화투
			[[[(GameLayer *)[self parent] playerCom] cardList] addObject:self];
			break;
		case kUserGainCardTag: //사용자가 딴 화투
			[[[(GameLayer *)[self parent] playerUser] gainedCardList] addObject:self];
			break;
		case kComGainCardTag: //컴퓨터가 딴 화투
			[[[(GameLayer *)[self parent] playerCom] gainedCardList] addObject:self];
			break;
		case kFloorCardTag: //판에 깔려 있는 화투
			[[(GameLayer *)[self parent] floorCardList] addObject:self];
			break;
		case kDeckCardTag: //데크에 아직 뒤집지 않은 화투
			[[(GameLayer *)[self parent] cardList] addObject:self];
			break;
		default:
			//Do nothing
			break;
	}
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<Card numberOfCard:%d seqOfCard:%d>",numberOfCard, seqOfCard];
}

- (NSDictionary *)dictionaryToSave 
{
	NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:seqOfCard], @"seqOfCard", 
						   //[NSNumber numberWithInt:numberOfCard], @"numberOfCard", 
						   //[NSNumber numberWithInt:cardStatus], @"cardStatus", 
						   //[NSNumber numberWithInt:slotIndex], @"slotIndex", 
						   [NSNumber numberWithInt:tag], @"tag", 
						   //[NSNumber numberWithBool:isFlipped], @"isFlipped", 
						   //[NSNumber numberWithBool:isClicked], @"isClicked", 
						   //[NSNumber numberWithBool:isShaked], @"isShaked", 
						   //frontTextureFile, @"frontTextureFile", 
						   nil];
	return aDict; 
}

- (id)initWithDictionary:(NSDictionary *)cardDictionary 
{
	self = [self initWithSeqNumber:[[cardDictionary valueForKey:@"seqOfCard"] intValue]]; 
	//numberOfCard = [[cardDictionary valueForKey:@"numberOfCard"] intValue]; 
	//cardStatus = [[cardDictionary valueForKey:@"cardStatus"] intValue]; 
	//slotIndex = [[cardDictionary valueForKey:@"slotIndex"] intValue]; 
	tag = [[cardDictionary valueForKey:@"tag"] intValue]; 
	//isFlipped = [[cardDictionary valueForKey:@"isFlipped"] boolValue]; 
	//isClicked = [[cardDictionary valueForKey:@"isClicked"] boolValue]; 
	//isShaked = [[cardDictionary valueForKey:@"isShaked"] boolValue]; 
	//frontTextureFile = [[cardDictionary valueForKey:@"frontTextureFile"] retain]; 
	return self; 
}

#pragma mark Touch callback method
//Touch begin callback method
- (void)receiveTouchesBegin:(UIEvent *)event
{

}

//Touch moved callback method
- (void)receiveTouchesMoved:(UIEvent *)event
{

}

//Touch end callback method
- (void)receiveTouchesEnd:(UIEvent *)event
{
	switch([self tag]){
		case kSunCardTag: //선결정 카드
			[(SunLayer *)[self parent] setIsTouchEnabled:NO];
			[(SunLayer *)[self parent] decisionFirst:self];
			break;
		case kUserCardTag: //사용자 카드
			[(GameLayer *)parent myTurn:self];
			break;
		default:
				//Do nothing
			break;
	}
}



/*
 -(void) encodeWithCoder: (NSCoder *) encoder 
 {
 [encoder encodeInt:numberOfCard forKey:@"numberOfCard"]; 
 [encoder encodeInt:seqOfCard forKey:@"seqOfCard"]; 
 [encoder encodeInt:cardStatus forKey:@"cardStatus"]; 
 [encoder encodeInt:slotIndex forKey:@"slotIndex"]; 
 [encoder encodeInt:tag forKey:@"tag"]; 
 [encoder encodeInt:isFlipped forKey:@"isFlipped"]; 
 [encoder encodeInt:isClicked forKey:@"isClicked"]; 
 [encoder encodeInt:isShaked forKey:@"isShaked"]; 
 [encoder encodeObject:frontTextureFile forKey:@"frontTextureFile"]; 
 } 
 
 -(id) initWithCoder: (NSCoder *) decoder 
 { 
 seqOfCard = [decoder decodeIntForKey:@"seqOfCard"]; 
 self = [self initWithSeqNumber:seqOfCard]; 
 numberOfCard = [decoder decodeIntForKey:@"numberOfCard"]; 
 cardStatus = [decoder decodeIntForKey:@"cardStatus"]; 
 slotIndex = [decoder decodeIntForKey:@"slotIndex"]; 
 tag = [decoder decodeIntForKey:@"tag"]; 
 isFlipped = [decoder decodeBoolForKey:@"isFlipped"]; 
 isClicked = [decoder decodeBoolForKey:@"isClicked"]; 
 isShaked = [decoder decodeBoolForKey:@"isShaked"]; 
 frontTextureFile = [[decoder decodeObjectForKey:@"frontTextureFile"] retain]; 
 return self; 
 }
 */



@end
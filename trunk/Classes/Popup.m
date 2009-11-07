//
//  Popup.m
//  GoStop
//
//  Created by Idiel on 5/28/09.
//  Copyright 2009 Code4Mac. All rights reserved.
//

#import "Popup.h"
#import "Card.h"
#import "GameScene.h"


@implementation Popup
@synthesize modalStatus, popupMode;
@synthesize selectedPopupKey;

NSString *MTPopUpModalResultKey = @"modalResult";
NSString *MTPopUpCardListKey = @"popUpCardListKey";
NSString *MTPopUpSelectedCardKey = @"popUpSelectedCard";

+ (void)popUpWithTitle:(NSString *)title hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector
{	
	[self popUpWithTitle:title hasYes:yes hasNo:no target:anObject selector:aSelector userInfo:nil];
	/* temp
	NSAssert(anObject != nil, @"popUpWithTitle target must not be nil");
	NSAssert([anObject isMemberOfClass:[GameLayer class]], @"target must be game layer");
	
	GameScene *gScene = (GameScene *)[anObject parent];
	
	NSAssert([gScene isMemberOfClass:[GameScene class]], @"target's parent must be GameScene");	
	
	[[Director sharedDirector] pause];
	[gScene addChild:[[[self alloc] initWithTitle:title card:nil hasYes:yes hasNo:no target:anObject selector:aSelector] autorelease] z:POP_ZINDEX];
	[anObject setIsPopupOn:YES];
	*/
}

+ (void)popUpWithTitle:(NSString *)title hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector userInfo:(NSMutableDictionary *)preUserInfo
{
	[self popUpWithTitle:title card:nil hasYes:yes hasNo:no target:anObject selector:aSelector userInfo:preUserInfo];
	
}

+ (void)popUpWithTitle:(NSString *)title card:(NSArray *)cardList hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector
{
	[self popUpWithTitle:title card:cardList hasYes:yes hasNo:no target:anObject selector:aSelector userInfo:nil];
}

+ (void)popUpWithTitle:(NSString *)title card:(NSArray *)cardList hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector userInfo:(NSMutableDictionary *)preUserInfo
{	
	

	//NSAssert([gScene isMemberOfClass:[GameScene class]] || [gScene isMemberOfClass:[SunScene class]], @"target's parent must be GameScene");	
	NSAssert([anObject isKindOfClass:[Layer class]], @"Target must be a kind of Layer class");	
	
	[[Director sharedDirector] pause];
	
	Scene *pScene = (Scene *)[anObject parent];
	[pScene addChild:[[self alloc] initWithTitle:title card:cardList hasYes:yes hasNo:no target:anObject selector:aSelector userInfo:preUserInfo] z:POP_ZINDEX];
	[(Layer *)anObject setIsTouchEnabled:NO]; //레이어 터치 이벤트 받지 않음
	
	
	/*
	 Popup *popup = [[[self alloc] initWithTitle:title card:nil hasYes:yes hasNo:no target:anObject selector:nil] autorelease];
	 [gScene addChild:popup z:POP_ZINDEX];
	 [anObject setIsPopupOn:YES];
	 
	 while([popup modalStatus] == 0){		
	 if ( [[NSRunLoop currentRunLoop] runMode:[[NSRunLoop currentRunLoop] currentMode] beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]] )
	 {
	 NSLog(@"NSRunLoop runMode return YES");
	 //[[NSRunLoop currentRunLoop] limitDateForMode:[[NSRunLoop currentRunLoop] currentMode]];
	 } else
	 {
	 NSLog(@"NSRunLoop runMode return NO");
	 }
	 }
	 
	 return [popup selectedPopupKey];
	 */
	
}


- (id)initWithTitle:(NSString *)title
			   card:(NSArray *)cardList
			 hasYes:(BOOL)yes
			  hasNo:(BOOL)no
			 target:(id)anObject
		   selector:(SEL)aSelector
{
	return [self initWithTitle:title
						  card:cardList 
						hasYes:yes 
						 hasNo:no 
						target:anObject 
					  selector:aSelector
					  userInfo:nil];
}


- (id)initWithTitle:(NSString *)title
			   card:(NSArray *)cardList
			 hasYes:(BOOL)yes
			  hasNo:(BOOL)no
			 target:(id)anObject
		   selector:(SEL)aSelector
		   userInfo:(NSMutableDictionary *)preUserInfo
			
{
	return [self initWithTitle:title
						  mode:0
						  card:cardList 
						hasYes:yes 
						 hasNo:no 
						target:anObject 
					  selector:aSelector
					  userInfo:preUserInfo];
}

- (id)initWithTitle:(NSString *)title 
			   mode:(int)mode
			   card:(NSArray *)cardList 
			 hasYes:(BOOL)yes 
			  hasNo:(BOOL)no 
			 target:(id)anObject 
		   selector:(SEL)aSelector
		   userInfo:(NSMutableDictionary *)preUserInfo
{
	if(self = [super init]) 
	{
		popupMode = mode;
		target = anObject;
		selector = aSelector;
		
		/* modal */
		selectedPopupKey = kPopupNone;
		modalStatus = 0;
		/* modal */
		
		if(preUserInfo == nil)
			userInfo = [[NSMutableDictionary alloc] init];
		else
			userInfo = [preUserInfo retain];
		
		
		[self setIsTouchEnabled:YES]; 
		
		Sprite *popup = [Sprite spriteWithFile:@"popup.png"];
		
		[popup setPosition:ccp(240, 160)];
		[popup setTag:kPopupBackground];
		
		Label *aTitle = [Label labelWithString:title
									  fontName:@"AppleGothic" 
									  fontSize:28];
		[aTitle setPosition:ccp(240,220)];
		[aTitle setTag:kPopupBackground];
		[self addChild:popup z:0];
		
		if(yes && no)
		{
			okButton = [Sprite spriteWithFile:@"popup_yes_on.png"];
			[okButton setTag:kPopupOKButton]; 
			cancelButton = [Sprite spriteWithFile:@"popup_no_on.png"];
			[cancelButton setTag:kPopupCancelButton]; 
			
			[okButton setPosition:ccp(180,100)]; 
			[cancelButton setPosition:ccp(300,100)];
			[okButton runAction:[TintTo actionWithDuration:0.0 red:160 green:160 blue:160]];
			[cancelButton runAction:[TintTo actionWithDuration:0.0 red:160 green:160 blue:160]];
			[self addChild:okButton z:1]; 
			[self addChild:cancelButton z:2]; 
			
		} else if(yes && !no) 
		{
			okButton = [Sprite spriteWithFile:@"popup_yes_off.png"];
			[okButton setTag:kPopupOKButton]; 
			
			[okButton setPosition:ccp(240,100)]; 
			[okButton runAction:[TintTo actionWithDuration:0.0 red:160 green:160 blue:160]];
			
			[self addChild:okButton z:1]; 
		}
		
		[self addChild:aTitle z:3];
		int cardCount = [cardList count];
		
		float baseFactor; 
		
		switch(cardCount)
		{
			case 1:
			case 2:
			case 3:
				baseFactor = 0.38; 
				break; 
			case 4:
			case 5:
				baseFactor = 0.3; 
				break;
			case 6:
			case 7:
			case 8:
				baseFactor = 0.2; 
				break;
			case 9:
			case 10:
				baseFactor = 0.1; 
				break; 
			default:
				baseFactor = 0; 
		}
		
		if(cardCount > 0)
		{
			int cardIndex = 0; 
			CGSize s = [[Director sharedDirector] winSize];
			Sprite *aSprite = [cardList objectAtIndex:0];
			float space = (260 - (aSprite.contentSize.width * baseFactor *cardCount))/(cardCount + 1); 
			
			float sp = s.width - (aSprite.contentSize.width * baseFactor *cardCount ) - space * (cardCount + 1);
			sp *= 0.5;
			
			for(Sprite *aCard in cardList) 
			{
				
				aCard.scale = baseFactor; 
				aCard.position = ccp(((aCard.contentSize.width * baseFactor + space) * cardIndex) + sp + aSprite.contentSize.width/2, 165); 
				[aCard runAction:[TintTo actionWithDuration:0.0 red:160 green:160 blue:160]];
				
				[[aCard parent] removeChild:aCard cleanup:YES];
				[self addChild:aCard];
				
				cardIndex++;
			}
			//142 x 216 original size, 
			//1 ~ 3, baseFactor : 0.5 = 71, 108 //max 230?
			//4 ~ 5, baseFactor : 0.3 = 43      //max 260?
			//6 ~ 8, baseFactor : 0.2 = 
			//9 ~ 10, baseFactor : 0.1 
			//280,170 inset 10 260 110 + 
			//scaleFactor : 260/cardCount - (inset:5)
			
			// start point s.width/2 - 260/2 
			// end Point s.width/2 + 260/2 
			// centers = sp + cardIndex * 
		}
		
		return self; 
	}
	return nil;
	
}

- (id)initWithInfo
{
	return nil; 
}

- (void)dealloc
{
	[userInfo release];
	
	[super dealloc];
}


- (popupKeys)openModalDialogForScene:(Scene *)scene
{	
	[scene addChild:self z:POP_ZINDEX];
	
	while(modalStatus == 0){
		
		if ( [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]] )
		{
			NSLog(@"NSRunLoop runMode return YES");
			[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];
		} else
		{
			NSLog(@"NSRunLoop runMode return NO");
		}
		
	}
	
	return selectedPopupKey;
}



/*
 - (void)okButtonClicked 
 {
 [(GameScene *)self.parent okButtonClicked:self]; 
 }
 
 - (void)cancelButtonClicked
 {
 [(GameScene *)self.parent cancelButtonClicked:self]; 
 }
 */

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	for(Sprite *aSprite in [self children])
	{
		CGSize s = aSprite.contentSize;
		s.width *= aSprite.scaleX; 
		s.height *= aSprite.scaleX;
		
		CGRect r = CGRectMake( aSprite.position.x - 
							  s.width/2,
							  aSprite.position.y-s.height/2,
							  s.width, s.height);
		
		if( CGRectContainsPoint( r, convertedLocation ) )
		{
			if(aSprite.tag == kPopupBackground)
				continue;
			
			[aSprite runAction:[TintTo actionWithDuration:0.0 red:255 green:255 blue:255]];
			/*
			 switch (aSprite.tag) {
			 
			 case kPopupOKButton:
			 {
			 [aSprite setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"popup_yes_on.png"]]];
			 }
			 break;
			 case kPopupCancelButton:
			 {
			 [aSprite setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"popup_no_on.png"]]];
			 }	
			 break; 
			 default:
			 //do nothing ;
			 break;
			 
			 }*/
		}
	}
	return kEventHandled;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	for(Sprite *aSprite in [self children])
	{
		CGSize s = aSprite.contentSize;
		s.width *= aSprite.scale; 
		s.height *= aSprite.scale;
		
		CGRect r = CGRectMake( aSprite.position.x - 
							  s.width/2,
							  aSprite.position.y-s.height/2,
							  s.width, s.height);
		
		if( CGRectContainsPoint( r, convertedLocation ) )
		{
			if(aSprite.tag == kPopupBackground)
				continue;
			
			[aSprite runAction:[TintTo actionWithDuration:0.2 red:255 green:255 blue:255]];
			
			
			
			/*
			 switch (aSprite.tag) {
			 case kPopupOKButton:
			 {
			 [aSprite setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"popup_yes_on.png"]]];
			 [cancelButton setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"popup_no_off.png"]]];
			 
			 }
			 break;
			 case kPopupCancelButton:
			 {
			 [aSprite setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"popup_no_on.png"]]];
			 [okButton setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"popup_yes_off.png"]]];
			 
			 }	
			 break; 
			 default:
			 //do nothing ;
			 break;
			 
			 }
			 */
		} else {
			if(aSprite.tag == kPopupBackground)
				continue;
			
			[aSprite runAction:[TintTo actionWithDuration:0.2 red:160 green:160 blue:160]];	
		}
	}
	return kEventHandled;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	Sprite *selectedSprite = nil;
	
	//static int aCard = 0;
	//static int bCard = 0;
	
	for(Sprite *aSprite in [self children])
	{
		CGSize s = aSprite.contentSize;
		s.width *= aSprite.scale; 
		s.height *= aSprite.scale;
		
		CGRect r = CGRectMake( aSprite.position.x - 
							  s.width/2,
							  aSprite.position.y-s.height/2,
							  s.width, s.height);
				
		if( CGRectContainsPoint( r, convertedLocation ) )
		{			
			if(aSprite.tag == kPopupBackground)
				continue;
			
			selectedSprite = aSprite; //선택된 sprite 저장해둠				
		} else	{
			//선택되지 않은 sprite를 흐리게 처리함
			/*
			//일단 적용하지 않음
			if(aSprite.tag == kPopupBackground)
				continue;
			
			[aSprite runAction:[TintTo actionWithDuration:0.2 red:160 green:160 blue:160]];				
			*/
		}
	}
		
	if(selectedSprite == nil){
		return kEventIgnored;
	}
	
	NSMutableArray *cardListArray = nil;
	
	if([selectedSprite isMemberOfClass:[Card class]]){
		//카드는 팝업레이어에서 제거하고 다시 게임 레이어로 추가한다.
		GameScene *gScene = (GameScene *)[self parent];
		
		int i = 0;
		int lastIndex = [[self children] count] - 1;
		
		cardListArray = [[[NSMutableArray alloc] init] autorelease];
		
		for(i = lastIndex ; i >= 0 ; i--){
			Sprite *aSprite = [[self children] objectAtIndex:i];
			
			if([aSprite isMemberOfClass:[Card class]]){
				
				[cardListArray addObject:aSprite]; //카드만 배열에 저장해둠.
				
				
				[[aSprite parent] removeChild:aSprite cleanup:YES]; //팝업 레이어에서 삭제				
				[[gScene getGameLayer] addChild:aSprite];
				//원래자리로 되돌아가야 함.
				switch([(Card *)aSprite tag]){
					case kUserCardTag:
						break;
					case kComCardTag:
						break;
					case kUserGainCardTag:
						break;
					case kComGainCardTag:
						break;
					case kFloorCardTag:
						[(Card *)aSprite moveToFloor];
						break;
					case kDeckCardTag:
						break;
				} 	
				
			} else {
			}
		}
		////////////////////////////////////////////////////
	}
		
	//callback with userInfo
	if([target respondsToSelector:selector]){
		switch (selectedSprite.tag) {
			case kPopupOKButton:
			case kPopupCancelButton:
				[userInfo setObject:[NSNumber numberWithInt:[selectedSprite tag]] forKey:MTPopUpModalResultKey];
				
				break; 
			default: //카드 sprite
				[userInfo setObject:[NSNumber numberWithInt:kPopupNone] forKey:MTPopUpModalResultKey];
				break;
		}
		[userInfo setObject:selectedSprite forKey:MTPopUpSelectedCardKey];
		if(cardListArray != nil)
			[userInfo setObject:cardListArray forKey:MTPopUpCardListKey];
		[target performSelector:selector withObject:userInfo];
	
					
		selectedPopupKey = selectedSprite.tag;
		modalStatus = 1;
		
		[self closePopup];		
	}		
	return kEventHandled;
}

- (void)delayedFinalizingWithObject:(id)argObject
{
	//NSLog(@"delayed finalizing!");	
	if([target respondsToSelector:selector]){
		[target performSelector:selector withObject:argObject];
	}
	
	modalStatus = 1;
	[[Director sharedDirector] resume];

	GameScene *gScene = (GameScene *)[self parent];
	[gScene removeChild:self cleanup:YES];
	
	//[self closePopup];
}

- (void)closePopup
{
	GameScene *gScene = (GameScene *)[self parent];
	[gScene removeChild:self cleanup:YES];
	
	NSAssert([target isKindOfClass:[Layer class]], @"Target must be a kind of Layer class");
	[(Layer *)target setIsTouchEnabled:YES];
	[[Director sharedDirector] resume];
}
@end


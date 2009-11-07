//
//  CharacterAnimation.m
//  GoStop
//
//  Created by Idiel on 6/2/09.
//  Copyright 2009 Code4Mac. All rights reserved.
//

#import "CharacterAnimation.h"


@implementation CharacterAnimation
+ (id)newCharacterAnimation
{
	return [[[super alloc] init] autorelease]; 
}

- (void)startCharacterAnimation:(int)animationType
{	
	Animation* animation = [Animation animationWithName:@"CharacterAnimation" delay:0.3f];
	
	switch (animationType) {
		case kAnimationThree: 
			[self prepareCharacterWithFile:@"character_01_self_three_01.png"];
			[animation addFrameWithFilename:@"character_01_self_three_01.png"];
			[animation addFrameWithFilename:@"character_01_self_three_02.png"];
			[animation addFrameWithFilename:@"character_01_self_three_01.png"];
			[animation addFrameWithFilename:@"character_01_self_three_02.png"];
			break; 
		case kAnimationOtherThree: 
			[self prepareCharacterWithFile:@"character_01_other_three_01.png"];
			[animation addFrameWithFilename:@"character_01_other_three_01.png"];
			[animation addFrameWithFilename:@"character_01_other_three_02.png"];
			[animation addFrameWithFilename:@"character_01_other_three_01.png"];
			[animation addFrameWithFilename:@"character_01_other_three_02.png"];
			break; 
		case kAnimationLucky: 
			[self prepareCharacterWithFile:@"character_01_self_lucky_01.png"];
			[animation addFrameWithFilename:@"character_01_self_lucky_01.png"];
			[animation addFrameWithFilename:@"character_01_self_lucky_02.png"];
			[animation addFrameWithFilename:@"character_01_self_lucky_01.png"];
			[animation addFrameWithFilename:@"character_01_self_lucky_02.png"];
			break; 
		case kAnimationOtherLucky: 
			[self prepareCharacterWithFile:@"character_01_other_lucky_01.png"];
			[animation addFrameWithFilename:@"character_01_other_lucky_01.png"];
			[animation addFrameWithFilename:@"character_01_other_lucky_02.png"];
			[animation addFrameWithFilename:@"character_01_other_lucky_01.png"];
			[animation addFrameWithFilename:@"character_01_other_lucky_02.png"];
			break; 
		case kAnimationGo: 
			[self prepareCharacterWithFile:@"character_01_self_go_01.png"];
			[animation addFrameWithFilename:@"character_01_self_go_01.png"];
			[animation addFrameWithFilename:@"character_01_self_go_02.png"];
			[animation addFrameWithFilename:@"character_01_self_go_01.png"];
			[animation addFrameWithFilename:@"character_01_self_go_02.png"];
			break; 
		case kAnimationOtherGo: 
			[self prepareCharacterWithFile:@"character_01_other_go_01.png"];
			[animation addFrameWithFilename:@"character_01_other_go_01.png"];
			[animation addFrameWithFilename:@"character_01_other_go_02.png"];
			[animation addFrameWithFilename:@"character_01_other_go_01.png"];
			[animation addFrameWithFilename:@"character_01_other_go_02.png"];
			break; 
		case kAnimationBomb: 
			[self prepareCharacterWithFile:@"character_01_self_bomb_01.png"];
			[animation addFrameWithFilename:@"character_01_self_bomb_01.png"];
			[animation addFrameWithFilename:@"character_01_self_bomb_02.png"];
			[animation addFrameWithFilename:@"character_01_self_bomb_01.png"];
			[animation addFrameWithFilename:@"character_01_self_bomb_02.png"];
			break; 
		case kAnimationOtherBomb: 
			[self prepareCharacterWithFile:@"character_01_other_bomb_01.png"];
			[animation addFrameWithFilename:@"character_01_other_bomb_01.png"];
			[animation addFrameWithFilename:@"character_01_other_bomb_02.png"];
			[animation addFrameWithFilename:@"character_01_other_bomb_01.png"];
			[animation addFrameWithFilename:@"character_01_other_bomb_02.png"];
			break; 
		case kAnimationShit: //쌌을 때
 		    [self prepareCharacterWithFile:@"character_01_self_shit_01.png"];
			[animation addFrameWithFilename:@"character_01_self_shit_01.png"];
			[animation addFrameWithFilename:@"character_01_self_shit_02.png"];
			[animation addFrameWithFilename:@"character_01_self_shit_01.png"];
			[animation addFrameWithFilename:@"character_01_self_shit_02.png"];
			break; 
		default:
			break;
	}
	id action = [Animate actionWithAnimation: animation];
	[characterSprite runAction:action]; 
	[self performSelector:@selector(removeAnimation) withObject:nil afterDelay:1.2]; 
}

- (void)prepareCharacterWithFile:(NSString *)filename 
{
	CGSize s = [[Director sharedDirector] winSize];
	characterSprite = [Sprite spriteWithFile:filename];
	shadowSprite = [Sprite spriteWithFile:filename]; 
	id tintAction = [TintTo actionWithDuration:0 red:0 green:0 blue:0]; 
	[shadowSprite runAction:tintAction]; 
	
	CGSize cs = [characterSprite contentSize]; 
	characterSprite.position = CGPointMake( s.width - cs.width / 2 - 10, cs.height / 2 + 10 );
	shadowSprite.position = CGPointMake( s.width - cs.width / 2 - 10, cs.height / 2 + 10 );
	
	//[self addChild:shadowSprite z:0]; 
	[self addChild:characterSprite z:1]; 
}

- (void)removeAnimation
{
	GameScene *gScene = (GameScene *)[self parent];
	[[gScene getGameLayer] setIsPopupOn:NO];
	[gScene removeChild:self cleanup:YES];
}

@end

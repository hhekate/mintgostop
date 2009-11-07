//
//  CharacterAnimation.h
//  GoStop
//
//  Created by Idiel on 6/2/09.
//  Copyright 2009 Code4Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum animationTypeKeys
{
	kAnimationThree = 4000, 
	kAnimationOtherThree,
	kAnimationLucky,
	kAnimationOtherLucky,
	kAnimationGo, 
	kAnimationOtherGo, 
	kAnimationBomb,
	kAnimationOtherBomb,
	kAnimationShit,
};

#import "gameScene.h"
@interface CharacterAnimation : Sprite {
	Sprite *characterSprite; 
	Sprite *shadowSprite; 
}
+ (id)newCharacterAnimation;
- (void)prepareCharacterWithFile:(NSString *)filename;
- (void)startCharacterAnimation:(int)animationType;
@end

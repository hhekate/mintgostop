//
//  SunLayer.h
//  GoStop
//
//  Created by Conan Kim on 9/17/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "TouchLayer.h"
#import "Card.h"
#import "ConstDefine.h"
#import "Popup.h"
#import "GameScene.h"

@interface SunLayer : TouchLayer {
	int sunPlayer; //1:me / 2:opponent
}
- (void)popupWithSunDecision;
- (void)removeAllCardSprites;
- (void)moveToGameScene:(NSDictionary *)userInfo;
- (void)shuffleSunCard;
- (void)decisionFirst:(Card *)selectedCard;

@end

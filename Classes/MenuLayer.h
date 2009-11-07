//
//  MenuLayer.h
//  GoStop
//
//  Created by Conan Kim on 9/17/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "cocos2d.h"
#import "SunScene.h"
#import "NetworkGameScene.h"

@interface MenuLayer : Layer {}
-(void)startGame: (id)sender;
-(void)help: (id)sender;
@end
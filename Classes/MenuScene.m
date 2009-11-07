//
//  MenuScene.m
//  GoStop
//
//  Created by Idiel on 5/20/09.
//  Copyright 2009 Code4Mac. All rights reserved.
//

#import "MenuScene.h"

@implementation MenuScene
- (id) init {
    self = [super init];
    if (self != nil) {
        Sprite * bg = [Sprite spriteWithFile:@"menu.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
        [self addChild:[MenuLayer node] z:1];
    }
    return self;
}
@end



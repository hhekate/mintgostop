//
//  SunScene.m
//  GoStop
//
//  Created by Conan Kim on 7/1/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "SunScene.h"
#import "SunLayer.h"

@implementation SunScene
- (id) init {
    self = [super init];
    if (self != nil) {
	
        Sprite * bg = [Sprite spriteWithFile:@"sunbg.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
				
        [self addChild:[SunLayer node] z:1];
    }
    return self;
}
@end



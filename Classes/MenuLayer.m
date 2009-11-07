//
//  MenuLayer.m
//  GoStop
//
//  Created by Conan Kim on 9/17/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "MenuLayer.h"

@implementation MenuLayer
- (id) init {
    self = [super init];
    if (self != nil) {
        [MenuItemFont setFontSize:20];
        [MenuItemFont setFontName:@"AppleGothic"];
        MenuItem *start = [MenuItemFont itemFromString:@"혼자 하기"
												target:self
											  selector:@selector(startGame:)];
		
		MenuItem *networkPlayStart = [MenuItemFont itemFromString:@"같이 하기"
														   target:self
														 selector:@selector(networkGame:)];
		
        MenuItem *help = [MenuItemFont itemFromString:@"Help"
											   target:self
											 selector:@selector(help:)];
		Menu *menu;
		if([[[NSUserDefaults standardUserDefaults] valueForKey:@"GameSaved"] boolValue])
		{	MenuItem *load = [MenuItemFont itemFromString:@"게임 이어하기"
												 target:self
											   selector:@selector(loadGame:)];
			menu = [Menu menuWithItems:start, load, networkPlayStart, help, nil]; 
		}
		else{
			menu = [Menu menuWithItems:start, networkPlayStart, help, nil];
		}
        [menu alignItemsVertically];
        [self addChild:menu];
    }
    return self;
}
-(void)startGame: (id)sender {
	SunScene * ss = [SunScene node];
    [[Director sharedDirector] replaceScene:[FlipXTransition transitionWithDuration:0.4 scene:ss]];
}

- (void)networkGame: (id)sender {
	//GameScene * gs = [GameScene node];
    NetworkGameScene *gs = [NetworkGameScene node]; 
	[[Director sharedDirector] replaceScene:gs];
	[gs startNetworkGame]; 
}

- (void)loadGame: (id)sender {
	GameScene * gs = [GameScene node];
    [[Director sharedDirector] replaceScene:gs];
	
	//[[[UIApplication sharedApplication] delegate] setCurrentGameScene:gs]; 
	[gs loadGame]; 
}

-(void)help: (id)sender {
    NSLog(@"help");
}
@end
//
//  GoStopAppDelegate.m
//  GoStop
//
//  Created by Idiel on 5/20/09.
//  Copyright Code4Mac 2009. All rights reserved.
//

#import "GoStopAppDelegate.h"

@implementation GoStopAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window setUserInteractionEnabled:YES];
    [window setMultipleTouchEnabled:YES];
    [[Director sharedDirector] setLandscape: YES];
    [[Director sharedDirector] attachInWindow:window];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [window makeKeyAndVisible];
	
	MenuScene * ms = [MenuScene node];
	
    [[Director sharedDirector] runWithScene:ms];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}


// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	if(currentGameScene != nil) 
	{
		[currentGameScene saveGame]; 
	}
	 */
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end

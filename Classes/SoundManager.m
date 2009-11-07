//
//  SoundBox.m
//  GoStop
//
//  Created by won on 01/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"


@implementation SoundManager
- (id) init
{
	self = [super init];
	if (self != nil) {
		
		NSString *file = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Sounds/throw.aiff"];

		NSURL *url = [NSURL fileURLWithPath:file];
		AudioServicesCreateSystemSoundID( (CFURLRef) url, &throwSound );
	}
	return self;
}


+ (SoundManager *) sharedManager
{
	static SoundManager * shared = nil;
	
    if ( !shared )
        shared = [[self alloc] init];
	
    return shared;
	
}

- (void)throwSound
{
	AudioServicesPlaySystemSound(throwSound);
	
}

@end

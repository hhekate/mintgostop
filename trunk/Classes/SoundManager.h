//
//  SoundBox.h
//  GoStop
//
//  Created by won on 01/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>


@interface SoundManager : NSObject {
	SystemSoundID throwSound;

}

+ (SoundManager *) sharedManager;
- (void)throwSound;


@end

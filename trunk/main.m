//
//  main.m
//  GoStop
//
//  Created by Idiel on 5/20/09.
//  Copyright Code4Mac 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	int retVal = UIApplicationMain(argc, argv, nil,
								   @"GoStopAppDelegate");
    [pool release];
    return retVal;
}

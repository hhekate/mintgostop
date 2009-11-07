//
//  CompositeActions.h
//  GoStop
//
//  Created by Conan Kim on 5/28/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


/** Moves a CocosNode object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
 */
@interface ScaledFlipMoveTo : IntervalAction <NSCopying>
{
	//move
	CGPoint endPosition;
	CGPoint startPosition;
	CGPoint delta;
	//scale
	float scale;
	float scaleY;
	float startScaleX;
	float startScaleY;
	float endScaleX;
	float endScaleY;
	float deltaX;
	float deltaY;
	
	id callBackObj;
	SEL callBackMethod;	
	
	BOOL needFlip;
}
/** creates the action */
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip;
/** creates the action withCallBackFunction*/
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip object:(id)object callBack:(SEL)callBack;
/** initializes the action */
-(id) initWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip;
-(id) initWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip object:(id)object callBack:(SEL)callBack;
@end

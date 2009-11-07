//
//  CompositeActions.m
//  GoStop
//
//  Created by Conan Kim on 5/28/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "CompositeActions.h"
#import "Card.h"



@implementation ScaledFlipMoveTo
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip
{	
	return [[[self alloc] initWithDuration:t position:p scale:s withFlip:flip] autorelease];
}

+(id) actionWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip object:(id)object callBack:(SEL)callBack
{
	return [[[self alloc] initWithDuration:t position:p scale:s  withFlip:flip object:object callBack:callBack] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip object:(id)object callBack:(SEL)callBack
{
	callBackMethod = callBack;
	callBackObj = object;
	
	return [self initWithDuration: t position: p scale: s withFlip:flip];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p scale:(float) s withFlip:(BOOL)flip
{
	if( !(self=[super initWithDuration: t]) )
		return nil;
	
	endPosition = p;
	endScaleX = s;
	endScaleY = s;
	
	needFlip = flip;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: endPosition scale:endScaleY withFlip:needFlip];
	return copy;
}

-(void) start
{
	[super start];
	startPosition = [target position];
	delta = ccpSub( endPosition, startPosition );
	
	startScaleX = [target scaleX];
	startScaleY = [target scaleY];
	deltaX = endScaleX - startScaleX;
	deltaY = endScaleY - startScaleY;
}

-(void) update: (ccTime) t
{	
	target.position = ccp( (startPosition.x + delta.x * t ), (startPosition.y + delta.y * t ) );
	
	float subDuration = 0.1; // 0 ~ (1-startPoint)
	float startPoint = 0.0; //0~1
	
	float subDeltaX = 0.0;
	
	if(needFlip){
		if(t > startPoint && t <= (startPoint + (subDuration / 2))){
			subDeltaX = 0-(startScaleX + deltaX * startPoint);
			[target setScaleX: ((startScaleX + deltaX * startPoint) + (subDeltaX * ((t-startPoint) / (subDuration / 2))))];
		} else if(t > (startPoint + (subDuration / 2)) && t <= (startPoint + subDuration)){
			subDeltaX = (startScaleX + deltaX * (startPoint + subDuration));
			[target setScaleX: (0 + (subDeltaX * ((t-(startPoint + (subDuration / 2))) / (subDuration / 2)))) ];
		} else
			[target setScaleX: (startScaleX + deltaX * t ) ];
		
		if(t > (startPoint + (subDuration / 2)))
			[(TextureNode *)target setTexture:[[TextureMgr sharedTextureMgr] addImage: [(Card *)target frontTextureFile]]];
	} else
		[target setScaleX: (startScaleX + deltaX * t ) ];
	
	
	[target setScaleY: (startScaleY + deltaY * t ) ];
}

- (BOOL)isDone
{
	if([super isDone]){
		if(callBackObj != nil){
			if([callBackObj respondsToSelector:callBackMethod]){
				[callBackObj performSelector:callBackMethod withObject:nil afterDelay:0.3];
			}
		}
		return YES;
	} else {
		return NO;
	}
}
@end
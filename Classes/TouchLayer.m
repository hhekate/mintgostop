//
//  TouchLayer.m
//  GoStop
//
//  Created by Conan Kim on 9/16/09.
//  Copyright 2009 Mintech. All rights reserved.
//

#import "TouchLayer.h"

@implementation TouchLayer


- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	for(TextureNode *aNode in [self children])
	{	
		if([aNode isKindOfClass:[TextureNode class]]){ //textureNode일 경우만 적용
			//Size Fix
			CGSize s = aNode.contentSize;
			s.width *= aNode.scale; 
			s.height *= aNode.scale;
			
			CGRect r = CGRectMake( aNode.position.x - 
								  s.width/2,
								  aNode.position.y-s.height/2,
								  s.width, s.height);
			
			if( CGRectContainsPoint( r, convertedLocation ) )
			{
				//Node의 터치 이벤트가 시작할 때
				if([aNode respondsToSelector:@selector(receiveTouchesBegin:)]){
					[aNode performSelector:@selector(receiveTouchesBegin:) withObject:event];
					break;
				}
			}			
		}
	}
	return kEventHandled;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	
	for(TextureNode *aNode in [self children])
	{			
		if([aNode isKindOfClass:[TextureNode class]]){ //textureNode일 경우만 적용
			//Size Fix
			CGSize s = aNode.contentSize;
			s.width *= aNode.scale; 
			s.height *= aNode.scale;
			
			CGRect r = CGRectMake( aNode.position.x - 
								  s.width/2,
								  aNode.position.y-s.height/2,
								  s.width, s.height);
			
			if( CGRectContainsPoint( r, convertedLocation ) )
			{
				//Node의 터치 무빙 이벤트중일 때
				if([aNode respondsToSelector:@selector(receiveTouchesMoved:)]){
					[aNode performSelector:@selector(receiveTouchesMoved:) withObject:event];
					break;
				}
			}
		}
	}
	return kEventHandled;
}


- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	for(TextureNode *aNode in [self children])
	{
		if([aNode isKindOfClass:[TextureNode class]]){ //textureNode일 경우만 적용
			//Size Fix
			CGSize s = aNode.contentSize;
			s.width *= aNode.scale;
			s.height *= aNode.scale;
			
			CGRect r = CGRectMake( aNode.position.x - 
								  s.width/2,
								  aNode.position.y-s.height/2,
								  s.width, s.height);
			
			if( CGRectContainsPoint( r, convertedLocation ))
			{
				//Node의 터치 이벤트가 끝났을 때
				if([aNode respondsToSelector:@selector(receiveTouchesEnd:)]){
					[aNode performSelector:@selector(receiveTouchesEnd:) withObject:event];
					break;
				}
			}
		}
	}
	return kEventHandled;
}


@end

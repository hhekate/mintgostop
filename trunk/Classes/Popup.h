//
//  Popup.h
//  GoStop
//
//  Created by Idiel on 5/28/09.
//  Copyright 2009 Code4Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ConstDefine.h"

typedef enum 
{
	kPopupNone = -1,
	kPopupBackground = 3000,
	kPopupOKButton = 3001, 
	kPopupCancelButton, 
	kPopupContinue, 
	kPopupCardOne = 3101, 
	kPopupCardTwo,
	kPopupCardThree, 
	kPopupCardFour,
	kPopupCardFive,
	kPopupCardSix,
	kPopupCardSeven,
	kPopupCardEight,
	kPopupCardNine, 
	kPopupCardTen
} popupKeys;

extern NSString *MTPopUpModalResultKey;
extern NSString *MTPopUpCardListKey;
extern NSString *MTPopUpSelectedCardKey;

@interface Popup : Layer {
	Sprite *okButton; 
	Sprite *cancelButton;
	id target; 
	SEL selector; 
	
	int popupMode; 
	int modalStatus;
	popupKeys selectedPopupKey;
	NSMutableDictionary *userInfo;
}
@property int modalStatus, popupMode;
@property popupKeys selectedPopupKey;
+ (void)popUpWithTitle:(NSString *)title hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector;
+ (void)popUpWithTitle:(NSString *)title hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector userInfo:(NSMutableDictionary *)preUserInfo;
+ (void)popUpWithTitle:(NSString *)title card:(NSArray *)cardList hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector;
+ (void)popUpWithTitle:(NSString *)title card:(NSArray *)cardList hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector userInfo:(NSMutableDictionary *)preUserInfo;


- (id)initWithTitle:(NSString *)title
			   card:(NSArray *)cardList
			 hasYes:(BOOL)yes
			  hasNo:(BOOL)no
			 target:(id)anObject
		   selector:(SEL)aSelector
		   userInfo:(NSMutableDictionary *)preUserInfo;

- (id)initWithTitle:(NSString *)title 
			   mode:(int)mode
			   card:(NSArray *)cardList 
			 hasYes:(BOOL)yes 
			  hasNo:(BOOL)no 
			 target:(id)anObject 
		   selector:(SEL)aSelector
		   userInfo:(NSMutableDictionary *)preUserInfo;

- (id)initWithTitle:(NSString *)title card:(NSArray *)cardList hasYes:(BOOL)yes hasNo:(BOOL)no target:(id)anObject selector:(SEL)aSelector;
- (id)initWithInfo;
- (popupKeys)openModalDialogForScene:(Scene *)scene;
- (void)closePopup;
@end

//
//  YJKeyboardAvoidCollectionView.h
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2014/10/26.
//  Copyright © 2014年 YJManager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJKeyboardAvoidCollectionView : UICollectionView

- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

@end

//
//  UIScrollView+YJKeyboardAvoidingExt.h
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2016/11/26.
//  Copyright © 2016年 YJManager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (YJKeyboardAvoidingExt)


/** 接收键盘将要 显示/隐藏 的通知 */
- (void)keyboardAvoidingWithKeyboardWillShow:(NSNotification *)notification;
- (void)keyboardAvoidingWithKeyboardWillHide:(NSNotification *)notification;


/** 根据子视图计算 ContentSize */
-(CGSize)keyboardAvoidingCalculatedContentSizeFromSubviewFrames;
/**< 寻找第一响应者 */
- (UIView *)keyboardAvoidingFindFirstResponderBeneathView:(UIView *)view;

/** 更新 */
- (void)keyboardAvoidingUpdateContentInset;
- (void)keyboardAvoidingUpdateFromContentSizeChange;

/** 定位于下一个输入区 */
- (BOOL)keyboardAvoidingFocusNextTextField;
-(void)keyboardAvoidingScrollToActiveTextField;

- (void)keyboardAvoidingAssignTextDelegateForViewsBeneathView:(UIView *)view;

@end

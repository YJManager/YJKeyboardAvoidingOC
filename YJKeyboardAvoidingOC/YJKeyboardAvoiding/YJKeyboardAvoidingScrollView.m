//
//  YJKeyboardAvoidingScrollView.m
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2016/11/26.
//  Copyright © 2016年 YJManager. All rights reserved.
//

#import "YJKeyboardAvoidingScrollView.h"
#import "UIScrollView+YJKeyboardAvoidingExt.h"

@interface YJKeyboardAvoidingScrollView () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation YJKeyboardAvoidingScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUpKeyboardAvoid];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self _setUpKeyboardAvoid];
}

- (void)_setUpKeyboardAvoid{
    NSNotificationCenter * noticationCenter = [NSNotificationCenter defaultCenter];
    
    [noticationCenter addObserver:self selector:@selector(keyboardAvoidingWithKeyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [noticationCenter addObserver:self selector:@selector(keyboardAvoidingWithKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [noticationCenter addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [noticationCenter addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];

}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self keyboardAvoidingUpdateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self keyboardAvoidingUpdateFromContentSizeChange];
}

- (void)contentSizeToFit {
    self.contentSize = [self keyboardAvoidingCalculatedContentSizeFromSubviewFrames];
}

- (BOOL)focusNextTextField {
    return [self keyboardAvoidingFocusNextTextField];
    
}
- (void)scrollToActiveTextField {
    return [self keyboardAvoidingScrollToActiveTextField];
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(keyboardAvoidingAssignTextDelegateForViewsBeneathView:) object:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self keyboardAvoidingFindFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![self focusNextTextField]) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(keyboardAvoidingAssignTextDelegateForViewsBeneathView:) object:self];
    [self performSelector:@selector(keyboardAvoidingAssignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

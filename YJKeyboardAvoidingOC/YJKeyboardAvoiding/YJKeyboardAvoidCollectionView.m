//
//  YJKeyboardAvoidCollectionView.m
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2014/10/26.
//  Copyright © 2014年 YJManager. All rights reserved.
//

#import "YJKeyboardAvoidCollectionView.h"
#import "UIScrollView+YJKeyboardAvoidingExt.h"

@interface YJKeyboardAvoidCollectionView () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation YJKeyboardAvoidCollectionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUpKeyboardAvoidNotificationCenter];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self _setUpKeyboardAvoidNotificationCenter];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self _setUpKeyboardAvoidNotificationCenter];
}

- (void)_setUpKeyboardAvoidNotificationCenter {
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) return;
    
    NSNotificationCenter * noticationCenter = [NSNotificationCenter defaultCenter];
    
    [noticationCenter addObserver:self selector:@selector(keyboardAvoidingWithKeyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [noticationCenter addObserver:self selector:@selector(keyboardAvoidingWithKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [noticationCenter addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [noticationCenter addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
}

-(BOOL)hasAutomaticKeyboardAvoidingBehaviour {
    if ( [[[UIDevice currentDevice] systemVersion] integerValue] >= 9.0
        && [self.delegate isKindOfClass:[UICollectionViewController class]] ) {
        return YES;
    }
    return NO;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self keyboardAvoidingUpdateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    if (CGSizeEqualToSize(contentSize, self.contentSize)) {
        return;
    }
    [super setContentSize:contentSize];
    [self keyboardAvoidingUpdateContentInset];
}

- (BOOL)focusNextTextField {
    return [self keyboardAvoidingFocusNextTextField];
    
}
- (void)scrollToActiveTextField {
    return [self keyboardAvoidingScrollToActiveTextField];
}

#pragma mark - Responders, events
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ( !newSuperview ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(keyboardAvoidingAssignTextDelegateForViewsBeneathView:) object:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self keyboardAvoidingFindFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {
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

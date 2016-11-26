//
//  YJKeyboardAvoidTableView.m
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2016/11/26.
//  Copyright © 2016年 YJManager. All rights reserved.
//

#import "YJKeyboardAvoidTableView.h"
#import "UIScrollView+YJKeyboardAvoidingExt.h"

@interface YJKeyboardAvoidTableView () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation YJKeyboardAvoidTableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUpKeyboardAvoidNotificationCenter];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
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


- (BOOL)hasAutomaticKeyboardAvoidingBehaviour{
    if ([self.delegate isKindOfClass:[UITableViewController class]]) {
        return YES;
    }
    return NO;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) return;
    [self keyboardAvoidingUpdateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) {
        [super setContentSize:contentSize];
        return;
    }
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
-(void)willMoveToSuperview:(UIView *)newSuperview {
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

//
//  UIScrollView+YJKeyboardAvoidingExt.m
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2016/11/26.
//  Copyright © 2016年 YJManager. All rights reserved.
//

#import "UIScrollView+YJKeyboardAvoidingExt.h"
#import <objc/message.h>

///////////////// 键盘的状态 ///////////////////////
@interface YJKeyboardAvoidingStatus : NSObject

@property (nonatomic, assign) UIEdgeInsets priorInset;
@property (nonatomic, assign) UIEdgeInsets priorScrollIndicatorInsets;
@property (nonatomic, assign) BOOL         keyboardVisible;
@property (nonatomic, assign) CGRect       keyboardRect;
@property (nonatomic, assign) CGSize       priorContentSize;
@property (nonatomic, assign) BOOL         priorPagingEnabled;
@property (nonatomic, assign) BOOL         ignoringNotifications;
@property (nonatomic, assign) BOOL         keyboardAnimationInProgress;

@end

@implementation YJKeyboardAvoidingStatus
@end


///////////////// UIScrollView 分类 ///////////////////////
static char const * const kKeyboardStatusKey      =  "kKeyboardStatusKey";

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL? UIKeyboardFrameEndUserInfoKey:@"UIKeyboardBoundsUserInfoKey")

// 参数
static NSString *const YJKeyboardAvoidScrollViewClassName = @"YJKeyboardAvoidingScrollView";
static const CGFloat kCalculatedContentPadding = 10.0f;
static const CGFloat kMinimumScrollOffsetPadding = 20.0f;

@implementation UIScrollView (YJKeyboardAvoidingExt)


- (void)keyboardAvoidingWithKeyboardWillShow:(NSNotification *)notification{

    // 1.获取键盘的的 Frame
    CGRect keyboardFrame = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    if (CGRectIsEmpty(keyboardFrame)) {return;}
    
    // 2.获取键盘的状态
    YJKeyboardAvoidingStatus *status = [self _keyboardAvoidingStatus];
    if (status.ignoringNotifications) {return;}
    status.keyboardRect = keyboardFrame;
    
    // 3.如果键盘不可见
    if (!status.keyboardVisible) {
        status.priorInset = self.contentInset;
        status.priorScrollIndicatorInsets = self.scrollIndicatorInsets;
        status.priorPagingEnabled = self.pagingEnabled;
    }
    
    // 4.开始修改
    status.keyboardVisible = YES;
    self.pagingEnabled = NO;
    
    if ([self isKindOfClass:NSClassFromString(YJKeyboardAvoidScrollViewClassName)]) {
        status.priorContentSize = self.contentSize;
        
        if (CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
            self.contentSize = [self keyboardAvoidingCalculatedContentSizeFromSubviewFrames];
        }
    }
    
    // 5.使光标位置在文本视图中可用
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 *NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(keyboardViewAnimationWillStartAppear:context:)];
        [UIView setAnimationDidStopSelector:@selector(keyboardViewAnimationDidStopDisappear:finished:context:)];
        
        [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
        
        self.contentInset = [self keyboardAvoidingContentInsetForKeyboard];
        
        UIView *firstResponder = [self keyboardAvoidingFindFirstResponderBeneathView:self];
        if (firstResponder) {
            CGFloat viewableHeight = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
            [self setContentOffset:CGPointMake(self.contentOffset.x,
                                               [self _keyboardAvoidingIdealOffsetForView:firstResponder viewAreaHeight:viewableHeight]) animated:NO];
        }
        self.scrollIndicatorInsets = self.contentInset;
        [self layoutIfNeeded];
        [UIView commitAnimations];
    });
    
    
}

/** 键盘开始动画 */
- (void)keyboardViewAnimationWillStartAppear:(NSString *)animationId context:(void *)context{
    [self _keyboardAvoidingStatus].keyboardAnimationInProgress = YES;
}

/** 键盘动画已经结束 */
- (void)keyboardViewAnimationDidStopDisappear:(NSString *)animatonId finished:(BOOL)finished context:(void *)context{
    if (finished) {
        [self _keyboardAvoidingStatus].keyboardAnimationInProgress = NO;
    }
}

- (void)keyboardAvoidingWithKeyboardWillHide:(NSNotification *)notification{

    // 1.获取键盘的的 Frame
    CGRect keyboardFrame = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    if (CGRectIsEmpty(keyboardFrame) && ![self _keyboardAvoidingStatus].keyboardAnimationInProgress) {return;}
    
    YJKeyboardAvoidingStatus *status = [self _keyboardAvoidingStatus];
    
    if (status.ignoringNotifications) {return;}
    
    if (!status.keyboardVisible) {return;}
    
    status.keyboardRect = CGRectZero;
    status.keyboardVisible = NO;
    
    // 动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    if ([self isKindOfClass:NSClassFromString(YJKeyboardAvoidScrollViewClassName)]) {
        self.contentSize = status.priorContentSize;
    }
    
    self.contentInset = status.priorInset;
    
    self.scrollIndicatorInsets = status.priorScrollIndicatorInsets;
    
    self.pagingEnabled = status.priorPagingEnabled;
    
    [self layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardAvoidingUpdateContentInset{
    
    YJKeyboardAvoidingStatus *status = [self _keyboardAvoidingStatus];
    if (status.keyboardVisible) {
        self.contentInset = [self keyboardAvoidingContentInsetForKeyboard];
    }
}

- (void)keyboardAvoidingUpdateFromContentSizeChange{
    
    YJKeyboardAvoidingStatus *status = [self _keyboardAvoidingStatus];
    if (status.keyboardVisible) {
        status.priorContentSize = self.contentSize;
        self.contentInset = [self keyboardAvoidingContentInsetForKeyboard];
    }
}

- (BOOL)keyboardAvoidingFocusNextTextField{
    
    UIView *firstResponder = [self keyboardAvoidingFindFirstResponderBeneathView:self];
    if (!firstResponder) {
        return NO;
    }
    UIView *view = [self keyboardAvoidingFindNextInputViewAfterView:firstResponder beneathView:self];
    
    if (view) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            YJKeyboardAvoidingStatus *state = [self _keyboardAvoidingStatus];
            state.ignoringNotifications = YES;
            [view becomeFirstResponder];
            state.ignoringNotifications = NO;
        });
        return YES;
    }
    return NO;
}

-(void)keyboardAvoidingScrollToActiveTextField{
    
    YJKeyboardAvoidingStatus *state = [self _keyboardAvoidingStatus];
    if (!state.keyboardVisible) return;
    
    UIView *firstResponder = [self keyboardAvoidingFindFirstResponderBeneathView:self];
    if (!firstResponder) {return;}
    state.ignoringNotifications = YES;
    CGFloat visibleSpace = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    
    CGPoint idealOffset = CGPointMake(self.contentOffset.x,
                  [self _keyboardAvoidingIdealOffsetForView:firstResponder viewAreaHeight:visibleSpace]);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setContentOffset:idealOffset animated:YES];
        state.ignoringNotifications = NO;
    });
}

- (void)keyboardAvoidingAssignTextDelegateForViewsBeneathView:(UIView *)view{
    for ( UIView *childView in view.subviews ) {
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) ) {
            [self keyboardAvoidingInitializeView:childView];
        } else {
            [self keyboardAvoidingAssignTextDelegateForViewsBeneathView:childView];
        }
    }
}

#pragma mark - Setting_Support -
- (YJKeyboardAvoidingStatus *)_keyboardAvoidingStatus{
    
    YJKeyboardAvoidingStatus *status = objc_getAssociatedObject(self, kKeyboardStatusKey);
    if (status == nil) {
        status = [[YJKeyboardAvoidingStatus alloc] init];
        objc_setAssociatedObject(self, kKeyboardStatusKey, status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return status;
}

-(CGSize)keyboardAvoidingCalculatedContentSizeFromSubviewFrames{
    
    BOOL wasShowingVerticalScrollIndicator = self.showsVerticalScrollIndicator;
    BOOL wasShowingHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    CGRect rect = CGRectZero;
    for (UIView *subView in self.subviews) {
        rect = CGRectUnion(rect, subView.frame);
    }
    rect.size.height += kCalculatedContentPadding;
    
    self.showsVerticalScrollIndicator = wasShowingVerticalScrollIndicator;
    self.showsHorizontalScrollIndicator = wasShowingHorizontalScrollIndicator;
    return rect.size;
}

/** 键盘的边距 */
- (UIEdgeInsets)keyboardAvoidingContentInsetForKeyboard{
    
    YJKeyboardAvoidingStatus *status = [self _keyboardAvoidingStatus];
    UIEdgeInsets newInset = self.contentInset;
    CGRect keyboardRect = status.keyboardRect;
    newInset.bottom = keyboardRect.size.height - MAX((CGRectGetMaxY(keyboardRect) - CGRectGetMaxY(self.bounds)), 0);
    return newInset;
}

/**< 寻找第一响应者 */
- (UIView *)keyboardAvoidingFindFirstResponderBeneathView:(UIView *)view {
    // 递归
    for (UIView *childView in view.subviews) {
        if ([childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder]) return childView;
        UIView *result = [self keyboardAvoidingFindFirstResponderBeneathView:childView];
        if (result) return result;
    }
    return nil;
}

/** 高度适配 理想 */
- (CGFloat)_keyboardAvoidingIdealOffsetForView:(UIView *)view viewAreaHeight:(CGFloat)viewAreaHeight{
    
    CGSize contentSize = self.contentSize;
    __block CGFloat offset = 0.0;
    CGRect subviewRect = [view convertRect:view.bounds toView:self];
    __block CGFloat padding = 0.0;
    void(^centerViewInViewableArea)()  = ^ {
        padding = (viewAreaHeight - subviewRect.size.height) * 0.5;
        
        if (padding < kMinimumScrollOffsetPadding ) {
            padding = kMinimumScrollOffsetPadding;
        }
        offset = subviewRect.origin.y - padding - self.contentInset.top;
    };
    
    if ([view conformsToProtocol:@protocol(UITextInput)]) {
        UIView <UITextInput> *textInput = (UIView <UITextInput>*)view;
        UITextPosition *caretPosition = [textInput selectedTextRange].start;
        if (caretPosition) {
            CGRect caretRect = [self convertRect:[textInput caretRectForPosition:caretPosition] fromView:textInput];
            padding = (viewAreaHeight - caretRect.size.height) * 0.5;
            
            if (padding < kMinimumScrollOffsetPadding ) {
                padding = kMinimumScrollOffsetPadding;
            }
            offset = caretRect.origin.y - padding - self.contentInset.top;
        } else {
            centerViewInViewableArea();
        }
    } else {
        centerViewInViewableArea();
    }

    CGFloat maxOffset = contentSize.height - viewAreaHeight - self.contentInset.top;
    if (offset > maxOffset) {
        offset = maxOffset;
    }
    if (offset < -self.contentInset.top) {
        offset = -self.contentInset.top;
    }
    return offset;
}

- (CGFloat)keyboardAvoidingNextInputViewHeuristicForViewFrame:(CGRect)frame{
    return  (-frame.origin.y * 1000.0) + (-frame.origin.x);
}

- (BOOL)keyboardAvoidingViewHiddenOrUserInteractionNotEnabled:(UIView *)view {
    while (view) {
        if (view.hidden || !view.userInteractionEnabled) {
            return YES;
        }
        view = view.superview;
    }
    return NO;
}

/** 递归方式寻找next */
- (void)keyboardAvoidingFindNextInputViewAfterView:(UIView *)priorView beneathView:(UIView *)beneathView bestCandidate:(UIView **)bestCandidate {
    
    CGRect priorFrame = [self convertRect:priorView.frame fromView:priorView.superview];
    CGRect candidateFrame = *bestCandidate ? [self convertRect:(*bestCandidate).frame fromView:(*bestCandidate).superview] : CGRectZero;
    CGFloat bestCandidateHeuristic = [self keyboardAvoidingNextInputViewHeuristicForViewFrame:candidateFrame];
    
    for ( UIView *childView in beneathView.subviews ) {
        if ( [self keyboardAvoidingViewIsValidKeyViewCandidate:childView] ) {
            CGRect frame = [self convertRect:childView.frame fromView:beneathView];
            
            // Use a heuristic to evaluate candidates
            CGFloat heuristic = [self keyboardAvoidingNextInputViewHeuristicForViewFrame:frame];
            
            // Find views beneath, or to the right. For those views that match, choose the view closest to the top left
            if ( childView != priorView
                && ((fabs(CGRectGetMinY(frame) - CGRectGetMinY(priorFrame)) < FLT_EPSILON && CGRectGetMinX(frame) > CGRectGetMinX(priorFrame))
                    || CGRectGetMinY(frame) > CGRectGetMinY(priorFrame))
                && (!*bestCandidate || heuristic > bestCandidateHeuristic) ) {
                
                *bestCandidate = childView;
                bestCandidateHeuristic = heuristic;
            }
        } else {
            [self keyboardAvoidingFindNextInputViewAfterView:priorView beneathView:childView bestCandidate:bestCandidate];
        }
    }
}

- (UIView *)keyboardAvoidingFindNextInputViewAfterView:(UIView *)priorView beneathView:(UIView *)beneathView{
    UIView *candidate = nil;
    [self keyboardAvoidingFindNextInputViewAfterView:priorView beneathView:beneathView bestCandidate:&candidate];
    return candidate;
}

#pragma mark - 支持的类型
- (BOOL)keyboardAvoidingViewIsValidKeyViewCandidate:(UIView *)view{
    if ( [self keyboardAvoidingViewHiddenOrUserInteractionNotEnabled:view] ) return NO;
    if ( [view isKindOfClass:[UITextField class]] && ((UITextField *)view).enabled) {
        return YES;
    }
    
    if ( [view isKindOfClass:[UITextView class]] && ((UITextView *)view).isEditable) {
        return YES;
    }
    return NO;
}

- (void)keyboardAvoidingInitializeView:(UIView *)view {
    if ( [view isKindOfClass:[UITextField class]]
        && ((UITextField*)view).returnKeyType == UIReturnKeyDefault
        && (![(UITextField*)view delegate] || [(UITextField*)view delegate] == (id<UITextFieldDelegate>)self) ) {
        [(UITextField*)view setDelegate:(id<UITextFieldDelegate>)self];
        UIView *otherView = [self keyboardAvoidingFindNextInputViewAfterView:view beneathView:self];
        if (otherView) {
            ((UITextField*)view).returnKeyType = UIReturnKeyNext;
        } else {
            ((UITextField*)view).returnKeyType = UIReturnKeyDone;
        }
    }
}

@end

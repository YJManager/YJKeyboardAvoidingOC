//
//  YJKeyboardAvoidTableView.h
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2016/11/26.
//  Copyright © 2016年 YJManager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJKeyboardAvoidTableView : UITableView

- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

@end

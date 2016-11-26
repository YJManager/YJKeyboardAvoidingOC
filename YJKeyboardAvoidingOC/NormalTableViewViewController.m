//
//  NormalTableViewViewController.m
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2016/11/27.
//  Copyright © 2016年 YJManager. All rights reserved.
//

#import "NormalTableViewViewController.h"
#import "YJKeyboardAvoidTableView.h"

@interface NormalTableViewViewController () <UITableViewDataSource>

@property (nonatomic, strong) YJKeyboardAvoidTableView * tableView;


@end

@implementation NormalTableViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        cell.accessoryView = textField;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Label %d", (int)indexPath.row];
    ((UITextField*)cell.accessoryView).placeholder = [NSString stringWithFormat:@"Field %d", (int)indexPath.row];
    
    return cell;
}


- (YJKeyboardAvoidTableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[YJKeyboardAvoidTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        [_tableView setTableFooterView:[UIView new]];
    }
    return _tableView;
}

@end

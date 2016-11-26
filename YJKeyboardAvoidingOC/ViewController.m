//
//  ViewController.m
//  YJKeyboardAvoidingOC
//
//  Created by YJHou on 2016/11/26.
//  Copyright © 2016年 YJManager. All rights reserved.
//

#import "ViewController.h"
#import "ScroollViewController.h"
#import "TableViewController.h"
#import "NormalTableViewViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segMentedControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)segmentedActionClick:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
//        ScroollViewController *scroollVc = [[ScroollViewController alloc] init];
//        [self.navigationController pushViewController:scroollVc animated:YES];
    }else if (sender.selectedSegmentIndex == 1){
        TableViewController *tabelVc = [[TableViewController alloc] init];
        [self.navigationController pushViewController:tabelVc animated:YES];
    }else if (sender.selectedSegmentIndex == 2){
        NormalTableViewViewController *tabelVc = [[NormalTableViewViewController alloc] init];
        [self.navigationController pushViewController:tabelVc animated:YES];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

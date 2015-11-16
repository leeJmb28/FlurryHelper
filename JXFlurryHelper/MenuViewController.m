//
//  MenuViewController.m
//  JXFlurryHelper
//
//  Created by JLee21 on 2015/11/12.
//  Copyright © 2015年 VS7X. All rights reserved.
//

#import "MenuViewController.h"
#import "FlurryHelper.h"
#import "AdViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"JXFlurryHelperDemo";
    [[FlurryHelper sharedHelper] activeWithKey:kFlurryKey withHandler:^(BOOL success, id response) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openAd:(UIButton *)button
{
    AdViewController *adView = [[AdViewController alloc] init];
    adView.title = button.titleLabel.text;
    [self.navigationController pushViewController:adView animated:YES];
}

@end

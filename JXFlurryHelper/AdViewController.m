//
//  AdViewController.m
//  JXFlurryHelper
//
//  Created by JLee21 on 2015/11/12.
//  Copyright © 2015年 VS7X. All rights reserved.
//

#import "AdViewController.h"
#import "FlurryHelper.h"

@interface AdViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *newsList;
}
@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self.title isEqualToString:@"BannerAd"]) {
        
        [[FlurryHelper sharedHelper] showBannerAdInView:self.view withTarget:self andHandler:^(BOOL success, id response) {
            
        }];
        
    } else if ([self.title isEqualToString:@"FullscreenAd"]) {
        
        [[FlurryHelper sharedHelper] showFullscreenAdWithTarget:self andHandler:^(BOOL success, id response) {
            
        }];
    } else if ([self.title isEqualToString:@"NativeAd"]) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        
        newsList = [NSMutableArray array];
        __weak UITableView *weakTableView = tableView;
        for (int n=1; n<=20; n++)
        {
            if (0 == n%5) {
                id tempAd = [[FlurryHelper sharedHelper] getNativeAdWithHandler:^(BOOL success, id response) {
                    
                    if (success) {
                        
                        [weakTableView beginUpdates];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:n-1 inSection:0];
                        [weakTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [weakTableView endUpdates];
                    }
                }];
                [newsList addObject:tempAd];
                
            } else {
                NSDictionary *news = @{@"headline":[NSString stringWithFormat:@"News-%d",n],
                                       @"summary":[NSString stringWithFormat:@"Summary-%d",n]};
                [newsList addObject:news];
            }
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return newsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellType];
    }
    
    NSInteger index = indexPath.row;
    if ([newsList[index] isKindOfClass:[FlurryAdNative class]]) {
        
        FlurryAdNative *ad = newsList[index];
        if (ad.ready) {
            
            for (FlurryAdNativeAsset *asset in ad.assetList)
            {
                if ([asset.name isEqualToString:@"headline"]) {
                    cell.textLabel.text = asset.value;
                }
                if ([asset.name isEqualToString:@"summary"]) {
                    cell.detailTextLabel.text = asset.value;
                }
            }
        } else {
            
            cell.textLabel.text = [NSString stringWithFormat:@"Ad not ready-%ld",index];
            cell.detailTextLabel.text = @"";
        }
    } else {
        
        NSDictionary *news = newsList[index];
        cell.textLabel.text = [news objectForKey:@"headline"];
        cell.detailTextLabel.text = [news objectForKey:@"summary"];
    }
    return cell;
}

@end

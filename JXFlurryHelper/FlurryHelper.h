//
//  FlurryHelper.h
//  JXFlurryHelper
//
//  Created by JLee21 on 2015/11/12.
//  Copyright © 2015年 VS7X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FlurryAdNative.h"

static NSString *const kFlurryKey = @"2WZ22NRSX8W52VKZBX9G"; //Use your own Flurry key

typedef void (^FlurryCallback)(BOOL success, id response);

@interface FlurryHelper : NSObject

+ (instancetype)sharedHelper;
- (void)activeWithKey:(NSString *)key withHandler:(FlurryCallback)callback;

/// Ads
- (void)showBannerAdInView:(UIView *)view withTarget:(UIViewController *)viewController andHandler:(FlurryCallback)callback;
- (void)showFullscreenAdWithTarget:(UIViewController *)viewController andHandler:(FlurryCallback)callback;
- (id)getNativeAdWithHandler:(FlurryCallback)callback;

/// Event and Error logger
+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)params;
+ (void)logError:(NSString *)errorName withMessage:(NSString *)message andError:(NSError *)error;
@end
//
//  FlurryHelper.m
//  JXFlurryHelper
//
//  Created by JLee21 on 2015/11/12.
//  Copyright © 2015年 VS7X. All rights reserved.
//

#import "FlurryHelper.h"

#import "FlurryHelper.h"
#import <objc/runtime.h>

#import "Flurry.h"
#import "FlurryAds.h"

/*------------------------------------------------------------------*/
#import "FlurryAdBanner.h"
#import "FlurryAdBannerDelegate.h"
static NSString *adSpaceBanner = @"Banner"; //Replaced by your adSpace

#import "FlurryAdInterstitial.h"
#import "FlurryAdInterstitialDelegate.h"
static NSString *adSpaceFullscreen = @"Takeover"; //Replaced by your adSpace

#import "FlurryAdNative.h"
#import "FlurryAdNativeDelegate.h"
static NSString *const adSpaceNative = @"InStream"; //Replaced by your adSpace

static char kAdAssociatedObjectKey;
static NSString *const kAdView = @"AdView";
static NSString *const kAdTarget = @"AdTarget";
static NSString *const kAdCallback = @"AdCallback";
/*------------------------------------------------------------------*/


@interface FlurryHelper()
<FlurryDelegate, FlurryAdBannerDelegate, FlurryAdInterstitialDelegate, FlurryAdNativeDelegate>
@end

@implementation FlurryHelper

#pragma mark - Exception handler

void uncaughtExceptionHandler(NSException *exception)
{
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

#pragma mark - Public Method

+ (instancetype)sharedHelper
{
    static FlurryHelper *_helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[FlurryHelper alloc] init];
    });
    return _helper;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        [Flurry setDelegate:self];
        //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
        [Flurry setCrashReportingEnabled:YES];
        [Flurry setLogLevel:FlurryLogLevelAll];
        
        [Flurry setDebugLogEnabled:NO];
        [FlurryAds enableTestAds:NO];
    }
    return self;
}

- (void)activeWithKey:(NSString *)key withHandler:(FlurryCallback)callback
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    objc_setAssociatedObject(self,&kAdAssociatedObjectKey,callback,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [Flurry startSession:key];
}

#pragma mark - Flurry delegate

- (void)flurrySessionDidCreateWithInfo:(NSDictionary *)info
{
    FlurryCallback callback = objc_getAssociatedObject(self, &kAdAssociatedObjectKey);
    if (callback) {
        
        if (nil == info) {
            callback(NO, @"Flurry activate failed!");
        } else {
            callback(YES, nil);
        }
    }
}

#pragma mark - Ads
#pragma mark Banner Ad

- (void)showBannerAdInView:(UIView *)view withTarget:(UIViewController *)viewController andHandler:(FlurryCallback)callback
{
    FlurryAdBanner *adBanner = [[FlurryAdBanner alloc] initWithSpace:adSpaceBanner];
    adBanner.adDelegate = self;
    NSDictionary *parameters = @{kAdView:view,
                                 kAdTarget:viewController,
                                 kAdCallback:callback};
    objc_setAssociatedObject(adBanner,&kAdAssociatedObjectKey,parameters,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [adBanner fetchAndDisplayAdInView:view viewControllerForPresentation:viewController];
    //[adBanner fetchAdForFrame:view.frame];
}

#pragma mark Banner AdDelegate

- (void)adBannerDidFetchAd:(FlurryAdBanner *)bannerAd
{
    NSLog(@"[adBanner] didFetchAd");
    NSDictionary *parameter = objc_getAssociatedObject(bannerAd, &kAdAssociatedObjectKey);
    FlurryCallback callback = [parameter objectForKey:kAdCallback];
    if (callback) {
        callback(YES, nil);
    }
}

- (void)adBannerDidRender:(FlurryAdBanner *)bannerAd
{
    NSLog(@"[adBanner] didRender");
}

- (void)adBanner:(FlurryAdBanner *)bannerAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    NSLog(@"[adBanner] adError:%@",errorDescription.localizedDescription);
    NSDictionary *parameter = objc_getAssociatedObject(bannerAd, &kAdAssociatedObjectKey);
    FlurryCallback callback = [parameter objectForKey:kAdCallback];
    if (callback) {
        callback(NO, errorDescription.localizedDescription);
    }
}

#pragma mark Fullscreen Ad

- (void)showFullscreenAdWithTarget:(UIViewController *)viewController andHandler:(FlurryCallback)callback
{
    FlurryAdInterstitial *adInterstital = [[FlurryAdInterstitial alloc] initWithSpace:adSpaceFullscreen];
    adInterstital.adDelegate = self;
    NSDictionary *parameters = @{kAdTarget:viewController,
                                 kAdCallback:callback};
    objc_setAssociatedObject(adInterstital,&kAdAssociatedObjectKey,parameters,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [adInterstital fetchAd];
}

#pragma mark Fullscreen AdDelegate

- (void)adInterstitialDidFetchAd:(FlurryAdInterstitial *)interstitialAd
{
    NSLog(@"[adFullscreen] didFetchAd");
}

- (void)adInterstitialDidDismiss:(FlurryAdInterstitial *)interstitialAd
{
    NSLog(@"[adFullscreen] didDismiss");
    NSDictionary *parameter = objc_getAssociatedObject(interstitialAd, &kAdAssociatedObjectKey);
    FlurryCallback callback = [parameter objectForKey:kAdCallback];
    if (callback) {
        callback(YES, nil);
    }
}

- (void)adInterstitial:(FlurryAdInterstitial *)interstitialAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    NSLog(@"[adFullscreen] adError:%@",errorDescription.localizedDescription);
    NSDictionary *parameter = objc_getAssociatedObject(interstitialAd, &kAdAssociatedObjectKey);
    FlurryCallback callback = [parameter objectForKey:kAdCallback];
    if (callback) {
        callback(NO, errorDescription.localizedDescription);
    }
}

#pragma mark Native Ad

- (id)getNativeAdWithHandler:(FlurryCallback)callback
{
    FlurryAdNative *nativeAd = [[FlurryAdNative alloc] initWithSpace:adSpaceNative];
    nativeAd.adDelegate = self;
    NSDictionary *parameters = @{kAdCallback:callback};
    objc_setAssociatedObject(nativeAd,&kAdAssociatedObjectKey,parameters,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //Request the Ad from Flurry
    [nativeAd fetchAd];
    return nativeAd;
}

#pragma mark Native AdDelegate

- (void)adNativeDidFetchAd:(FlurryAdNative *)nativeAd
{
    NSLog(@"adNative didFetchAd %p",nativeAd);
    NSDictionary *parameter = objc_getAssociatedObject(nativeAd, &kAdAssociatedObjectKey);
    FlurryCallback callback = [parameter objectForKey:kAdCallback];
    if (callback) {
        callback(YES, nativeAd);
    }
}

- (void)adNative:(FlurryAdNative *)nativeAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    [Flurry logError:@"adNative fetchError" message:[errorDescription localizedDescription] error:errorDescription];
    NSDictionary *parameter = objc_getAssociatedObject(nativeAd, &kAdAssociatedObjectKey);
    FlurryCallback callback = [parameter objectForKey:kAdCallback];
    if (callback) {
        callback(NO, errorDescription.localizedDescription);
    }
}

#pragma mark - Event and Error logger

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)params
{
    if (nil == params) {
        [Flurry logEvent:eventName];
    } else {
        [Flurry logEvent:eventName withParameters:params];
    }
}

+ (void)logError:(NSString *)errorName withMessage:(NSString *)message andError:(NSError *)error
{
    [Flurry logError:errorName message:message error:error];
}

@end

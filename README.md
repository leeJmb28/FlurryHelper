JXFlurryHelper
=================

JXFlurryHelper help developers to integrate Flurry Ads/Analytics in a easy way.

## How to use

#### Import

``` objective-c
#import "FlurryHelper.h"
```

#### Common Settings

``` objective-c
// Use singleton or [[FlurryHelper alloc] init]
[FlurryHelper sharedHelper];

// activate with Flurry key
[[FlurryHelper sharedHelper] activeWithKey:@"2WZ22NRSX8W52VKZBX9G" 
                               withHandler:^(BOOL success, id response) {
    // handle response here
}];
```

#### Banner Ad

``` objective-c
[[FlurryHelper sharedHelper] showBannerAdInView:self.view 
                                     withTarget:self
                                     andHandler:^(BOOL success, id response) {
    
}];
```

#### Fullscreen Ad

``` objective-c
[[FlurryHelper sharedHelper] showFullscreenAdWithTarget:self 
                                             andHandler:^(BOOL success, id response) {
    
}];
```

#### Native Ad

``` objective-c
id tempAd = [[FlurryHelper sharedHelper] getNativeAdWithHandler:^(BOOL success, id response) {
                    
    if (success) {
        FlurryAdNative *ad = response;
        // insert the Ad into target list and update UI
    }
}];
```

## Version

V1.0

## License

MIT.

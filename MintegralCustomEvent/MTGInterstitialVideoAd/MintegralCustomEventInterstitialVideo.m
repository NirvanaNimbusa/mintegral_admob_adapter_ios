//
//  MintegralCustomEventInterstitialVideo.m
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventInterstitialVideo.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>

#import "MintegralHelper.h"


#define TIMERDURATION 3.0
#define SUMTIME 10.0

static int secondCount = 0;

@interface MintegralCustomEventInterstitialVideo() <MTGInterstitialVideoDelegate>

@property (nonatomic, copy) NSString *adUnit;
@property (nonatomic,strong) NSTimer  *queryTimer;
@property (nonatomic, readwrite, strong) MTGInterstitialVideoAdManager *mtgInterstitialVideoAdManager;

@end

@implementation MintegralCustomEventInterstitialVideo
@synthesize delegate;


#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    NSDictionary *mintegralInfoDict = [MintegralHelper dictionaryWithJsonString:serverParameter];
    
    NSString *appId = nil;
    if ([mintegralInfoDict objectForKey:@"appId"]) {
        appId = [mintegralInfoDict objectForKey:@"appId"];
    }
    
    NSString *appKey = nil;
    if ([mintegralInfoDict objectForKey:@"appKey"]) {
        appKey = [mintegralInfoDict objectForKey:@"appKey"];
    }
    
    NSString *InterstitialAdUnitId = nil;
    if ([mintegralInfoDict objectForKey:@"unitId"]) {
        InterstitialAdUnitId = [mintegralInfoDict objectForKey:@"unitId"];
    }
    
    if (![MintegralHelper isSDKInitialized]) {
        
        [MintegralHelper setGDPRInfo:mintegralInfoDict];
        //init SDK
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralHelper sdkInitialized];
    }
    
    self.adUnit = InterstitialAdUnitId;
    
    if (!_mtgInterstitialVideoAdManager) {
        _mtgInterstitialVideoAdManager = [[MTGInterstitialVideoAdManager alloc] initWithUnitID:self.adUnit delegate:self];
    }
    
    [_mtgInterstitialVideoAdManager loadAd];
}

/// Present the interstitial ad as a modal view using the provided view controller.
- (void)presentFromRootViewController:(UIViewController *)rootViewController {

    [_mtgInterstitialVideoAdManager showFromViewController:rootViewController];
}

#pragma mark MVInterstitialVideoAdLoadDelegate implementation

- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidReceiveAd:)]) {
        [self.delegate customEventInterstitialDidReceiveAd:self];
    }
    [self stopTimer];
}


- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
        NSError *customEventError = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
        [self.delegate customEventInterstitial:self didFailAd:customEventError];
    }
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillPresent:)]) {
        [self.delegate customEventInterstitialWillPresent:self];
    }
}

- (void)onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{}


- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWillDismiss:)]) {
        [self.delegate customEventInterstitialWillDismiss:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialDidDismiss:)]) {
        [self.delegate customEventInterstitialDidDismiss:self];
    }
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventInterstitialWasClicked:)]) {
        [self.delegate customEventInterstitialWasClicked:self];
    }
}

- (void)checkVideoReady{

}

-(void)fireTimer{
    
    if (secondCount > 0) return;
    
    secondCount = 0;
    
    _queryTimer = [NSTimer  scheduledTimerWithTimeInterval:TIMERDURATION target:self selector:@selector(checkVideoReady) userInfo:nil repeats:YES];
    [_queryTimer fire];
    
}

-(void)stopTimer{
    
    secondCount = 0;
    
    if (_queryTimer.isValid) {
        [_queryTimer invalidate];
        _queryTimer = nil;
    }
    
}




@end
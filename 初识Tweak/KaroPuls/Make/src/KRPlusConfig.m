//
//  KRPlusConfig.m
//  nav_wechat
//
//  Created by AlbertHuang on 2018/10/10.
//  Copyright © 2018 Kangaroo. All rights reserved.
//

#import "KRPlusConfig.h"

@implementation KRPlusConfig

static NSString * const KKRTopBarColorKey = @"KKRTopBarColorKey";
static NSString * const KKRPreventRevokeEnableKey = @"KKRPreventRevokeEnableKey";
static NSString * const KKRIsTopBarColorKey = @"KKRIsTopBarColorKey";
static NSString * const kKRTopBarImageNameKey = @"kKRTopBarImageNameKey";
static NSString * const kKRIsTopBarImageNameKey = @"kKRIsTopBarImageNameKey";


+ (instancetype)sharedConfig {
    static KRPlusConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[KRPlusConfig alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _kr_isTopBarColor       = [[NSUserDefaults standardUserDefaults] boolForKey:KKRIsTopBarColorKey];
        _kr_isTopBarImage       = [[NSUserDefaults standardUserDefaults] boolForKey:kKRIsTopBarImageNameKey];
        _kr_topBarColor         = [[NSUserDefaults standardUserDefaults] objectForKey:KKRTopBarColorKey];
        _kr_topBarImageName     = [[NSUserDefaults standardUserDefaults] objectForKey:kKRTopBarImageNameKey];
        _kr_preventRevokeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KKRPreventRevokeEnableKey];
        
    }
    return self;
}

- (void)setKr_isTopBarColor:(BOOL)kr_isTopBarColor {
    _kr_isTopBarColor = kr_isTopBarColor;
    [self saveBoolValue:kr_isTopBarColor InKey:KKRIsTopBarColorKey];
}

- (void)setKr_isTopBarImage:(BOOL)kr_isTopBarImage {
    _kr_isTopBarImage = kr_isTopBarImage;
    [self saveBoolValue:kr_isTopBarImage InKey:kKRIsTopBarImageNameKey];
}

- (void)setKr_preventRevokeEnable:(BOOL)kr_preventRevokeEnable {
    _kr_preventRevokeEnable = kr_preventRevokeEnable;
    [self saveBoolValue:kr_preventRevokeEnable InKey:KKRPreventRevokeEnableKey];
}

- (void)setKr_topBarColor:(NSString *)kr_topBarColor {
    _kr_topBarColor = kr_topBarColor;
    [self saveValue:kr_topBarColor InKey:KKRTopBarColorKey];
}

- (void)setKr_topBarImageName:(NSString *)kr_topBarImageName {
    _kr_topBarImageName = kr_topBarImageName;
    [self saveValue:kr_topBarImageName InKey:kKRTopBarImageNameKey];
}


- (void)saveValue:(NSString *)value InKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveBoolValue:(BOOL)value InKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

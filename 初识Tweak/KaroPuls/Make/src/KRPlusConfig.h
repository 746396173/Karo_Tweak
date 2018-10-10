//
//  KRPlusConfig.h
//  nav_wechat
//
//  Created by AlbertHuang on 2018/10/10.
//  Copyright © 2018 Kangaroo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRPlusConfig : NSObject
+ (instancetype)sharedConfig;
/**  微信导航栏配置 */
@property (nonatomic, copy) NSString *kr_topBarColor;
@property (nonatomic, assign) BOOL kr_isTopBarColor;
@property (nonatomic, copy) NSString *kr_topBarImageName;
@property (nonatomic, assign) BOOL kr_isTopBarImage;
/**  微信功能配置 */
@property (nonatomic, assign) BOOL kr_preventRevokeEnable;
@end


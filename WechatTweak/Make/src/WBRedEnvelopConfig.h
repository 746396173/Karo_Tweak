//
//  WBRedEnvelopConfig.h
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@class CContact;
@interface WBRedEnvelopConfig : NSObject

+ (instancetype)sharedConfig;

@property (assign, nonatomic) BOOL autoReceiveEnable;

@property (assign, nonatomic) NSInteger delaySeconds;

/** Pro */
@property (assign, nonatomic) BOOL receiveSelfRedEnvelop;
@property (assign, nonatomic) BOOL serialReceive;
@property (strong, nonatomic) NSArray *blackList;
@property (assign, nonatomic) BOOL revokeEnable;

//程序进入后台处理
- (void)enterBackgroundHandler;
@property (nonatomic, assign) BOOL isOpenBackgroundMode; //是否开启后台模式
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskIdentifier; //后台任务标识符
@property (nonatomic, strong) NSTimer *bgTaskTimer; //后台任务定时器
@property (nonatomic, strong) AVAudioPlayer *blankPlayer; //无声音频播放器

@end

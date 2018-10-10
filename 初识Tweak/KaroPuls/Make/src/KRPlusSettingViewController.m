//
//  KRPlusSettingViewController.m
//  nav_wechat
//
//  Created by AlbertHuang on 2018/10/10.
//  Copyright © 2018 Kangaroo. All rights reserved.
//

#import "KRPlusSettingViewController.h"
#import "KRPlusRobot.h"
@interface KRPlusSettingViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation KRPlusSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        CGRect winSize = [UIScreen mainScreen].bounds;
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:winSize style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadTableData];
    [self initTitle];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
    
}

- (void)initTitle {
    self.title = @"微信小配置";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0],NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    [self addTopBarSection];
    [self addNiubilitySection];
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - 设置 TableView

- (void)addTopBarSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"UI修改。" Footer:nil];
    [sectionInfo addCell:[self createTopBarColorCell]];
    if ([[KRPlusConfig sharedConfig] kr_isTopBarColor]) {
        [sectionInfo addCell:[self createStepTopBarColorCell]];
    }
    [sectionInfo addCell:[self createTopBarImageCell]];
    if ([[KRPlusConfig sharedConfig] kr_isTopBarImage]) {
        [sectionInfo addCell:[self createStepTopBarImageCell]];
    }
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (void)addNiubilitySection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"功能点。" Footer:nil];

    [sectionInfo addCell:[self createRevokeSwitchCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

#pragma mark - 导航栏

- (MMTableViewCellInfo *)createTopBarColorCell {
    BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingTopBarColorSwitch:) target:self title:@"是否修改导航栏颜色" on:kr_isTopBarColor];
    
    return cellInfo;
}

- (MMTableViewCellInfo *)createStepTopBarColorCell {
    NSString *kr_topBarColor = [[KRPlusConfig sharedConfig] kr_topBarColor];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingStepTopBarColor) target:self title:@"RGB色值" rightValue:kr_topBarColor accessoryType:1];
    
    return cellInfo;
}

- (MMTableViewCellInfo *)createTopBarImageCell {
    BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingTopBarImageSwitch:) target:self title:@"是否修改导航栏背景图" on:kr_isTopBarImage];
    
    return cellInfo;
}

- (MMTableViewCellInfo *)createStepTopBarImageCell {
    NSString *kr_topBarColor = [[KRPlusConfig sharedConfig] kr_topBarColor];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingStepTopBarImage) target:self title:@"图片文件名(png)" rightValue:kr_topBarColor accessoryType:1];
    
    return cellInfo;
}

- (MMTableViewCellInfo *)createRevokeSwitchCell {
    BOOL kr_preventRevokeEnable = [[KRPlusConfig sharedConfig] kr_preventRevokeEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingRevokeSwitch:) target:self title:@"拦截撤回消息" on:kr_preventRevokeEnable];
    
    return cellInfo;
}

#pragma mark - 设置cell相应的方法
- (void)settingTopBarColorSwitch:(UISwitch *)arg {
    [[KRPlusConfig sharedConfig] setKr_isTopBarColor:arg.on];
    [self reloadTableData];
}

- (void)settingTopBarImageSwitch:(UISwitch *)arg {
    [[KRPlusConfig sharedConfig] setKr_isTopBarImage:arg.on];
    [self reloadTableData];
}

- (void)settingRevokeSwitch:(UISwitch *)arg {
    [[KRPlusConfig sharedConfig] setKr_preventRevokeEnable:arg.on];
    [self reloadTableData];
}

- (void)settingStepTopBarColor {
    [self alertControllerWithTitle:@"RGB色值设置"
                           message:@""
                           content:@""
                       placeholder:@"请输入RGB色值"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [[KRPlusConfig sharedConfig] setKr_topBarColor:textField.text];
                                   [self reloadTableData];
                               }];
}

- (void)settingStepTopBarImage {
    [self alertControllerWithTitle:@"图片文件名"
                           message:@""
                           content:@""
                       placeholder:@"请输入图片文件名"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [[KRPlusConfig sharedConfig] setKr_topBarImageName:textField.text];
                                   [self reloadTableData];
                               }];
}

#pragma mark - Private Methods

- (void)alertControllerWithTitle:(NSString *)title content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:nil content:content placeholder:placeholder blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:message content:content placeholder:placeholder keyboardType:UIKeyboardTypeDefault blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType blk:(void (^)(UITextField *))blk  {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (blk) {
                                                        blk(alert.textFields.firstObject);
                                                    }
                                                }]];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeholder;
            textField.text = content;
            textField.keyboardType = keyboardType;
        }];
        
        alert;
    });
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

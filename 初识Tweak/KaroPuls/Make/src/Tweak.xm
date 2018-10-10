#import "KRPlusSettingViewController.h"
#import "KRPlusRobot.h"

%hook CMessageMgr
- (void)onRevokeMsg:(CMessageWrap *)arg1 {
    if ([[KRPlusConfig sharedConfig] kr_preventRevokeEnable]) {
        NSString *msgContent = arg1.m_nsContent;

        NSString *(^parseParam)(NSString *, NSString *,NSString *) = ^NSString *(NSString *content, NSString *paramBegin,NSString *paramEnd) {
            NSUInteger startIndex = [content rangeOfString:paramBegin].location + paramBegin.length;
            NSUInteger endIndex = [content rangeOfString:paramEnd].location;
            NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
            return [content substringWithRange:range];
        };

        NSString *session = parseParam(msgContent, @"<session>", @"</session>");
        NSString *newmsgid = parseParam(msgContent, @"<newmsgid>", @"</newmsgid>");
        NSString *fromUsrName = parseParam(msgContent, @"<![CDATA[", @"撤回了一条消息");
        CMessageWrap *revokemsg = [self GetMsg:session n64SvrID:[newmsgid integerValue]];

        CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
        CContact *selfContact = [contactMgr getSelfContact];
        NSString *newMsgContent = @"";


        if ([revokemsg.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
        if (revokemsg.m_uiMessageType == 1) {       // 判断是否为文本消息
            newMsgContent = [NSString stringWithFormat:@"拦截到你撤回了一条消息：\n %@",revokemsg.m_nsContent];
        } else {
            newMsgContent = @"拦截到你撤回一条消息";
        }
        } else {
        if (revokemsg.m_uiMessageType == 1) {
            newMsgContent = [NSString stringWithFormat:@"拦截到一条 %@撤回消息：\n %@",fromUsrName, revokemsg.m_nsContent];
        } else {
            newMsgContent = [NSString stringWithFormat:@"拦截到一条 %@撤回消息",fromUsrName];
        }
    }

    CMessageWrap *newWrap = ({
        CMessageWrap *msg = [[%c(CMessageWrap) alloc] initWithMsgType:0x2710];
        [msg setM_nsFromUsr:revokemsg.m_nsFromUsr];
        [msg setM_nsToUsr:revokemsg.m_nsToUsr];
        [msg setM_uiStatus:0x4];
        [msg setM_nsContent:newMsgContent];
        [msg setM_uiCreateTime:[arg1 m_uiCreateTime]];

        msg;
    });

    [self AddLocalMsg:session MsgWrap:newWrap fixTime:0x1 NewMsgArriveNotify:0x0];
    return;
    }
    %orig;
}
%end

%hook NewSettingViewController
- (void)reloadTableData {
	%orig;
	MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");
	MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];
	MMTableViewCellInfo *groupSettingCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(groupSetting) target:self title:@"额外功能~" accessoryType:1];
    [sectionInfo addCell:groupSettingCell];
	[tableViewInfo insertSection:sectionInfo At:0];
	MMTableView *tableView = [tableViewInfo getTableView];
	[tableView reloadData];
}

- (id)navigationBarBackgroundColor {
    BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;

}

%new
- (void)groupSetting {
	KRPlusSettingViewController *settingViewController = [[KRPlusSettingViewController alloc] init];
	[self.navigationController PushViewController:settingViewController animated:YES];
}
%end

%hook NewMainFrameViewController
- (id)navigationBarBackgroundColor {
    BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}

- (void)searchDisplayControllerWillEndSearch:(id)arg1 {
    NSLog(@"即将关闭搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] && ![tmpView isKindOfClass:NSClassFromString(@"MMMainTableView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:NO];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}
- (void)searchDisplayControllerDidBeginSearch:(id)arg1 {
    NSLog(@"已经打开搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] && ![tmpView isKindOfClass:NSClassFromString(@"MMMainTableView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:YES];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}

- (void)searchDisplayControllerWillBeginSearch:(id)arg1{
    NSLog(@"即将打开搜索栏");
    %orig;
}
%end

%hook ContactsViewController
- (id)navigationBarBackgroundColor {
    BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
 
    
}
- (void)searchDisplayControllerWillEndSearch:(id)arg1 {
    NSLog(@"即将关闭搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] && ![tmpView isKindOfClass:NSClassFromString(@"MMMainTableView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:NO];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}
- (void)searchDisplayControllerDidBeginSearch:(id)arg1 {
    NSLog(@"已经打开搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] && ![tmpView isKindOfClass:NSClassFromString(@"MMMainTableView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:YES];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}

- (void)searchDisplayControllerWillBeginSearch:(id)arg1{
    NSLog(@"即将打开搜索栏");
    %orig;
}

%end

%hook FindFriendEntryViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
%end

%hook MoreViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
%end

%hook BaseMsgContentViewController
- (id)navigationBarBackgroundColor {
    BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    NSLog(@"%@",[self.view subviews]);
    if ([self.view subviews].count > 5 ){
        //先判断是否有UISearchDisplayControllerContainerView
        BOOL isSearchView = NO;
        for (id tmpView in [self.view subviews]) {
            if ([tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                isSearchView = YES;
                break;
            }
        }
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] 
            && ![tmpView isKindOfClass:NSClassFromString(@"MMUISearchBar")] 
            && ![tmpView isKindOfClass:NSClassFromString(@"YYTableView")] 
            && ![tmpView isKindOfClass:NSClassFromString(@"MMMultiSelectToolView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"MMInputToolView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"UIImageView")]
            && ((UIView *)tmpView).frame.size.height < 200
            &&  isSearchView) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:YES];
                    NSLog(@"%@",topView);
                    break;
                
            }
        }
    }
}
%end
%hook ContactInfoViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
%end
%hook ChatRoomInfoViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
%end
%hook AddContactToChatRoomViewController
- (id)navigationBarBackgroundColor {
    BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
%end

%hook BrandContactsViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}

- (void)searchDisplayControllerWillEndSearch:(id)arg1 {
    NSLog(@"即将关闭搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] && ![tmpView isKindOfClass:NSClassFromString(@"MMTableView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:NO];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}
- (void)searchDisplayControllerDidBeginSearch:(id)arg1 {
    NSLog(@"已经打开搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] && ![tmpView isKindOfClass:NSClassFromString(@"MMTableView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:YES];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}

- (void)searchDisplayControllerWillBeginSearch:(id)arg1{
    NSLog(@"即将打开搜索栏");
    %orig;
}
%end

%hook ContactTagListViewController
- (id)navigationBarBackgroundColor {
    BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
%end

%hook ChatRoomListViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
- (void)searchDisplayControllerWillEndSearch:(id)arg1 {
    NSLog(@"即将关闭搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] 
            && ![tmpView isKindOfClass:NSClassFromString(@"MMTableView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"MMLoadingView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:NO];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}
- (void)searchDisplayControllerDidBeginSearch:(id)arg1 {
    NSLog(@"已经打开搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")] 
            && ![tmpView isKindOfClass:NSClassFromString(@"MMTableView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"MMLoadingView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:YES];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}

- (void)searchDisplayControllerWillBeginSearch:(id)arg1{
    NSLog(@"即将打开搜索栏");
    %orig;
}
%end

%hook SayHelloViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
%end

%hook AddFriendEntryViewController
- (id)navigationBarBackgroundColor {
     BOOL kr_isTopBarImage = [[KRPlusConfig sharedConfig] kr_isTopBarImage];
    if (kr_isTopBarImage && [[KRPlusConfig sharedConfig] kr_topBarImageName].length > 0) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[KRPlusConfig sharedConfig] kr_topBarImageName]];
        return [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    } else {
        BOOL kr_isTopBarColor = [[KRPlusConfig sharedConfig] kr_isTopBarColor];
        if (kr_isTopBarColor) {
            return [UIColor colorWithHexString: [[KRPlusConfig sharedConfig] kr_topBarColor]];
        }
    }
    return %orig;
}
- (void)searchDisplayControllerWillEndSearch:(id)arg1 {
    NSLog(@"即将关闭搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UIImageView")] 
            && ![tmpView isKindOfClass:NSClassFromString(@"MMTableView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"MMUISearchBar")]
            && ![tmpView isKindOfClass:NSClassFromString(@"MMLoadingView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:NO];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}
- (void)searchDisplayControllerDidBeginSearch:(id)arg1 {
    NSLog(@"已经打开搜索栏");
    if ([self.view subviews].count > 2 ){
        for (id tmpView in [self.view subviews]) {
            NSLog(@"%@",tmpView);
            if (![tmpView isKindOfClass:NSClassFromString(@"UIImageView")] 
            && ![tmpView isKindOfClass:NSClassFromString(@"MMTableView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"MMUISearchBar")]
            && ![tmpView isKindOfClass:NSClassFromString(@"MMLoadingView")]
            && ![tmpView isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                if (((UIView *)tmpView).frame.size.height < 200) {
                    UIView *topView = (UIView *)tmpView;
                    [topView setHidden:YES];
                    NSLog(@"%@",topView);
                    break;
                }
            }
        }
    }
    %orig;
}

- (void)searchDisplayControllerWillBeginSearch:(id)arg1{
    NSLog(@"即将打开搜索栏");
    %orig;
}
%end



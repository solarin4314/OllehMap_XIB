//
//  SettingViewController2.h
//  OllehMap
//
//  Created by JiHyung on 12. 11. 15..
//
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "OllehMapStatus.h"
#import "OMMessageBox.h"
#import "VersionInfoViewController.h"
#import "ResolutionViewController.h"
#import "HelperViewController.h"
#import "NoticeListViewController.h"
#import "ServerConnector.h"
#import "RecentSearchViewController.h"
#import "FavoriteViewController.h"
#import "AccountSettingViewController.h"
#import "MyImageViewController.h"
// 고객문의/ 초불만
#import "CustomerComplainViewController.h"
#import "ImproveProposeViewController.h"
#include <sys/sysctl.h>


@interface SettingViewController2 : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    // 설정 테이블
    UITableView *_settingTableView;
    
    // 공지사항 뱃지
    NSMutableArray *_notiArr;
    UIImageView *_notiImg;
    UILabel *_notiLabel;
    
    // 나의 이미지 설정
    UISwitch *_myImgSettingSwitch;
    UITableViewCell *_myImgSettingCell;
}


#pragma mark -
#pragma mark @property
@property (nonatomic, retain) IBOutlet UITableView *settingTableView;
@property (retain, nonatomic) UIImageView *notiImg;
@property (retain, nonatomic) UILabel *notiLabel;
@property (retain, nonatomic) NSMutableArray *notiArr;
@property (retain, nonatomic) UISwitch *myImgSettingSwitch;


@end

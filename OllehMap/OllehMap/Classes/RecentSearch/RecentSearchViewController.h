//
//  RecentSearchViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 10..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "OllehMapStatus.h"
#import "OMMessageBox.h"
#import "recentCell.h"

@interface RecentSearchViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    
    // 편집모드 버튼
    UIButton *_editBtn;
    
    
    // 최근검색 테이블
    UITableView *_recentTableView;
    
    // 에디팅 뷰
    UIView *_editView;
    UILabel *_allSelectLabel;
    UILabel *_deleteLabel;
    
    // 널뷰
    UIView *_nullView;
    UILabel *_nullLbl;
    
    BOOL _check;
    
    NSMutableDictionary *_recentList;
    
}

- (IBAction)popBtnClick:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *prevBtn;

@property (retain, nonatomic) IBOutlet UIButton *editBtn;
@property (retain, nonatomic) UIView *nullView;
@property (retain, nonatomic) UILabel *nullLbl;

- (IBAction)editBtnClick:(id)sender;

@property (retain, nonatomic) IBOutlet UITableView *recentTableView;


@property (retain, nonatomic) IBOutlet UIView *editView;
@property (retain, nonatomic) IBOutlet UILabel *allSelectLabel;

@property (retain, nonatomic) IBOutlet UILabel *deleteLabel;


- (IBAction)allSelecetBtnClick:(id)sender;
- (IBAction)deleteBtnClick:(id)sender;


- (void)didFinishRequestBusNumDetail:(id)request;

@end

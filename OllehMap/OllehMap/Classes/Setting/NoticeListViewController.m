//
//  NoticeListViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 10..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "NoticeListViewController.h"

@interface NoticeListViewController ()

@end

@implementation NoticeListViewController
@synthesize scrollView = _scrollView;


- (void)dealloc
{
    [_scrollView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [self drawNoticeAllList];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSLog(@"notilistcount : %d, notilist : %@", [oms getNoticeCheckCount], [oms getNoticeCheckList]);
    
    
    
    //NSLog(@"dic : %@", dic);
    
    
    _notiArr = [oms.noticeListDictionary objectForKeyGC:@"NOTICELIST"];
    
    //NSLog(@"notiArr : %@", _notiArr);
    
    
    // notiArr 를 displayNo 키값으로 정렬
    NSSortDescriptor *temp = [[NSSortDescriptor alloc] initWithKey:@"sortDate" ascending:NO];
    NSSortDescriptor *temp2 = [[NSSortDescriptor alloc] initWithKey:@"seqNo" ascending:NO];
    
    [_notiArr sortUsingDescriptors:[NSArray arrayWithObjects:temp,temp2,nil]];
    
    [temp release];
    [temp2 release];
    
    NSLog(@"날짜순 : %@", _notiArr);
    
    //NSMutableDictionary *dic = [oms.noticeListDictionary objectForKeyGC:@"NOTICELIST"];
    
    //NSLog(@"dic : %@", dic);
    
    int ct = [_notiArr count];
    
    for (NSDictionary *dicc in _notiArr)
    {
        [dicc setValue:[NSString stringWithFormat:@"%d", ct] forKey:@"NUM"];
        ct--;
    }
    
    NSLog(@"번호붙임 : %@", _notiArr);
}

- (void) drawNoticeAllList
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int viewY = 0;
    
    for(int i=0;i<_notiArr.count;i++)
    {
        
        // 각 뷰
        UIView *listView = [[UIView alloc] init];
        [listView setFrame:CGRectMake(0, viewY, 320, 63)];
        
        // 버튼
        UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [listBtn setBackgroundImage:[UIImage imageNamed:@"notice_list_bg.png"] forState:UIControlStateNormal];
        // 이미지필요(notice_list_bg)
        [listBtn setBackgroundImage:[UIImage imageNamed:@"notice_list_bg_pressed.png"] forState:UIControlStateHighlighted];
        [listBtn addTarget:self action:@selector(noticeClick:) forControlEvents:UIControlEventTouchUpInside];
        [listBtn setFrame:CGRectMake(0, 0, 320, 63)];
        listBtn.tag = [[[_notiArr objectAtIndexGC:i] objectForKeyGC:@"seqNo"] intValue];
        
        // new check
        UIImageView *newImg = [[UIImageView alloc] init];
        
        int seq = [[[_notiArr objectAtIndexGC:i] objectForKeyGC:@"seqNo"] intValue];
        [newImg setImage:[UIImage imageNamed:@"notice_new.png"]];
        [newImg setFrame:CGRectMake(0, 0, 29, 29)];
        
        for (NSString *str in [oms getNoticeCheckList])
        {
            if([str isEqualToString:[NSString stringWithFormat:@"%d", seq]])
            {
                NSLog(@"str : %@", str);
                [newImg setHidden:YES];
                
                break;
            }
        }
        
        
        
        
        // 번호
        UILabel *seqNo = [[UILabel alloc] init];
        [seqNo setText:[NSString stringWithFormat:@"%@",[[_notiArr objectAtIndexGC:i] objectForKeyGC:@"NUM"]]];
        [seqNo setBackgroundColor:[UIColor clearColor]];
        [seqNo setTextAlignment:NSTextAlignmentCenter];
        [seqNo setFont:[UIFont boldSystemFontOfSize:22]];
        [seqNo setFrame:CGRectMake(0, 0, 58, 63)];
        
        // 날짜
        UILabel *date = [[UILabel alloc] init];
        
        NSString *dateRawStr = [[_notiArr objectAtIndexGC:i] objectForKeyGC:@"startDate"];
        
        NSArray *dateRaw = [dateRawStr componentsSeparatedByString:@" "];
        
        NSString *dayStr = [dateRaw objectAtIndexGC:0];
        
        
        [date setText:[NSString stringWithFormat:@"%@", dayStr]];
        [date setBackgroundColor:[UIColor clearColor]];
        [date setTextColor:[UIColor colorWithRed:25.0/255.0 green:168.0/255.0 blue:199.0/255.0 alpha:1]];
        [date setFont:[UIFont systemFontOfSize:13]];
        [date setFrame:CGRectMake(68, 35, 242, 13)];
        
        // 제목
        UILabel *title = [[UILabel alloc] init];
        [title setText:[NSString stringWithFormat:@"%@", [[_notiArr objectAtIndexGC:i] objectForKeyGC:@"title"]]];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setFont:[UIFont systemFontOfSize:14]];
        [title setNumberOfLines:2];
        [title setFrame:CGRectMake(68, 15, 242, 14)];
        
        CGSize titleSize = [title.text sizeWithFont:title.font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
        
        if(titleSize.width > 242)
        {
            NSLog(@"오바");
            
            // 32부터 2줄표기됨
            titleSize = [title.text sizeWithFont:title.font constrainedToSize:CGSizeMake(242, 32)];
            
            [listView setFrame:CGRectMake(0, viewY, 320, 81)];
            [listBtn setFrame:CGRectMake(0, 0, 320, 81)];
            [seqNo setFrame:CGRectMake(0, 0, 58, 81)];
            [date setFrame:CGRectMake(68, 53, 242, 13)];
            [title setFrame:CGRectMake(68, 15, 242, titleSize.height)];
            
            viewY += 81;
        }
        else
        {
            viewY += 63;
        }
        
        [listView addSubview:listBtn];
        [listView addSubview:newImg];
        [listView addSubview:seqNo];
        [listView addSubview:title];
        [listView addSubview:date];
        [_scrollView addSubview:listView];
        
        UIImageView *underLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_line.png"]];
        [underLine setFrame:CGRectMake(0, viewY, 320, 1)];
        
        [_scrollView addSubview:underLine];
        
        
        [underLine release];
        [seqNo release];
        [newImg release];
        [title release];
        [date release];
        [listView release];
        
        viewY += 1;
        
    }
    
    NSLog(@"viewY : %d", viewY);
    _scrollViewHeight = viewY;
    
    [self drawScrollView];
}
// 높이설정해야지
- (void) drawScrollView
{
    _scrollView.contentSize = CGSizeMake(320, _scrollViewHeight);
}


- (IBAction)popBtnClick:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    
    SettingViewController2 *svc = [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
    
    int notReadCount = _notiArr.count - [oms getNoticeCheckCount];
    
    if(notReadCount < 1)
    {
        [svc.notiImg setHidden:YES];
        [svc.notiLabel setHidden:YES];
    }
    else if(notReadCount < 10)
    {
        [svc.notiImg setFrame:CGRectMake(69, 14, 17, 18)];
        [svc.notiImg setImage:[UIImage imageNamed:@"setting_box_icon_01.png"]];
        [svc.notiLabel setFrame:CGRectMake(69 + 4, 14 + 3, 9, 12)];
        [svc.notiLabel setText:[NSString stringWithFormat:@"%d", notReadCount]];
    }
    else
    {
        [svc.notiImg setFrame:CGRectMake(69, 14, 23, 18)];
        [svc.notiImg setImage:[UIImage imageNamed:@"setting_box_icon_02.png"]];
        [svc.notiLabel setFrame:CGRectMake(69 + 4, 14 + 3, 15, 12)];
        [svc.notiLabel setText:[NSString stringWithFormat:@"%d", notReadCount]];
    }
    
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

// 공지상세 클릭
- (void)noticeClick:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int index = ((UIButton *)sender).tag;
    
    NSMutableArray *arrr = [oms.noticeListDictionary objectForKeyGC:@"NOTICELIST"];
    
    for(int i=0;i<[arrr count];i++)
    {
        if([[[arrr objectAtIndexGC:i] objectForKeyGC:@"seqNo"] intValue] == index)
        {
            
            [oms addNoticeCheck:index];
            /**
             @MethodDescription
             공지사항 상세
             @MethodParams
             seqNo
             @MethodMehotdReturn
             finishNoticeDetailCallBack
             */
            int sendNum = [[[_notiArr objectAtIndexGC:i] objectForKeyGC:@"NUM"] intValue];
            
            [[ServerConnector sharedServerConnection] requestNoticeDetail:self action:@selector(finishNoticeDetailCallBack:) SeqNo:index:sendNum];
            
            break;
        }
    }
    
    
    
}
- (void)finishNoticeDetailCallBack:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        NoticeDetailViewController *ndvc = [[NoticeDetailViewController alloc] initWithNibName:@"NoticeDetailViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:ndvc animated:NO];
        
        [ndvc release];
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", "")];
    }
}

@end

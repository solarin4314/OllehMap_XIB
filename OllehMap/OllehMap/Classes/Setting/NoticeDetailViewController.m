//
//  NoticeDetailViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 11..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "NoticeDetailViewController.h"

@interface NoticeDetailViewController ()

@end

@implementation NoticeDetailViewController
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [_scrollView release];
    [super dealloc];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _viewStartY = 0;
    // Do any additional setup after loading the view from its nib.
    
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //NSLog(@"%@", oms.noticeDetailDictionary);
    
    // 상단제목
    [self drawTitle];
}

- (void) drawTitle
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int viewY = 0;
    // 각 뷰
    UIView *listView = [[UIView alloc] init];
    [listView setFrame:CGRectMake(0, viewY, 320, 63)];
    
    // 뷰 배경
    UIImageView *listBg = [[UIImageView alloc] init];
    [listBg setImage:[UIImage imageNamed:@"notice_list_bg.png"]];
    //[listBg setBackgroundColor:[UIColor redColor]];
    [listBg setFrame:CGRectMake(0, 0, 320, 63)];
    
    // new check
    UIImageView *newImg = [[UIImageView alloc] init];
    [newImg setImage:[UIImage imageNamed:@"notice_new.png"]];
    [newImg setFrame:CGRectMake(0, 0, 29, 29)];
    
    // 번호
    UILabel *seqNo = [[UILabel alloc] init];
    [seqNo setText:[NSString stringWithFormat:@"%@", [oms.noticeDetailDictionary objectForKeyGC:@"SEQNUMBER"]]];
    [seqNo setBackgroundColor:[UIColor clearColor]];
    [seqNo setTextAlignment:NSTextAlignmentCenter];
    [seqNo setFont:[UIFont boldSystemFontOfSize:22]];
    [seqNo setFrame:CGRectMake(0, 0, 58, 63)];
    
    // 날짜
    UILabel *date = [[UILabel alloc] init];
    [date setText:[NSString stringWithFormat:@"%@", [[oms.noticeDetailDictionary objectForKeyGC:@"NOTICEDETAIL"] objectForKeyGC:@"startDate"]]];
    [date setTextColor:[UIColor colorWithRed:25.0/255.0 green:168.0/255.0 blue:199.0/255.0 alpha:1]];
    [date setFont:[UIFont systemFontOfSize:13]];
    [date setFrame:CGRectMake(68, 35, 242, 13)];
    
    // 제목
    UILabel *title = [[UILabel alloc] init];
    [title setText:[NSString stringWithFormat:@"%@", [[oms.noticeDetailDictionary objectForKeyGC:@"NOTICEDETAIL"] objectForKeyGC:@"title"]]];
    [title setFont:[UIFont systemFontOfSize:14]];
    [title setNumberOfLines:2];
    [title setFrame:CGRectMake(68, 15, 242, 14)];
    
    CGSize titleSize = [title.text sizeWithFont:title.font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
    
    if(titleSize.width > 242)
    {
        NSLog(@"오바");
        
        titleSize = [title.text sizeWithFont:title.font constrainedToSize:CGSizeMake(242, FLT_MAX)];
        
        [listView setFrame:CGRectMake(0, viewY, 320, 81)];
        [listBg setFrame:CGRectMake(0, 0, 320, 81)];
        [seqNo setFrame:CGRectMake(0, 0, 58, 81)];
        [date setFrame:CGRectMake(68, 53, 242, 13)];
        [title setFrame:CGRectMake(68, 15, 242, titleSize.height)];
        
        viewY += 81;
    }
    else
    {
        viewY += 63;
    }
    
    [listView addSubview:listBg];
    // 공지상세 들어오면 뱃지 필요없음
    //[listView addSubview:newImg];
    [listView addSubview:seqNo];
    [listView addSubview:title];
    [listView addSubview:date];
    [_scrollView addSubview:listView];
    
    UIImageView *underLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_line.png"]];
    [underLine setFrame:CGRectMake(0, viewY, 320, 1)];
    
    [_scrollView addSubview:underLine];
    
    viewY += 1;
    
    [underLine release];
    [listBg release];
    [seqNo release];
    [newImg release];
    [title release];
    [date release];
    [listView release];
    
    
    _viewStartY += viewY;
    
    [self drawContent];
}

- (void) drawContent
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    UIView *contentView = [[UIView alloc] init];
    
    UILabel *content = [[UILabel alloc] init];
    [content setNumberOfLines:0];
    [content setText:[NSString stringWithFormat:@"%@", [[oms.noticeDetailDictionary objectForKeyGC:@"NOTICEDETAIL"] objectForKeyGC:@"contents"]]];
    [content setFont:[UIFont systemFontOfSize:14]];
    [content setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    
    CGSize contentSize = [content.text sizeWithFont:content.font constrainedToSize:CGSizeMake(290, FLT_MAX)];
    
    int contentViewHeight = 15 + contentSize.height + 15;
    
    [content setFrame:CGRectMake(15, 15, 290, contentSize.height)];
    
    [contentView addSubview:content];
    
    [content release];
    
    [contentView setFrame:CGRectMake(0, _viewStartY, 320, contentViewHeight)];
    
    
    
    [_scrollView addSubview:contentView];
    
    [contentView release];
    
    _viewStartY += contentViewHeight;
    
    [self drawScrollView];
    
}

- (void) drawScrollView
{
    _scrollView.contentSize = CGSizeMake(320, _viewStartY);
}
- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

@end

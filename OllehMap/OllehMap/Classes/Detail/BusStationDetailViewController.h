//
//  BusStationDetailViewController.h
//  OllehMap
//
//  Created by 이제민 on 13. 4. 23..
//
//

#import <UIKit/UIKit.h>
#import "CommonPOIDetailViewController.h"
#import "BusLineInStationCell.h"

#define X_VALUE 0
#define X_WIDTH 320

@interface BusStationDetailViewController : CommonPOIDetailViewController
{
    NSInteger _viewStartY;
    
    IBOutlet UIButton *_mapBtn;
    
    IBOutlet UIView *_busStationWindow;
    UIScrollView *_bsScrollView;
    
    int scrollHeight;
}

@property (retain, nonatomic) IBOutlet UIScrollView *bsScrollView;
- (IBAction)popBtnClick:(id)sender;
- (IBAction)reFreshBtnClick:(id)sender;

- (IBAction)mapBtnClick:(id)sender;

@end

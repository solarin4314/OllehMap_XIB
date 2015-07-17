//
//  BusNumberLineViewController.h
//  OllehMap
//
//  Created by 이제민 on 13. 4. 24..
//
//

#import <UIKit/UIKit.h>
#import "CommonPOIDetailViewController.h"
#import "BusLineInStationCell.h"
#import "BusStationDetailViewController.h"

#define BusCellHeight 58

@interface BusNumberLineViewController : CommonPOIDetailViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _viewStartY;
    
    IBOutlet UIButton *_mapBtn;
    
    IBOutlet UIView *_busNumberWindow;
    
    UITableView *_busStationList;
    UIView *_busWhereView;
    
    NSIndexPath *currentNearStation;
}
@property (retain, nonatomic) IBOutlet UIView *busWhereView;

- (IBAction)popBtnClick:(id)sender;
- (IBAction)mapBtnClick:(id)sender;
- (IBAction)reFreshBtnClick:(id)sender;

@end

//
//  AddressPOIViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 25..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPOIDetailViewController.h"

@interface AddressPOIViewController : CommonPOIDetailViewController
{
    DetailScrollView *_scrollView;
    
    UIButton *_mapBtn;
    NSInteger _viewStartY;
    NSInteger _nullSizeY;
    Coord _poiCrd;
    NSString *_poiAddress;
    NSString *_poiSubAddress;
    NSString *_oldOrNew;
}


#pragma mark -
#pragma mark @property
@property (retain, nonatomic) IBOutlet DetailScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *mapBtn;
@property (nonatomic, assign) Coord poiCrd;
@property (nonatomic, retain) NSString *poiAddress;
@property (nonatomic, retain) NSString *poiSubAddress;
@property (nonatomic, retain) NSString *oldOrNew;


#pragma mark -
#pragma mark IBAction
- (IBAction)popBtnClick:(id)sender;
- (IBAction)mapBtnClick:(id)sender;

@end

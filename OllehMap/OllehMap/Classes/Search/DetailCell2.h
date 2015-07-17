//
//  DetailCell2.h
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 21..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell2 : UITableViewCell
{
    UIImageView *_poiImage;
    
    UILabel *_busNumber;
    UILabel *_busArea;
    UILabel *_startStation;
    UIImageView *_arrow;
    
    UILabel *_returnStation;
    
    UIImageView *_arrowImg;
    
}

@property (retain, nonatomic) IBOutlet UIImageView *poiImage;

@property (retain, nonatomic) IBOutlet UILabel *busNumber;
@property (retain, nonatomic) IBOutlet UILabel *busArea;
@property (retain, nonatomic) IBOutlet UILabel *startStation;
@property (retain, nonatomic) IBOutlet UIImageView *arrow;

@property (retain, nonatomic) IBOutlet UILabel *returnStation;

@property (retain, nonatomic) IBOutlet UIImageView *arrowImg;




@end

//
//  recentCell.h
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 15..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface recentCell : UITableViewCell
{
    

    
    UIImageView *_poiImage;
    UILabel *_classification;
    UILabel *_placeName;
    
    UIButton *_radioBtn;
    
    
    // 편집모드 전용 오브젝트
    UIImageView *_imgvwCheckBox;
    UIControl *_vwCellBackground;    
}


@property (retain, nonatomic) IBOutlet UIImageView *poiImage;
@property (nonatomic, retain) IBOutlet UILabel *placeName;
@property (retain, nonatomic) IBOutlet UILabel *classification;
@property (retain, nonatomic) IBOutlet UIButton *radioBtn;

// 경로일 때

@property (retain, nonatomic) IBOutlet UILabel *startLbl;
@property (retain, nonatomic) IBOutlet UILabel *destLbl;
@property (retain, nonatomic) IBOutlet UILabel *visitLbl;

@property (retain, nonatomic) IBOutlet UILabel *startContent;
@property (retain, nonatomic) IBOutlet UILabel *visitContent;
@property (retain, nonatomic) IBOutlet UILabel *destContent;

// 수정버튼
@property (retain, nonatomic) UIImageView *imgvwCheckBox;
@property (retain, nonatomic) UIControl *vwCellBackground;




@end

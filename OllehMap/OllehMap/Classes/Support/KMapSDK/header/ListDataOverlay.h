//
//  ListDataOverlay.h
//  KTMapSDK
//
//  Created by 창현 방 on 11. 11. 17..
//  Copyright 2011 네이버시스템. All rights reserved.
//
//  overlap_marker
//
//  중첩된 Marker에 balloon이 아닌 리스트를 보여주기 위한 클래스.
//  UITableView를 이용하여 리스트를 만든다.
//  리스트 데이터를 배열 형식으로 받아서 화면에 리스트형식으로 보여주고 사용자 선택시
//  해당 리스트 인덱스를 반환해 준다.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UserOverlay.h"

@interface ListDataOverlay : UserOverlay<UITableViewDelegate , UITableViewDataSource>
{
	Overlay* ownerOverlay;
    UITableView* TableView;
    UIImageView* ArrowImageView;
}

@property (nonatomic,retain) Overlay* ownerOverlay;

//초기화 세팅
- (id)initWithOwner:(Overlay*)ownerOverlay Size:(CGSize)size;

//UITableView를 세팅하기 위한 함수.
//리스트 데이터와 이미지를 받아서 리스트를 만든다.
- (void)setListData:(NSArray *)listData ImageTitle:(NSString *)title BackgroundImage:(NSString *)BackgroundImage;
@end

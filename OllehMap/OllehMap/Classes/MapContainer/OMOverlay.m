//
//  OMOverlay.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 5..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMOverlay.h"
#import "OllehMapStatus.h"
#import "ThemeCommon.h"

// 모든 POI 오버레이를 위한 커스텀 이미지 오버레이 클래스를 하나 생성한다.
@interface OMImageOverlay (Initionalizing)
// 인스턴스 생성시 각 클래스별로 별도로 처리할 작업을 정리한다.
- (void) initComponentsSub;
@end

@implementation OMPolylineOverlay
- (id) init
{
    self = [super init];
    if(self)
    {

    }
    return self;
}

@end

@implementation  OMImageOverlay
// 멤버변수에 대한 get/set 메소드 치환
@synthesize isTrafficOption = _isTrafficOption;
@synthesize duplicated = _duplicated;
@synthesize selected = _selected;
@synthesize additionalInfo = _additionalInfo;
// 생성자 메소드
- (id) init
{
    self = [super init];
    if (self)
    {
        // 공통 초기화 작업 처리
        [self initComponentsMain];
        // 개별 초기화 작업 처리
        [self initComponentsSub];
    }
    return self;
}
// 생성자 메소드, 이미지 초기화
- (id) initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self)
    {
        // 공통 초기화 작업 처리
        [self initComponentsMain];
        // 개별 초기화 작업 처리
        [self initComponentsSub];
    }
    return self;
}
// 인스턴스 생성시 공통적으로 처리할 작업을 정리한다.
- (void) initComponentsMain
{
    // 공통 초기화 작업 처리하자.
    
    // 교통옵션 여부는 기본값을 NO 처리한다.
    _isTrafficOption = NO;
    
    // 길찾기 여부 기본값  NO
    _isRouteOption = NO;
    // 중복 여부는 기본값을 NO 처리한다.
    _duplicated = NO;
    // 오버레이 선택 여부는 기본값을 NO 처리한다.
    _selected = NO;
    // 추가정보 딕셔너리 초기화한다.
    _additionalInfo = [[NSMutableDictionary alloc] init];
}
// 인스턴스 생성시 각 클래스별로 별도로 처리할 작업을 정리한다.
- (void) initComponentsSub
{
    // 각 클래스별로 호출되며 initComponentsMain 호출이후에 처리된다.
}
// 인스턴스 해제시 내부 자원 해제하도록 한다.
- (void) dealloc
{
    // 먼저 내부 자원 해제한다.
    [_additionalInfo release]; _additionalInfo = nil;
    // 상위 클래스 자원 해제하도록 유도한다.
    [super dealloc];
}
@end

// 롱탭 POI 를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlayLongtap
// 오버레이 선택시 동작할 메소드
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Selected = nil;
    if (selected) imageName_Selected = @"_pressed";
    else imageName_Selected = @"";
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker_poi%@.png", imageName_Selected];
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(self.imageSize.width/2, self.imageSize.height)];
}
@end

// 검색결과 단일 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlaySearchSingle
@synthesize usePOIIcon = _usePOIIcon;
- (void) initComponentsSub
{
    _usePOIIcon = NO;
}
// 오버레이 선택시 동작할 메소드
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Selected = nil;
    if (selected)
    {
        
        imageName_Selected = @"_pressed";
        
        for (UIImageView *marker in self.getOverlayView.subviews)
        {
            [marker setFrame:CGRectMake(marker.frame.origin.x, marker.frame.origin.y - 2, marker.frame.size.width, marker.frame.size.height)];
        }
        
    }
    else
    {
        imageName_Selected = @"";
        
        for (UIImageView *marker in self.getOverlayView.subviews)
        {
            [marker setFrame:CGRectMake(marker.frame.origin.x, marker.frame.origin.y + 2, marker.frame.size.width, marker.frame.size.height)];
        }
    }

    NSString *imageName_POI = nil;
    // POI 이미지 포함된 아이콘 사용여부
    if ( self.usePOIIcon ) imageName_POI = @"_poi";
    else imageName_POI = @"";
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker%@%@.png", imageName_POI, imageName_Selected];
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(self.imageSize.width/2, self.imageSize.height)];
}
@end

// 검색결과 다중 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlaySearchMulti
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Duplicated = nil;
    if (_duplicated) imageName_Duplicated = @"_overlap";
    else imageName_Duplicated = @"";
    NSString *imageName_Selected = nil;
    if (selected)
    {
        imageName_Selected = @"_pressed";
        
        
        NSLog(@"index : %@", [self.additionalInfo objectForKeyGC:@"Index"]);
        indexer = [[self.additionalInfo objectForKeyGC:@"Index"] intValue];
        
        
        NSLog(@"subView count : %d", self.getOverlayView.subviews.count);
        
        for (UIImageView *marker in self.getOverlayView.subviews)
        {
            [marker setFrame:CGRectMake(marker.frame.origin.x, marker.frame.origin.y - 2, marker.frame.size.width, marker.frame.size.height)];
        }
    }
    else
    {
        
        NSLog(@"index : %@", [self.additionalInfo objectForKeyGC:@"Index"]);
        
        
        NSLog(@"subView count : %d", self.getOverlayView.subviews.count);
        if([[self.additionalInfo objectForKeyGC:@"Index"] intValue] == indexer)
        {
            for (UIImageView *marker in self.getOverlayView.subviews)
            {
                [marker setFrame:CGRectMake(marker.frame.origin.x, marker.frame.origin.y + 2, marker.frame.size.width, marker.frame.size.height)];
            }
        }
        
        indexer = 11111;
        
        imageName_Selected = @"";
    }
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker%@%@.png", imageName_Duplicated, imageName_Selected];
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(self.imageSize.width/2, self.imageSize.height)];
}
@end

// 최근검색 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlayRecent
@synthesize specialNormalIconImage = _specialNormalIconImage;
@synthesize specialSelectedIconImage = _specialSelectedIconImage;
- (void) dealloc
{
    [_specialNormalIconImage release]; _specialNormalIconImage = nil;
    [_specialSelectedIconImage release]; _specialSelectedIconImage = nil;
    [super dealloc];
}
- (void) initComponentsSub
{
    [super initComponentsSub];
    _specialNormalIconImage = nil;
    _specialSelectedIconImage = nil;
}
// 오버레이 선택시 동작할 메소드
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Selected = nil;
    if (selected) imageName_Selected = @"_pressed";
    else imageName_Selected = @"";
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker_poi%@.png", imageName_Selected];
    
    // 교통옵션 관련 특별 이미지인 경우 처리
    if ( selected &&  _specialSelectedIconImage ) imageName = _specialSelectedIconImage;
    else if ( _specialNormalIconImage ) imageName = _specialNormalIconImage;
    
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(self.imageSize.width/2, self.imageSize.height)];
}
@end

// 즐겨찾기 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlayFavorite
@synthesize specialNormalIconImage = _specialNormalIconImage;
@synthesize specialSelectedIconImage = _specialSelectedIconImage;
- (void) dealloc
{
    [_specialNormalIconImage release]; _specialNormalIconImage = nil;
    [_specialSelectedIconImage release]; _specialSelectedIconImage = nil;
    [super dealloc];
}
- (void) initComponentsSub
{
    [super initComponentsSub];
    _specialNormalIconImage = nil;
    _specialSelectedIconImage = nil;
}
// 오버레이 선택시 동작할 메소드
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Selected = nil;
    if (selected) imageName_Selected = @"_pressed";
    else imageName_Selected = @"";
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker_poi%@.png", imageName_Selected];
    
    // 교통옵션 관련 특별 이미지인 경우 처리
    if ( selected &&  _specialSelectedIconImage ) imageName = _specialSelectedIconImage;
    else if ( _specialNormalIconImage ) imageName = _specialNormalIconImage;
    
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(self.imageSize.width/2, self.imageSize.height)];
}
@end
// 출바알
@implementation OMImageOverlaySearchRouteStart

-(void) initComponentsSub
{
    [super initComponentsSub];
    _isRouteOption = YES;
}
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName = [NSString stringWithFormat:@"map_marker_start.png"];
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(self.imageSize.width/2, self.imageSize.height)];
}

@end
// 경유우
@implementation OMImageOverlaySearchRouteVisit

-(void) initComponentsSub
{
    [super initComponentsSub];
    _isRouteOption = YES;
}

@end
// 도차악
@implementation OMImageOverlaySearchRouteDest

-(void) initComponentsSub
{
    [super initComponentsSub];
    _isRouteOption = YES;
}

@end
// 버스노선도 내 버스정류장 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlayBusStationInBusLIneMap
// MIK.geun :: 20120905 //  2차개발현재 아직까진 사용계획 없음
@end

// 교통옵션 CCTV POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlayTrafficCCTV
// 전용 초기화 코드를 처리한다.
- (void) initComponentsSub
{
    // 교통옵션 여부를 YES  처리한다.
    _isTrafficOption = YES;
}
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Duplicated = nil;
    if (_duplicated) imageName_Duplicated = @"_poi";
    else imageName_Duplicated = @"";
    NSString *imageName_Selected = nil;
    if (selected) imageName_Selected = @"_pressed";
    else imageName_Selected = @"";
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker%@_cctv%@.png", imageName_Duplicated, imageName_Selected];
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(poiIconImage.size.width/2, poiIconImage.size.height)];
}
@end

// 교통옵션 버스정류장 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlayTrafficBusStation
// 전용 초기화 코드를 처리한다.
- (void) initComponentsSub
{
    // 교통옵션 여부를 YES  처리한다.
    _isTrafficOption = YES;
}
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Duplicated = nil;
    if (_duplicated) imageName_Duplicated = @"_poi";
    else imageName_Duplicated = @"";
    NSString *imageName_Selected = nil;
    if (selected) imageName_Selected = @"_pressed";
    else imageName_Selected = @"";
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker%@_busstop%@.png", imageName_Duplicated, imageName_Selected];
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(poiIconImage.size.width/2, poiIconImage.size.height)];
}
@end

// 교통옵션 지하철역 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation  OMImageOverlayTrafficSubwayStation
// 전용 초기화 코드를 처리한다.
- (void) initComponentsSub
{
    // 교통옵션 여부를 YES  처리한다.
    _isTrafficOption = YES;
}
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *imageName_Duplicated = nil;
    if (_duplicated) imageName_Duplicated = @"_poi";
    else imageName_Duplicated = @"";
    NSString *imageName_Selected = nil;
    if (selected) imageName_Selected = @"_pressed";
    else imageName_Selected = @"";
    NSString *imageName = [NSString stringWithFormat:@"map_b_marker%@_subway%@.png", imageName_Duplicated, imageName_Selected];
    UIImage *poiIconImage = [UIImage imageNamed:imageName];
    [self.imageView setImage:poiIconImage];
    [self setCenterOffset:CGPointMake(poiIconImage.size.width/2, poiIconImage.size.height)];
}
@end

// 테마 POI를 처리하기위한 오버레이 클래스를 정의한다.
@implementation OMImageOverlayTheme
- (void) setSelected:(BOOL)selected
{
    // 상위 클래스 메소드 처리, 단순 _selected 값에 대입하는 역할만 있음.
    [super setSelected:selected];
    
    // 이후로 선택여부에 따라 이미지가 바뀌는 작업을 처리하도록 하자.
    NSString *mainThemeCode = stringValueOfDictionary([ThemeCommon sharedThemeCommon].additionalInfo, @"MainThemeCode");
    UIImage *themeImage = nil;
    if ( _duplicated && _selected )
        themeImage = [UIImage imageWithContentsOfFile:[ThemeCommon getThemeImageFileFullPath:mainThemeCode :ThemeImageType_Marker_Down_Nest]];
    else if ( _duplicated && !_selected )
        themeImage = [UIImage imageWithContentsOfFile:[ThemeCommon getThemeImageFileFullPath:mainThemeCode :ThemeImageType_Marker_Normal_Nest]];
    else if ( !_duplicated && _selected )
        themeImage = [UIImage imageWithContentsOfFile:[ThemeCommon getThemeImageFileFullPath:mainThemeCode :ThemeImageType_Marker_Down]];
    else if ( !_duplicated && !_selected)
        themeImage = [UIImage imageWithContentsOfFile:[ThemeCommon getThemeImageFileFullPath:mainThemeCode :ThemeImageType_Marker_Normal]];
    else
        themeImage = [UIImage imageNamed:@"map_b_marker_poi.png"];
    
    [self.imageView setImage:themeImage];
    [self setCenterOffset:CGPointMake(themeImage.size.width/2, themeImage.size.height)];
}
@end


// 커스텀 유저 유저 오버레이 클래스를 정의한다.
@interface OMUserOverlay (Initionalizing)
- (void) initComponentsSub;
@end
@implementation  OMUserOverlay
- (id) init
{
    self = [super init];
    if (self)
    {
        [self initComponentsMain];
        [self initComponentsSub];
    }
    return self;
}
- (id) initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        [self initComponentsMain];
        [self initComponentsSub];
    }
    return self;
}
- (void) initComponentsMain
{
}
- (void) initComponentsSub
{
}
@end

// POI 마커옵션 오버레이 클래스를 정의한다.
@implementation OMUserOverlayMarkerOption
- (void) initComponentsSub
{
}
@end

// POI 마커옵션 오버레이중 -타이틀- 전용오버레이 클래스를 정의한다.
@implementation OMUserOverlayMarkerOptionTitle
@synthesize additionalInfo = _additionalInfo;
- (void) initComponentsSub
{
    _additionalInfo = [[NSMutableDictionary alloc] init];
}
- (void) dealloc
{
    [_additionalInfo removeAllObjects]; [_additionalInfo release]; _additionalInfo = nil;
    
    [super dealloc];
}
@end
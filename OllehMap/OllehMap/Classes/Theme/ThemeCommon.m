//
//  ThemeCommon.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 28..
//
//

#import "ThemeCommon.h"
#import "OllehMapStatus.h"
#import "MapContainer.h"

@interface ThemeCommon (private)
@end

@implementation ThemeCommon
@synthesize additionalInfo = _additionalInfo;

- (id) init
{
    self = [super init];
    if (self)
    {
        _additionalInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void) dealloc
{
    [_additionalInfo  release]; _additionalInfo = nil;
    [super dealloc];
}

static ThemeCommon* _Instance = nil;
+ (ThemeCommon*) sharedThemeCommon
{
    if ( _Instance == nil )
    {
        _Instance = [[ThemeCommon alloc] init];
    }
    return _Instance;
}


// =========================


+ (NSString*) getThemeImageDirectory
{
    NSArray *documentsDirecotryPathArray = NSSearchPathForDirectoriesInDomains(
                                                                               NSDocumentDirectory,
                                                                               NSUserDomainMask,
                                                                               YES);
    return [NSString stringWithFormat:@"%@/Theme", [documentsDirecotryPathArray objectAtIndexGC:0] ];
}

+ (NSString*) getThemeImageFileFullPath :(NSString*)themeCode :(ThemeImageType)imageType
{
    NSString *imageTypeName = nil;
    switch (imageType)
    {
        case ThemeImageType_Marker_Down:
                        imageTypeName = @"marker_down";
            break;
        case ThemeImageType_Marker_Down_Nest:
                        imageTypeName = @"marker_down_nest";
            break;
        case ThemeImageType_Marker_Normal:
                        imageTypeName = @"marker_normal";
            break;
        case ThemeImageType_Marker_Normal_Nest:
                        imageTypeName = @"marker_normal_nest";
            break;
        case ThemeImageType_Marker_list:
                        imageTypeName = @"marker_list";
            break;
        case ThemeImageType_ICON:
        default:
            imageTypeName = @"icon";
            break;
    }
    return [NSString stringWithFormat:@"%@/%@_%@.PNG", [ThemeCommon getThemeImageDirectory], themeCode, imageTypeName];
}

+ (UIImage*) imageByThemeCode :(NSString*)themeCode;
{
    NSString *imageFilePath = [ThemeCommon getThemeImageFileFullPath:themeCode :ThemeImageType_ICON];
    return [UIImage imageWithContentsOfFile:imageFilePath];
}

+ (NSDictionary*) themeInfoByIndex :(NSInteger)index
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSDictionary *info = nil;
    
    if ( oms.themeInfoList && oms.themeInfoList.count > 0 )
    {
        info = [oms.themeInfoList objectAtIndexGC:index];
    }
    
    return info;
}


// =========================

- (void) clearThemeSearchResult
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    if ( mc.kmap.theme || self.additionalInfo.count > 0 )
    {
        // 지도에서 테마 제거
        [mc.kmap removeAllThemeOverlay];
        // 지도에서 테마사용여부 비활성화
        mc.kmap.theme = NO;
        
        // 테마정보 클리어
        [self.additionalInfo removeAllObjects];
    }
}

@end

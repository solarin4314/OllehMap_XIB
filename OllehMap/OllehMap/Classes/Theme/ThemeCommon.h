//
//  ThemeCommon.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 28..
//
//

#import <Foundation/Foundation.h>


typedef enum
{
    ThemeImageType_ICON = 0,
    ThemeImageType_Marker_Normal,
    ThemeImageType_Marker_Down,
    ThemeImageType_Marker_Normal_Nest,
    ThemeImageType_Marker_Down_Nest,
    ThemeImageType_Marker_list
} ThemeImageType;

@interface ThemeCommon : NSObject
{
    NSMutableDictionary *_additionalInfo;
}
@property (nonatomic, readonly) NSMutableDictionary *additionalInfo;

+ (ThemeCommon*) sharedThemeCommon;

// ===============================

+ (NSString*) getThemeImageDirectory;

+ (NSString*) getThemeImageFileFullPath :(NSString*)themeCode :(ThemeImageType)imageType;

+ (UIImage*) imageByThemeCode :(NSString*)themeCode;

+ (NSDictionary*) themeInfoByIndex :(NSInteger)index;

// ==============================

- (void) clearThemeSearchResult;

@end

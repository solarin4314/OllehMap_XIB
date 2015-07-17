
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <sys/time.h>

// DB 버전관리
#define _LastRecommendWordVersion 2

@interface OMDatabaseConverter : NSObject
{
}

+ (NSMutableDictionary*) makeFavoriteDictionary :(int)favoriteID sortOrder:(int)sortOrder category:(int)category title1:(NSString*)title1 title2:(NSString*)title2 title3:(NSString*)title3 iconType:(int)iconType coord1x:(double)coord1x coord1y:(double)coord1y coord2x:(double)coord2x coord2y:(double)coord2y coord3x:(double)coord3x coord3y:(double)coord3y detailType:(NSString*)detailType detailID:(NSString*)detailID shapeType:(NSString *)shapeType fcNm:(NSString *)fcNm idBgm:(NSString *)idBgm;

@end


@interface DbHelper : NSObject
{
    // 추천검색어 DB
    sqlite3 *_automakeKeywordDatabase;
    // 즐겨찾기 DB
    sqlite3 *_favoriteListDatabase;
}

// ====================
// [ 추천검색어 메소드 ]
// ====================
- (void) initAutomakeKeywordDB;
- (void) getAutomakeKeyword:(NSString *)keyword;
// ********************

// ==================
// [ 즐겨찾기 메소드 ]
// ==================
- (void) initFavoriteListDB;
- (void) getFavoriteList;
- (BOOL) favoriteValidCheck:(NSDictionary *)favoriteDic;
- (void) addFavorite :(NSDictionary*)favoriteDic;
- (void) updateFavorite :(NSMutableArray*)favoriteList;
// ******************

// ==============
// [ 보조 메소드 ]
// ==============
- (NSString *)GetUTF8String:(NSString *)hanggulString :(BOOL)onlyChosung;
- (NSString*) createEditableCopyOfDatabaseIfNeeded :(NSString*)dbfilename;
+ (void) changeNewestDatabaseFromApplicationLibrary_Recommend;
// **************
@end



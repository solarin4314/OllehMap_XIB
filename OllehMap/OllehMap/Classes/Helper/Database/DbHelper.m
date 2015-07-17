
#import "DbHelper.h"
#import "OllehMapStatus.h"
#import "OMMessageBox.h"


@implementation OMDatabaseConverter

+ (NSMutableDictionary*) makeFavoriteDictionary :(int)favoriteID sortOrder:(int)sortOrder category:(int)category title1:(NSString*)title1 title2:(NSString*)title2 title3:(NSString*)title3 iconType:(int)iconType coord1x:(double)coord1x coord1y:(double)coord1y coord2x:(double)coord2x coord2y:(double)coord2y coord3x:(double)coord3x coord3y:(double)coord3y detailType:(NSString *)detailType detailID:(NSString *)detailID shapeType:(NSString *)shapeType fcNm:(NSString *)fcNm idBgm:(NSString *)idBgm
{
    NSMutableDictionary *favoriteDic;
    @try
    {
        favoriteDic = [NSMutableDictionary dictionary];
        
        // DB 연동 변수
        [favoriteDic setObject:[NSNumber numberWithInt:favoriteID] forKey:@"FavoriteID"];
        [favoriteDic setObject:[NSNumber numberWithInt:sortOrder] forKey:@"SortOrder"];
        [favoriteDic setObject:[NSNumber numberWithInt:category] forKey:@"Category"];
        [favoriteDic setObject:title1 forKey:@"Title1"];
        [favoriteDic setObject:title2 forKey:@"Title2"];
        [favoriteDic setObject:title3 forKey:@"Title3"];
        [favoriteDic setObject:[NSNumber numberWithInt:iconType] forKey:@"IconType"];
        [favoriteDic setObject:[NSNumber numberWithDouble:coord1x] forKey:@"Coord1x"];
        [favoriteDic setObject:[NSNumber numberWithDouble:coord1y] forKey:@"Coord1y"];
        [favoriteDic setObject:[NSNumber numberWithDouble:coord2x] forKey:@"Coord2x"];
        [favoriteDic setObject:[NSNumber numberWithDouble:coord2y] forKey:@"Coord2y"];
        [favoriteDic setObject:[NSNumber numberWithDouble:coord3x] forKey:@"Coord3x"];
        [favoriteDic setObject:[NSNumber numberWithDouble:coord3y] forKey:@"Coord3y"];
        [favoriteDic setObject:detailType forKey:@"DetailType"];
        [favoriteDic setObject:detailID forKey:@"DetailID"];
        [favoriteDic setObject:shapeType forKey:@"ShapeType"];
        [favoriteDic setObject:fcNm forKey:@"FcNm"];
        [favoriteDic setObject:idBgm forKey:@"IdBgm"];
        
        // 앱내부에서만 처리되는 상태변수
        [favoriteDic setObject:[NSNumber numberWithBool:NO] forKey:@"DeleteChecked"];
        
    }
    @catch (NSException *exception)
    {
        favoriteDic = nil;
    }
    
    return favoriteDic;
}

@end



@implementation DbHelper

- (void) dealloc
{
    [super dealloc];
}

// ====================
// [ 추천검색어 메소드 ]
// ====================

- (void) initAutomakeKeywordDB
{
	//도큐먼트 위치에 db.sqlite명으로 파일패스 설정
	//NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AutomakeKeyword" ofType:@"sqlite"]; //simulator 용
    NSString *filePath = [self createEditableCopyOfDatabaseIfNeeded:@"RecommendWord.sqlite"];
	
	//데이터베이스를 연결한다.
	//해당 위치에 데이터베이스가 없을경우에는 생성해서 연결한다.
	if ( sqlite3_open([filePath UTF8String], &_automakeKeywordDatabase) != SQLITE_OK)
    {
		sqlite3_close(_automakeKeywordDatabase);
	}
	
	// 테이블 없으면, 새로 테이블 생성
	char *sql = "CREATE TABLE IF NOT EXISTS KeywordTB('kw_stIndex' CHAR, 'kw_endIndex' CHAR, 'kw_recommWord' CHAR)";
	if (sqlite3_exec(_automakeKeywordDatabase, sql, nil,nil,nil) != SQLITE_OK)
    {
		// 닫기
		sqlite3_close(_automakeKeywordDatabase);
		//NSLog(@"Error");
	}
}

- (void) getAutomakeKeyword:(NSString *)keyword
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // DB초기화
    [self initAutomakeKeywordDB];
    
    NSString *allCharacter = [self GetUTF8String:keyword :NO];
    NSString *choCharacter = [self GetUTF8String:keyword :YES];
    
    // 추천 검색어 초기화
    [oms.searchAutoMakeArray removeAllObjects];
    
#define _DATASET_1
    
#ifdef _DATASET_0
    //SELECT group_concat(RecommWord) AS RecommWordList FROM ( select  RecommWord from tb_recommword where JasoSeq like 'ã±%' order by RecommWord limit 10000 offset 0)
    NSString *query = [NSString stringWithFormat:@"SELECT group_concat(RecommWord) AS RecommWordList FROM ( select  RecommWord from TB_RecommWord where JasoSeq LIKE '%@%%' OR FirstSeq LIKE '%@%%' ORDER BY RecommWord ASC LIMIT 20 OFFSET 0)",keyword,keyword];
    
    NSLog(@"%@", query);
    
    sqlite3_stmt *selectStatement;
    
    //프리페어스테이트먼트를 사용
    if (sqlite3_prepare_v2(_automakeKeywordDatabase, [query UTF8String], -1, &selectStatement, NULL) == SQLITE_OK)
    {
        // 레코드의 데이터를 받아서 출력한다.
        while (sqlite3_step(selectStatement) == SQLITE_ROW)
        {
            char* rawRecommWordText = (char*)sqlite3_column_text(selectStatement, 0);
            if (rawRecommWordText)
            {
                NSString *tempString = [NSString stringWithUTF8String:rawRecommWordText];
                
                if (tempString.length > 0)
                    for (NSString *key in [tempString componentsSeparatedByString:@","])
                    {
                        [oms.searchAutoMakeArray addObject:key];
                    }
            }
        }
        
	}
    sqlite3_finalize(selectStatement);
#endif
    
#ifdef _DATASET_1
    
    NSString *query = nil;
    
    // 초중성 분리 안된 케이스
    if ( allCharacter.length <= 0  && choCharacter.length <= 0)
        query = [NSString stringWithFormat:@"SELECT RecommWord FROM TB_RecommWord WHERE RecommWord LIKE '%@%%' %@",keyword,@""];
    // 전체문자와 초성문자열이 같은 경우 // 초성만 검색
    else if ([allCharacter isEqualToString:choCharacter])
        query = [NSString stringWithFormat:@"SELECT RecommWord FROM TB_RecommWord WHERE FirstSeq LIKE '%@%%' %@", choCharacter,@""];
    // 전체문자와 초성문자열이 다른 경우 전체문자열만 검색
    else
        query = [NSString stringWithFormat:@"SELECT RecommWord FROM TB_RecommWord WHERE JasoSeq LIKE '%@%%' %@",allCharacter,@""];
    
    //NSLog(@"Query : %@", query);
    
    char *errMsg = NULL;
	char **results;
	int rows;
	int columns;
    
	if ( sqlite3_get_table(_automakeKeywordDatabase, [query UTF8String], &results, &rows, &columns, &errMsg) == SQLITE_OK )
    {
        [oms setRecommWord:results :rows];
    }
    else
    {
        NSLog(@"추천검색어 쿼리 오류발생 : %s", errMsg);
        [oms setRecommWord:nil :0];
    }
    
    // results 는 OMS로 넘겨서 OMS에서 릴리즈를 관리한다.
	//sqlite3_free_table (results);
#endif
    
#ifdef _DATASET_2
    NSString *query = [NSString stringWithFormat:@"SELECT RecommWord FROM TB_RecommWord WHERE JasoSeq LIKE '%@%%' OR FirstSeq LIKE '%@%%'",chokey,chokey];
    //NSLog(@"%@", query);
    
    sqlite3_stmt *selectStatement;
    
    //프리페어스테이트먼트를 사용
    if (sqlite3_prepare_v2(_automakeKeywordDatabase, [query UTF8String], -1, &selectStatement, NULL) == SQLITE_OK)
    {
        // 레코드의 데이터를 받아서 출력한다.
        while (sqlite3_step(selectStatement) == SQLITE_ROW)
        {
            char* rawRecommWordText = (char*)sqlite3_column_text(selectStatement, 0);
            if (rawRecommWordText)
            {
                NSString *refinedRecommWordText = [NSString stringWithUTF8String:rawRecommWordText];
                [oms.searchAutoMakeArray addObject:refinedRecommWordText];
            }
        }
	}
    
    sqlite3_finalize(selectStatement);
#endif
    
    
    sqlite3_close(_automakeKeywordDatabase);
    
}

// ********************


// ==================
// [ 즐겨찾기 메소드 ]
// ==================

- (void) initFavoriteListDB
{
 	//도큐먼트 위치에 db.sqlite명으로 파일패스 설정
	//NSString *filePath = [[NSBundle mainBundle] pathForResource:@"FavoriteList" ofType:@"sqlite"];
    NSString *filePath = [self createEditableCopyOfDatabaseIfNeeded:@"FavoriteList.sqlite"];
	
	//데이터베이스를 연결한다.
	//해당 위치에 데이터베이스가 없을경우에는 생성해서 연결한다.
	if (sqlite3_open([filePath UTF8String], &_favoriteListDatabase) != SQLITE_OK)
    {
		sqlite3_close(_favoriteListDatabase);
	}
	
	// 테이블 없으면, 새로 테이블 생성
    // 예전 테이블
    //char *sql = "CREATE TABLE IF NOT EXISTS FavoriteListTB (FavoriteID INTEGER PRIMARY KEY, SortOrder NUMERIC, Category NUMERIC, Title1 TEXT, Title2 TEXT, Title3 TEXT, IconType NUMERIC, Coord1x NUMERIC, Coord1y NUMERIC, Coord2x NUMERIC, Coord2y NUMERIC, Coord3x NUMERIC, Coord3y NUMERIC, DetailType TEXT, DetailID TEXT)";
    // 새로운 테이블
	char *sql = "CREATE TABLE IF NOT EXISTS FavoriteListTB (FavoriteID INTEGER PRIMARY KEY, SortOrder NUMERIC, Category NUMERIC, Title1 TEXT, Title2 TEXT, Title3 TEXT, IconType NUMERIC, Coord1x NUMERIC, Coord1y NUMERIC, Coord2x NUMERIC, Coord2y NUMERIC, Coord3x NUMERIC, Coord3y NUMERIC, DetailType TEXT, DetailID TEXT, ShapeType TEXT, FcNm TEXT, IdBgm TEXT)";
    
	if (sqlite3_exec(_favoriteListDatabase, sql, nil,nil,nil) != SQLITE_OK)
    {
		// 닫기
		sqlite3_close(_favoriteListDatabase);
	}
     
}
- (void) columnAddCheck2
{
    sqlite3_stmt *sqlStatement;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM sqlite_master where sql like('%%%@%%')", @"ShapeType"];
    if(sqlite3_prepare(_favoriteListDatabase, [sql UTF8String] , -1, &sqlStatement, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with prepare statement tableInfo %@",[NSString stringWithUTF8String:(const char *)sqlite3_errmsg(_favoriteListDatabase)]);
        
    }
    NSString *returnSQL = nil;
    while (sqlite3_step(sqlStatement)==SQLITE_ROW)
    {
        returnSQL = [NSString stringWithUTF8String:(char*)sqlite3_column_text(sqlStatement, 1)];
    }
    if(returnSQL == nil)
    {
        NSString *ShapeQuery = [NSString stringWithFormat:@"ALTER TABLE FavoriteListTB add column ShapeType text"];
        NSString *fcnmQuery = [NSString stringWithFormat:@"ALTER TABLE FavoriteListTB add column FcNm text"];
        NSString *idbgmQuery = [NSString stringWithFormat:@"ALTER TABLE FavoriteListTB add column IdBgm text"];
        
        sqlite3_exec(_favoriteListDatabase, [ShapeQuery UTF8String], nil, nil, nil);
        sqlite3_exec(_favoriteListDatabase, [fcnmQuery UTF8String], nil, nil, nil);
        sqlite3_exec(_favoriteListDatabase, [idbgmQuery UTF8String], nil, nil, nil);
        
        sqlite3_close(_favoriteListDatabase);

    }
    else
    {
    NSLog(@"있는거야");
    }

}
- (void) getFavoriteList
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 즐겨찾기 초기화
    [oms.favoriteList removeAllObjects];
    
    // DB초기화
    [self initFavoriteListDB];
    // 컬럼추가
    [self columnAddCheck2];
    NSString *query = [NSString stringWithFormat:@"SELECT FavoriteID,SortOrder,Category,Title1,Title2,Title3,IconType,Coord1x,Coord1y,Coord2x,Coord2y,Coord3x,Coord3y,DetailType,DetailID,ShapeType,FcNm,IdBgm FROM FavoriteListTB WHERE 1=1 ORDER BY CAST(SortOrder AS NUMERIC) ASC, CAST(Category AS NUMERIC) ASC"];
    //NSLog(@"%@", query);
    
    sqlite3_stmt *selectStatement;
    
    //프리페어스테이트먼트를 사용
    if (sqlite3_prepare_v2(_favoriteListDatabase, [query UTF8String], -1, &selectStatement, NULL) == SQLITE_OK)
    {
        // 레코드의 데이터를 받아서 출력한다.
        while (sqlite3_step(selectStatement) == SQLITE_ROW)
        {
            int favoriteID = (int)sqlite3_column_int(selectStatement, 0);
            int sortOrder = (int)sqlite3_column_int(selectStatement, 1);
            int category = (int)sqlite3_column_int(selectStatement, 2);
            char* title1row = (char*)sqlite3_column_text(selectStatement, 3);
            NSString *title1 = title1row ? [NSString stringWithUTF8String:title1row] : [NSString string];
            char* title2row = (char*)sqlite3_column_text(selectStatement, 4);
            NSString *title2 =title2row ? [NSString stringWithUTF8String:title2row] : [NSString string];
            char* title3row = (char*)sqlite3_column_text(selectStatement, 5);
            NSString *title3 = title3row ? [NSString stringWithUTF8String:title3row] : [NSString string];
            int iconType = (int)sqlite3_column_int(selectStatement, 6);
            double coord1x = (double)sqlite3_column_double(selectStatement, 7);
            double coord1y = (double)sqlite3_column_double(selectStatement, 8);
            double coord2x = (double)sqlite3_column_double(selectStatement, 9);
            double coord2y = (double)sqlite3_column_double(selectStatement, 10);
            double coord3x = (double)sqlite3_column_double(selectStatement, 11);
            double coord3y = (double)sqlite3_column_double(selectStatement, 12);
            char* detailTyperow = (char*)sqlite3_column_text(selectStatement, 13);
            NSString *detailType = detailTyperow ? [NSString stringWithUTF8String:detailTyperow] : [NSString string];
            char* detailIDrow = (char*)sqlite3_column_text(selectStatement, 14);
            NSString *detailID = detailIDrow ? [NSString stringWithUTF8String:detailIDrow] : [NSString string];
            
            char *shapeTyperow = (char*)sqlite3_column_text(selectStatement, 15);
            NSString *shapeType = shapeTyperow ? [NSString stringWithUTF8String:shapeTyperow] : [NSString string];
            
            char *fcNmrow = (char *)sqlite3_column_text(selectStatement, 16);
            NSString *fcNm = fcNmrow ? [NSString stringWithUTF8String:fcNmrow] : [NSString string];
            
            char *idBgmrow = (char *)sqlite3_column_text(selectStatement, 17);
            NSString *idBgm = idBgmrow ? [NSString stringWithUTF8String:idBgmrow] : [NSString string];
            
            
            // 즐겨찾기 정보 생성
            NSMutableDictionary *fDic = [OMDatabaseConverter makeFavoriteDictionary:favoriteID sortOrder:sortOrder category:category title1:title1 title2:title2 title3:title3 iconType:iconType coord1x:coord1x coord1y:coord1y coord2x:coord2x coord2y:coord2y coord3x:coord3x coord3y:coord3y detailType:detailType detailID:detailID shapeType:shapeType fcNm:fcNm idBgm:idBgm];
            
            if (fDic) [oms.favoriteList addObject:fDic];
        }
	}
    
    sqlite3_close(_favoriteListDatabase);
    sqlite3_finalize(selectStatement);
}
- (BOOL) favoriteValidCheck:(NSDictionary *)favoriteDic
{
    // 즐겨찾기 목록이 메모리에 없을 경우 불러오기
    if ( [OllehMapStatus sharedOllehMapStatus].favoriteList.count <= 0 ) [self getFavoriteList];
    NSLog(@"즐겨찾기 카운트 : %d", [OllehMapStatus sharedOllehMapStatus].favoriteList.count);
    
    // 추가하려는 즐겨찾기 정보가 비정상일 경우 오류 처리
    if ( !favoriteDic )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Search_Favorite_AddFailed_DataError", @"")];
        return false;
    }
    
    // 기존 즐겨찾기 목록에 동일한 좌표가 존재하는지 체크
    for (NSDictionary *dic in [OllehMapStatus sharedOllehMapStatus].favoriteList)
    {
        // 길찾기 카테고리는 경로좌표로 비교
        if ( [[favoriteDic objectForKeyGC:@"Category"] intValue] == 2 ) // Favorite_Category_Route = 2
        {
            int coord1x = [[favoriteDic objectForKeyGC:@"Coord1x"] doubleValue];
            int coord1y = [[favoriteDic objectForKeyGC:@"Coord1y"] doubleValue];
            int coord2x = [[favoriteDic objectForKeyGC:@"Coord2x"] doubleValue];
            int coord2y = [[favoriteDic objectForKeyGC:@"Coord2y"] doubleValue];
            int coord3x = [[favoriteDic objectForKeyGC:@"Coord3x"] doubleValue];
            int coord3y = [[favoriteDic objectForKeyGC:@"Coord3y"] doubleValue];
            
            int precoord1x = [[dic objectForKeyGC:@"Coord1x"] doubleValue];
            int precoord1y = [[dic objectForKeyGC:@"Coord1y"] doubleValue];
            int precoord2x = [[dic objectForKeyGC:@"Coord2x"] doubleValue];
            int precoord2y = [[dic objectForKeyGC:@"Coord2y"] doubleValue];
            int precoord3x = [[dic objectForKeyGC:@"Coord3x"] doubleValue];
            int precoord3y = [[dic objectForKeyGC:@"Coord3y"] doubleValue];
            
            
            if ( coord1x == precoord1x && coord1y == precoord1y
                && coord2x == precoord2x && coord2y == precoord2y
                && coord3x == precoord3x && coord3y == precoord3y)
            {
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Search_Favorite_AddFailed_ExistsItem", @"")];
                return false;
            }
            
        }
        // 주소의 경우 좌표로 비교
        else  if ( [[favoriteDic objectForKeyGC:@"Category"] intValue] == 1  // Favorite_Category_Local = 1
                  && [[favoriteDic objectForKeyGC:@"DetailType"] isEqualToString:@"ADDR"] )
        {
            int coord1x = [[favoriteDic objectForKeyGC:@"Coord1x"] doubleValue];
            int coord1y = [[favoriteDic objectForKeyGC:@"Coord1y"] doubleValue];
            int precoord1x = [[dic objectForKeyGC:@"Coord1x"] doubleValue];
            int precoord1y = [[dic objectForKeyGC:@"Coord1y"] doubleValue];
            if ( coord1x == precoord1x && coord1y == precoord1y )
            {
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Search_Favorite_AddFailed_ExistsItem", @"")];
                return false;
            }
            
        }
        // 그외 정보는 Type-ID 로 비교
        else
        {
            //NSLog(@"%@ %@ %@ %@",[favoriteDic objectForKeyGC:@"DetailType"] , [favoriteDic objectForKeyGC:@"DetailID"], [dic objectForKeyGC:@"DetailType"], [dic objectForKeyGC:@"DetailID"]  );
            if ( [[favoriteDic objectForKeyGC:@"DetailType"] isEqualToString:[dic objectForKeyGC:@"DetailType"]]
                && [[favoriteDic objectForKeyGC:@"DetailID"] isEqualToString:[dic objectForKeyGC:@"DetailID"]] )
            {
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Search_Favorite_AddFailed_ExistsItem", @"")];
                return false;
            }
        }
    }
    return true;
    
}
- (void) addFavorite :(NSDictionary*)favoriteDic
{
    
    [self initFavoriteListDB];
    
    // SELECT max(SortOrder) FROM FavoriteListTB
    // INSERT INTO FavoriteListTB (FavoriteID,SortOrder,Category,Title1,Title2,Title3,IconType,Coord1x,Coord1y,Coord2x,Coord2y,Coord3x,Coord3y)  VALUES(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    
    int category = [[favoriteDic objectForKeyGC:@"Category"] intValue];
    NSString *title1 = nil;
    if ( [[favoriteDic allKeys] containsObject:@"Title1"] )
        title1 = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"Title1"]];
    else title1 = @"";
    NSString *title2 = nil;
    if ( [[favoriteDic allKeys] containsObject:@"Title2"] )
        title2 = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"Title2"]];
    else title2 = @"";
    NSString *title3 = nil;
    if ( [[favoriteDic allKeys] containsObject:@"Title3"] )
        title3 = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"Title3"]];
    else title3 = @"";
    int iconType = [[favoriteDic objectForKeyGC:@"IconType"] intValue];
    double coord1x = [[favoriteDic objectForKeyGC:@"Coord1x"] doubleValue];
    double coord1y = [[favoriteDic objectForKeyGC:@"Coord1y"] doubleValue];
    double coord2x = [[favoriteDic objectForKeyGC:@"Coord2x"] doubleValue];
    double coord2y = [[favoriteDic objectForKeyGC:@"Coord2y"] doubleValue];
    double coord3x = [[favoriteDic objectForKeyGC:@"Coord3x"] doubleValue];
    double coord3y = [[favoriteDic objectForKeyGC:@"Coord3y"] doubleValue];
    NSString *detailType = nil;
    if ( [[favoriteDic allKeys] containsObject:@"DetailType"] )
        detailType = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"DetailType"]];
    else detailType = @"";
    NSString *detailID = nil;
    if ( [[favoriteDic allKeys] containsObject:@"DetailID"] )
        detailID = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"DetailID"]];
    else detailID = @"";
    
    NSString *shapeType = nil;
    if( [[favoriteDic allKeys] containsObject:@"ShapeType"])
        shapeType = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"ShapeType"]];
    else
        shapeType = @"";
    
    NSString *fcNm = nil;
    if( [[favoriteDic allKeys] containsObject:@"FcNm"])
        fcNm = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"FcNm"]];
    else
        fcNm = @"";
    
    NSString *idBgm = nil;
    if( [[favoriteDic allKeys] containsObject:@"IdBgm"])
        idBgm = [NSString stringWithFormat:@"%@", [favoriteDic objectForKeyGC:@"IdBgm"]];
    else
        idBgm = @"";
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO FavoriteListTB (FavoriteID,SortOrder,Category,Title1,Title2,Title3,IconType,Coord1x,Coord1y,Coord2x,Coord2y,Coord3x,Coord3y,DetailType,DetailID,ShapeType,FcNm, IdBgm)  VALUES(NULL, %@, %d, '%@', '%@', '%@', %d, %f, %f, %f, %f, %f, %f, '%@', '%@', '%@', '%@', '%@');"
                       //, @"(SELECT MAX( CAST(SortOrder AS NUMERIC) ) FROM FavoriteListTB) + 1" //SortOrder
                       , @"0"
                       , category
                       , title1, title2, title3
                       , iconType
                       , coord1x, coord1y
                       , coord2x, coord2y
                       , coord3x, coord3y
                       , detailType, detailID, shapeType, fcNm, idBgm
                       ];
    //NSLog(@"DB 즐겨찾기 입력 : %@", query);
    
    if ( sqlite3_exec(_favoriteListDatabase, [query UTF8String], nil,nil,nil) == SQLITE_OK)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Search_Favorite_AddSuccess", @"")];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Search_Favorite_AddFailed_DataError",@"")];
    }
    
    sqlite3_close(_favoriteListDatabase);
    
    // 즐겨찾기 추가 이후 데이터 새로고침
    [self getFavoriteList];
    // 정렬순서 재조정
    [self updateFavorite:[OllehMapStatus sharedOllehMapStatus].favoriteList];
}

- (void) updateFavorite :(NSMutableArray*)favoriteList
{
    [self initFavoriteListDB];
    
    NSMutableString *queryForNoDeleteItems = [NSMutableString stringWithString:@""];
    
    int newSortOrder = 0;
    for (NSMutableDictionary *favoriteDic in favoriteList)
    {
        NSString *favoriteTitle1 = [favoriteDic objectForKeyGC:@"Title1"];
        int favoriteID = [[favoriteDic objectForKeyGC:@"FavoriteID"] intValue];
        
        // 살아남은 아이템 목록 처리 (삭제아이템 처리할 때 사용)
        if ( queryForNoDeleteItems.length > 0) [queryForNoDeleteItems appendString:@","];
        [queryForNoDeleteItems appendFormat:@"%d", favoriteID];
        
        // 살아남은 아이템 정렬 순서 업데이트
        NSString* queryUpdate = [NSString stringWithFormat:@"UPDATE FavoriteListTB SET SortOrder=%d WHERE FavoriteID = %d; ", ++newSortOrder, favoriteID];
        //NSLog(@"DB 즐겨찾기 정렬순서 업데이트 : %@@", queryUpdate);
        
        // 이름변경
        NSString *queryRename = [NSString stringWithFormat:@"UPDATE FavoriteListTB SET Title1 = '%@' WHERE FavoriteID = %d;", favoriteTitle1, favoriteID];
        
        sqlite3_exec(_favoriteListDatabase, [queryUpdate UTF8String], nil,nil,nil);
        sqlite3_exec(_favoriteListDatabase, [queryRename UTF8String], nil,nil,nil);
        
    }
    
    // 즐겨찾기 삭제 쿼리
    NSString *queryDelete = [NSString stringWithFormat:@"DELETE FROM FavoriteListTB WHERE FavoriteID NOT IN (%@); ", queryForNoDeleteItems];
    //NSLog(@"DB 즐겨찾기 삭제 : %@@", queryDelete);
    sqlite3_exec(_favoriteListDatabase, [queryDelete UTF8String], nil,nil,nil);
    
    
    
    // DB 닫기
    sqlite3_close(_favoriteListDatabase);
}

// ******************


// ==============
// [ 보조 메소드 ]
// ==============

- (NSString *)GetUTF8String:(NSString *)hanggulString :(BOOL)onlyChosung
{
	NSArray *chosung = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
	NSArray *jungsung = [[NSArray alloc] initWithObjects:@"ㅏ",@"ㅐ",@"ㅑ",@"ㅒ",@"ㅓ",@"ㅔ",@"ㅕ",@"ㅖ",@"ㅗ",@"ㅘ",@"ㅙ",@"ㅚ",@"ㅛ",@"ㅜ",@"ㅝ",@"ㅞ",@"ㅟ",@"ㅠ",@"ㅡ",@"ㅢ",@"ㅣ",nil];
	NSArray *jongsung = [[NSArray alloc] initWithObjects:@"",@"ㄱ",@"ㄲ",@"ㄳ",@"ㄴ",@"ㄵ",@"ㄶ",@"ㄷ",@"ㄹ",@"ㄺ",@"ㄻ",@"ㄼ",@"ㄽ",@"ㄾ",@"ㄿ",@"ㅀ",@"ㅁ",@"ㅂ",@"ㅄ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@" ㅌ",@"ㅍ",@"ㅎ",nil];
    
    NSMutableString *textResult = [NSMutableString string];
	for (int i=0, maxi=[hanggulString length] ;i < maxi;i++)
    {
        // 유니 코드를 사용하여 맞는 글자를 찾는다.
		NSInteger code = [hanggulString characterAtIndex:i];
		if (code >= 44032 && code <= 55203)
        {
			NSInteger uniCode = code - 44032;
			NSInteger chosungIndex = uniCode / 21 / 28;
			NSInteger jungsungIndex = uniCode % (21 * 28) / 28;
			NSInteger jongsungIndex = uniCode % 28;
            
            if (onlyChosung)
                [textResult appendString:[chosung objectAtIndexGC:chosungIndex]];
            else
                [textResult appendFormat:@"%@%@%@", [chosung objectAtIndexGC:chosungIndex], [jungsung objectAtIndexGC:jungsungIndex], [jongsung objectAtIndexGC:jongsungIndex]];
		}
        else //if (i==maxi-1)
        {
            NSRange range;
            range.location = i;
            range.length = 1;
            [textResult appendString:[hanggulString substringWithRange:range]];
        }
        
    }
    
    [chosung release];
    [jungsung release];
    [jongsung release];
    
	return [textResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString*) createEditableCopyOfDatabaseIfNeeded :(NSString*)dbfilename
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndexGC:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbfilename];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (!success)
    {
        // The writable database does not exist, so copy the default to the appropriate location.
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbfilename];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        
        if (success)
        {
        }
        else
        {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            return nil;
        }
    }
    return writableDBPath;
}

+ (void) changeNewestDatabaseFromApplicationLibrary_Recommend
{
    // ==============================================
    // [ DB 파일이 Documents 폴더내에 존재하는지 체크 ]
    // ==============================================
    
    NSError *error;
    
    // iOS 기본 파일 매니저
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Document 디렉토리 경로 가져오기
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndexGC:0];
    NSString *dbfilename = @"RecommendWord.sqlite";
    
    // Documents에 해당 DB파일 존재하는지 확인
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbfilename];
    BOOL exists = [fileManager fileExistsAtPath:writableDBPath];
    
    // Document  폴더에 해당DB 가 존재하면서 최신(App)버전일 경우...
    if (exists && [[[NSUserDefaults standardUserDefaults] objectForKeyGC:@"RecommendWordDataVersion"] intValue] >= _LastRecommendWordVersion )
    {
        // p~~~ass
    }
    // 해당 DB 가 존재는 하지만 최신버전이 아닌경우..
    else if ( exists )
    {
        // 기존버전 삭제
        [fileManager removeItemAtPath:writableDBPath error:&error];
        // 신규버전 카피
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbfilename];
        [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        // 새버전 기록
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_LastRecommendWordVersion] forKey:@"RecommendWordDataVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // 존재조차 하지 않는 경우...
    else
    {
        // 신규버전 카피
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbfilename];
        [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        // 새버전 기록
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_LastRecommendWordVersion] forKey:@"RecommendWordDataVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }    
    
}


// **************

@end




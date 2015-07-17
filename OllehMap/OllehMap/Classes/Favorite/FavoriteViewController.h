//
//  FavoriteViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 24..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OMNavigationController.h"
#import "OMMessageBox.h"
#import "SearchRouteExecuter.h"

typedef enum
{
    Favorite_Category_All = 0
    ,Favorite_Category_Local = 1
    ,Favorite_Category_Route = 2
    ,Favorite_Category_Public = 3
} Favorite_Category;

typedef enum
{
    Favorite_IconType_None = 10000
    ,Favorite_IconType_BusStop = 10001
    ,Favorite_IconType_CCTV = 10002
    ,Favorite_IconType_Course = 10003
    ,Favorite_IconType_POI = 10004
    ,Favorite_IconType_Subway = 10005
    
} Favorite_IconType;

UIImage* getFavoritImage(int iconType);

@interface FavoriteCell : UITableViewCell
{
    id _refreshDeleteButtonTarget;
    SEL _refreshDeleteButtonAction;
    
    UIControl *_vwCustomCell;
    UIView *_vwCustomCellBackground;
    UIButton *_btnCheck;
    
    NSMutableDictionary *_currentFavoriteDictionary;
}

- (BOOL) setFavoriteDictionary :(NSMutableDictionary*)favoriteDic;
- (NSMutableDictionary*) getFavoriteDictionary;
- (void) addTargetActionRefreshDeleteButton :(id)target :(SEL)action;
- (void) onCheck :(id)sender;
- (void) onCheckCell :(id)sender;
- (void) renderInCell :(BOOL)isEdting;

@end

@interface FavoriteViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate>
{
    UIView *_vwNavigation;
    
    Favorite_Category _favoriteCategory;
    UIView *_vwFavoriteContainer;
    
    UITableView *_tvwFavoriteList;
    
    UIButton *_btnSelectAllFavorite;
    UIButton *_btnDeleteSelectedFavorite;
    UIButton *_btnRenameFavorite;
    
    UILabel *_lblSelectAllFavorite;
    UILabel *_lblSelectAllFavoriteShadow;
    
    UILabel *_lblDeleteSelectedFavorite;
    UILabel *_lblDeleteSelectedFavoriteShadow;
    
    UILabel *_lblRenameFavorite;
    UILabel *_lblRenameFovoriteShadow;
    
    NSMutableArray *_favoriteLocalList;
    NSMutableArray *_favoriteRouteList;
    NSMutableArray *_favoritePublicList;
    
    UITextField *_renameTextField;
}

// ================
// [ 초기화 메소드 ]
// ================
- (void) initComponents;
- (void) initFavorteListOnMemory :(BOOL)fromDB;
- (NSMutableArray*) getCurrentCategoryFavoriteLIst;
// ****************

// ================
// [ 렌더링 메소드 ]
// ================
- (void) renderNavigation;
- (void) renderCategory :(Favorite_Category)category;
- (void) renderCategoryTable;
- (void) renderBottomDeletController;
// ****************

// ==================
// [ 테이블뷰 메소드 ]
// ==================
// ******************

// ==============
// [ 액션 메소드 ]
// ==============
- (void) onPrev :(id)sender;
- (void) onModify :(id)sender;
- (void) onCategoryAll :(id)sender;
- (void) onCategoryLocal :(id)sender;
- (void) onCategoryRoute :(id)sender;
- (void) onCategoryPublic :(id)sender;
- (void) onSeletAll :(id)sender;
- (void) onDeleteSelectedFavorite :(id)sender;
- (void) onRefreshDeleteButtonText :(id)sender;
// **************


// ===================
// [ 검색 콜백 메소드 ]
// ===================
- (void) didFinishRequestBusNumberDetail :(id)request;
// *******************

@end

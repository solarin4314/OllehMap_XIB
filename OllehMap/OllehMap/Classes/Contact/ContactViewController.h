//
//  ContactViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 24..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// 주소록 프레임웍 헤더파일
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "OMNavigationController.h"
#import "OMMessageBox.h"
#import "OMCustomView.h"

#import "OMPeoplePickerNavigationController.h"


@interface OMControlContact : UIControl
{
    NSString *_name;
    NSArray *_addresses;
    BOOL _isAddress;
    BOOL _isNewAddress;
}
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSArray *addresses;
@property (nonatomic, assign) BOOL isAddress;
@property (nonatomic, assign) BOOL isNewAddress;
@end

@interface ContactViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UIScrollViewDelegate>
{
    OMPeoplePickerNavigationController *_peoplePicker;
    
    UIView *_vwMultiAddressSelector;
}

+ (BOOL) checkAddressBookAuth;
+ (BOOL) checkAddressBookAuthWithoutMessage;

@end

//
//  UIViewController+Is4Inch.m
//  iPhone 5: 4 inch category
//
//  Created by Choi Joong Kwan on 2012. 09. 12.
//  Copyright (c) tiny2n@naver.com. All rights reserved.
//

#import <objc/runtime.h>
#import "uiviewcontroller+is4inch.h"

@implementation UIViewController (Is4Inch)

/**
 아이폰5 : 4인치에 대응해서 만든 뷰컨트롤러 Xib 생성 메소드
 initWith4InchNibName:bundle:
 @param     nibNameOrNil    : Xib 네임 or nil
 @param     nibBundleOrNil  : 번들네임 or nil
 @return    생성된 UIViewController
 */
- (id)initWith4InchNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString * newNibNameOrNil = [nibNameOrNil stringByAppendingString:@"~568h"];

    // 4 인치에 대응하는지 검사
    // 아이폰5: 4 인치용 Xib로 초기화: ~568h 삽입
    if ((IS_4_INCH) && ([[NSBundle mainBundle] pathForResource:newNibNameOrNil ofType:@"nib"]))
    {
        // 4인치용 Xib가 존재하는지 검사
        // Xib가 컴파일 되면 nib가 되므로 nib로 검사
        return [self performSelector:@selector(initWithLegacyNibName:bundle:) withObject:newNibNameOrNil withObject:nibBundleOrNil];
    }
    else
    {
        return [self performSelector:@selector(initWithLegacyNibName:bundle:) withObject:nibNameOrNil    withObject:nibBundleOrNil];
    }
}

/**
 프로젝트가 실행되면 load는 자동으로 실행됨.
 즉, 사용하고 싶은 곳에서 선언해서 사용하는 것이 아닌 선언없이도 전반적으로 교체되어 사용. (해더가 필요없는 2번째 이유)
 해당 메소드는 카테고리에 선언했다고 하더라도 해당 클래스 'load'메소드도 별도로 호출됨 '+(void)initialize' 메소드는 오버라이드 됨.
 */
+ (void)load
{  
    // 'initWithNibName:bundle:' 메소드를 'initWithLegacyNibName:bundle:' 메소드라는 이름으로 생성해서 추가함.
    // 추가기 때문에 'initWithNibName:bundle:' 메소드, 'initWithLegacyNibName:bundle:' 메소드 두 이름으로 동일한 기능.
    class_addMethod([self class], @selector(initWithLegacyNibName:bundle:), [self instanceMethodForSelector:@selector(initWithNibName:bundle:)], "v@:@@");  
    
    // 'initWith4InchNibName:bundle:' 메소드를 'initWithNibName:bundle:' 로 교체
    Method new = class_getInstanceMethod(self, @selector(initWith4InchNibName:bundle:));
    class_replaceMethod([self class], @selector(initWithNibName:bundle:), method_getImplementation(new), "v@:@@");
} 

@end

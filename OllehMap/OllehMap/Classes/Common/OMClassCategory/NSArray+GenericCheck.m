//
//  NSArray+GenericCheck.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 11. 16..
//
//

#import "NSArray+GenericCheck.h"
#if DEBUG
#import "OMMessageBox.h"
#endif

@implementation NSArray (GenericCheck)
- (id) objectAtIndexGC:(NSUInteger)index
{
    id object = nil;
    if ( self.count-1 >= index) object = [self objectAtIndex:index];
#if DEBUG
    // DEBUG 적용 // 인덱스 이상현상시 오류 리턴
    else
    {
        [OMMessageBox showAlertMessage:@"DEBUG" :@"objectAtIndexGC 메세지를 통해 입력받은 인덱스 값이 현재 객체의 Count 수보다 큰값입니다.\nnil을 리턴합니다."];
    }
#endif
    if ( object && [object isKindOfClass:[NSNull class]] )
    {
        object = nil;
    }
    return object;
}
@end
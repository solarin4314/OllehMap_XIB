/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file NetDataFindRoad.m
 @class NetDataFindRoad
 @brief 길찾기 검색 결과 데이터 파싱 클래스 
 */ 

#import "NetDataFindRoad.h"

@implementation NetDataFindRoad

@synthesize themeID;
@synthesize page;
@synthesize sortType;

@synthesize isError;
@synthesize isSearchPublic;



// 초기화 함수
- (id) init 
{    
    self = [super init];
	if(self != nil)
    {
        // init
		_xmlValue = [[NSMutableString alloc] init];
		_netResult = [[CommonGW alloc] init];
		isRecommend = NO;
		isBus = NO;
		isSubway = NO;
		isBoth = NO;
		
		tmp_RouteSearch = [[RouteSearch alloc] init];
	}
	return self;
}


+ (id) parser
{
	return [[[[self class] alloc] init] autorelease];
}



/**
 @brief 데이터 파싱
 @param aBodyData 파싱할 데이터
 @return 파싱한 데이터(CommonGW)
 */
- (id) parserData:(NSData *)aBodyData
{	
	NSString * buffer= [[NSString alloc] initWithData:aBodyData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];

	NSData* convertData = [buffer dataUsingEncoding:NSUTF8StringEncoding];
	
    if(buffer == nil || ([buffer length] > 5 && [[buffer substringWithRange:NSMakeRange(1, 4)] isEqualToString:@"html"]))
    {
		_netResult.isError = YES;
	}
    else
    {
		_netResult.isError = NO;
        _netResult.RPTYPE = isSearchPublic;
        
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:convertData];
		[parser setDelegate:self];
		[parser parse];
		[parser release];
	}

    [buffer release];
	return _netResult;
}


- (void) dealloc {
	[_xmlValue release];
	[super dealloc];
}



#pragma mark - NSXMLParser 메소드 -
// 엘리먼트 파싱 시작될 때 호출
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
    
	if([elementName isEqualToString:@"Response"] && [attributeDict count] > 0)
    {
		if([[NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"isRoute"]] isEqualToString:@"false"])
        {
			_netResult.isError = YES;
			[_xmlValue setString:@""];
		}
	}
    // 대중교통 일 경우
	else if(isSearchPublic)
    {
		if([elementName isEqualToString:@"BUS"] && [attributeDict count] > 0)
        {
			isBus = YES;
			for(id Keys in attributeDict)
			{				
				NSLog(@"버스 Object :%@ Keys:%@",[attributeDict objectForKeyGC:Keys],Keys);
			}			
		}
		else if([elementName isEqualToString:@"SUBWAY"] && [attributeDict count] > 0)
        {
			isSubway = YES;
			for(id Keys in attributeDict)
			{				
				NSLog(@"지하철 Object :%@ Keys:%@",[attributeDict objectForKeyGC:Keys],Keys);
			}		
		}
        else if([elementName isEqualToString:@"BOTH"] && [attributeDict count] > 0)
        {
			isBoth = YES;
			for(id Keys in attributeDict)
			{				
				NSLog(@"보스 Object :%@ Keys:%@",[attributeDict objectForKeyGC:Keys],Keys);
			}						
		}
        else if([elementName isEqualToString:@"RECOMMEND"] && [attributeDict count] > 0)
        {
			isRecommend = YES;
			for(id Keys in attributeDict)
			{				
				NSLog(@"추천 Object :%@ Keys:%@",[attributeDict objectForKeyGC:Keys],Keys);
			}									
		}
		else
        {	
            if([elementName isEqualToString:@"VERTEX"] && [attributeDict count] > 0)
            {
                    RouteSearchCoordItems* item = [[RouteSearchCoordItems alloc] init];
                    item._vertexX = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"x"]];
                    item._vertexY = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"y"]];
                    [tmp_RouteSearch._RouteSearchCoordArray addObject:item];				
                    [item release];
            }
            else if([elementName isEqualToString:@"NODE"] && [attributeDict count] > 0)
            {                 
                    RouteSearchBusStationItems* item = [[RouteSearchBusStationItems alloc] init];
                    item._name = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"name"]];
                    item._stationtype = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"stationtype"]];
                    item._x = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"x"]];
                    item._y = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"y"]];				
                    [tmp_RouteSearch._RouteSearchBusStationArray addObject:item];
                    [item release];			 
            }
            else if([elementName isEqualToString:@"RG"] && [attributeDict count] > 0)
            {
                    RouteSearchBusRGItems* item = [[RouteSearchBusRGItems alloc] init];
                    item._distance = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"distance"]];
                    item._distancetype = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"distancetype"]];
                    item._endname = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"endname"]];
                    item._lanename = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"lanename"]];
                    item._methodtype = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"methodtype"]];
                    item._rgtype = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"rgtype"]];
                    item._startname = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"startname"]];
                    item._x = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"x"]];
                    item._y = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"y"]];				
                    [tmp_RouteSearch._RouteSearchBusRGArray addObject:item];
                    [item release];
            }
            else if([elementName isEqualToString:@"ROUTE"] && [attributeDict count] > 0)
            {			 
                    tmp_RouteSearch._rg_count = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"rgcount"]];
                    tmp_RouteSearch._total_dist = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"totaldistance"]];
                    tmp_RouteSearch._total_time = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"totaltime"]];
                    tmp_RouteSearch._total_charge = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"charge"]];				
            }		
        }	
    }
	//자동차 길찾기일 경우
	else
    {
        //NSLog(@"길찾기 XML파싱 - 자동차 -");
        
		if([elementName isEqualToString:@"vertex"] && [attributeDict count] > 0)
        {
			RouteSearchCoordItems* item = [[RouteSearchCoordItems alloc] init];
			item._vertexX = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"x"]];
			item._vertexY = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"y"]];			
			[_netResult._routeSearch._RouteSearchCoordArray addObject:item];
			[item release];
		}
        else if([elementName isEqualToString:@"ROUTE"] && [attributeDict count] > 0)
        {
			tmp_RouteSearch._rg_count = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"rg_count"]];
			tmp_RouteSearch._total_dist = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"total_dist"]];
			tmp_RouteSearch._total_time = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"total_time"]];
			tmp_RouteSearch._total_charge = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"charge"]];
			_netResult._routeSearch._total_dist = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"total_dist"]];
			_netResult._routeSearch._total_time = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"total_time"]];
			_netResult._routeSearch._total_charge = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"charge"]];			
		}
        else if([elementName isEqualToString:@"rg"] && [attributeDict count] > 0)
        {
			RouteSearchDirItems* item = [[RouteSearchDirItems alloc] init];
			item._dir_name = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"dir_name"]];
			item._link_idx = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"link_idx"]];
			item._nextdist = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"nextdist"]];
			item._node_name = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"node_name"]];
			item._type = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"type"]];			
			item._x = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"x"]];
			item._y = [NSString stringWithFormat:@"%@", [attributeDict objectForKeyGC:@"y"]];
			[_netResult._routeSearch._RouteSearchDirArray addObject:item];
			[item release];
		}
	}
}

// value의 문자값을 만날 때 호출, 문자가 xmlValue에 하나씩 추가함
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
	[_xmlValue appendString:string];
}

// value 값 파싱이 끝나면 호출됨
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if([elementName isEqualToString:@"Response"] && _netResult.isError)
    {
		//_netResult._ERRCODE = [[NSString alloc] initWithString:@"999"];
        _netResult._ERRCODE = [NSString stringWithFormat:@"999"];
		//_netResult._ERRMSG = [[NSString alloc] initWithString:_xmlValue];
        _netResult._ERRMSG = [NSString stringWithFormat:@"%@", _xmlValue];
		_netResult.isError = NO;
	}
    // 대중교통일 경우
    else if(isSearchPublic)
    {
		if([elementName isEqualToString:@"BUS"])
        {
			isBus = NO;
		}
        else if([elementName isEqualToString:@"SUBWAY"])
        {
			isSubway = NO;
		}
        else if([elementName isEqualToString:@"BOTH"])
        {
			isBoth = NO;
		}
        else if([elementName isEqualToString:@"RECOMMEND"])
        {
			isRecommend = NO;
		}
        else if([elementName isEqualToString:@"RESULT"])
        {
			if(isBus) 
            {
				[_netResult._rspTotalArrayList._BusArray  addObject:tmp_RouteSearch];
				//int Cnt = [_netResult._rspTotalArrayList._BusArray  count];
				//LOG_TRACE (@"버스리절트= %d",Cnt);
			}
			else if(isSubway) 
            {
				[_netResult._rspTotalArrayList._SubwayArray  addObject:tmp_RouteSearch];
				//int Cnt = [_netResult._rspTotalArrayList._SubwayArray  count];
				//LOG_TRACE (@"지하철리절트= %d",Cnt);
			}
			else if(isBoth) 
            {
				[_netResult._rspTotalArrayList._BothArray  addObject:tmp_RouteSearch];
				//int Cnt = [_netResult._rspTotalArrayList._BothArray  count];
				//LOG_TRACE (@"보스리절트= %d",Cnt);
			}
			else if(isRecommend) 
            {
				[_netResult._rspTotalArrayList._RecommendArray  addObject:tmp_RouteSearch];
				//int Cnt = [_netResult._rspTotalArrayList._RecommendArray  count];
				//LOG_TRACE (@"추천리절트= %d",Cnt);
				/*
				if(Cnt > 0){
					for(int a=0; a<Cnt; a++){
						RouteSearch* item = [_netResult._rspTotalArrayList._RecommendArray objectAtIndexGC:a];
									
						int Cnts = [item._RouteSearchBusRGArray count];
						LOG_TRACE(@"############ _RouteSearchBusRGArray : %d", Cnt);
						for(int a=0; a<Cnts; a++){
							RouteSearchBusRGItems* itemz = [item._RouteSearchBusRGArray objectAtIndexGC:a];
							LOG_TRACE(@"-------- _distance : %@", itemz._distance);
							LOG_TRACE(@"-------- _distancetype : %@", itemz._distancetype);
							LOG_TRACE(@"-------- _endname : %@", itemz._endname);
							LOG_TRACE(@"-------- _lanename : %@", itemz._lanename);
							LOG_TRACE(@"-------- _methodtype : %@", itemz._methodtype);
							LOG_TRACE(@"-------- _rgtype : %@", itemz._rgtype);
							LOG_TRACE(@"-------- _startname : %@", itemz._startname);
							LOG_TRACE(@"-------- _x : %@", itemz._x);
							LOG_TRACE(@"-------- _y : %@", itemz._y);
						}
					}
				}
				LOG_TRACE(@"추천추가완료");
				 */
			}			
			tmp_RouteSearch = [[RouteSearch alloc] init];			 
		}
		else if([elementName isEqualToString:@"Response"])
        {
			tmp_RouteSearch = nil;
			//_netResult._routeSearch = [_netResult._rspTotalArrayList._RecommendArray objectAtIndexGC:0];
		}
	}
}

@end

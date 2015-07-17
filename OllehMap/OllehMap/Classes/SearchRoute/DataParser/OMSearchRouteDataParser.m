//
//  OMSearchRouteDataParser.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 30..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMSearchRouteDataParser.h"

@implementation OMSearchRouteDataParser

@synthesize nVehicleType = _nVehicleType;

/*- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"item"]) 
        elementType = etItem;
    
    [xmlValue setString:@""];
}*/


- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // XML Element Start
    //NSLog(@"SearchRoute(CAR) :: [%@] Element Start \n=> %@", elementName, attributeDict);  
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 자동차
    if (_nVehicleType == 0)
    {        
        // Response
        if ([elementName isEqualToString:@"Response"])
        {            
            _isRoute = [[attributeDict objectForKeyGC:@"isRoute"] boolValue];
            [[oms searchRouteData] setIsRouteCar:_isRoute];
        }
        // Data
        else if ([elementName isEqualToString:@"DATA"])
        {
            KBounds ma;
            ma.minX = [[attributeDict objectForKeyGC:@"mbr_minx"] doubleValue];
            ma.minY = [[attributeDict objectForKeyGC:@"mbr_miny"] doubleValue];
            ma.maxX = [[attributeDict objectForKeyGC:@"mbr_maxx"] doubleValue];
            ma.maxY = [[attributeDict objectForKeyGC:@"mbr_maxy"] doubleValue];
            
            [[oms searchRouteData] setRouteCarMapArea:ma];
        }
        // Data - link
        else if ([elementName isEqualToString:@"link"])
        {            
        }
        // Data - link - vertex
        else if ([elementName isEqualToString:@"vertex"])
        {               
            double x = [[attributeDict objectForKeyGC:@"x"] doubleValue];
            double y = [[attributeDict objectForKeyGC:@"y"] doubleValue];
            
            if ([[[oms searchRouteData] routeCarLinks] count] <= 0)
            {
                [[[oms searchRouteData] routeCarLinks] addCoord:CoordMake(x, y)];
            }
            else
            {
                int linkCount = [[[oms searchRouteData] routeCarLinks] count];
                Coord prevCrd = [[[oms searchRouteData] routeCarLinks] getCoord:linkCount-1];
                Coord currCrd = CoordMake(x,y);

                if (CoordDistance(currCrd, prevCrd) != 0)
                {
                    [[[oms searchRouteData] routeCarLinks] addCoord:currCrd];
                } 
            }
        }
        // ROUTE
        else if ([elementName isEqualToString:@"ROUTE"])
        {
            oms.searchRouteData.routeCarPointCount = [[attributeDict objectForKeyGC:@"rg_count"] intValue];
            oms.searchRouteData.routeCarTotalDistance = [[attributeDict objectForKeyGC:@"total_dist"] doubleValue];
            oms.searchRouteData.routeCarTotalTime = [[attributeDict objectForKeyGC:@"total_time"] floatValue];
        }
        // ROUTE - rg
        else if ([elementName isEqualToString:@"rg"])
        {         
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:7];
            [dic setObject:[attributeDict objectForKeyGC:@"dir_name"] forKey:@"Direction"];
            [dic setObject:[attributeDict objectForKeyGC:@"link_idx"] forKey:@"Index"];
            [dic setObject:[attributeDict objectForKeyGC:@"nextdist"] forKey:@"NextDistance"];
            [dic setObject:[attributeDict objectForKeyGC:@"node_name"] forKey:@"Name"];
            [dic setObject:[attributeDict objectForKeyGC:@"type"] forKey:@"Type"];
            [dic setObject:[attributeDict objectForKeyGC:@"x"] forKey:@"X"];
            [dic setObject:[attributeDict objectForKeyGC:@"y"] forKey:@"Y"];
            [[[oms searchRouteData] routeCarPoints] addObject:dic];
        }

    }
    // 대중교통
    else if (_nVehicleType == 1)
    {        
        // Response
        if ([elementName isEqualToString:@"Response"])
        {            
            _isRoute = [[attributeDict objectForKeyGC:@"isRoute"] boolValue];
            [[oms searchRouteData] setIsRoutePublic:_isRoute];
        }
        // Recommend Category
        else if ([elementName isEqualToString:@"RECOMMEND"])
        {            
            _nCurrentPublicCategory = 0;
            oms.searchRouteData.routePublicRecommendCount = [[attributeDict objectForKeyGC:@"resultcount"] intValue];
        }
        // Both Category
        else if ([elementName isEqualToString:@"BOTH"])
        {            
            _nCurrentPublicCategory = 1;
            oms.searchRouteData.routePublicBothCount = [[attributeDict objectForKeyGC:@"resultcount"] intValue];
        }
        // Bus Category
        else if ([elementName isEqualToString:@"BUS"])
        {            
            _nCurrentPublicCategory = 2;
            oms.searchRouteData.routePublicBusCount = [[attributeDict objectForKeyGC:@"resultcount"] intValue];
        }
        // Subway Category
        else if ([elementName isEqualToString:@"SUBWAY"])
        {            
            _nCurrentPublicCategory = 3;
            oms.searchRouteData.routePublicSubwayCount = [[attributeDict objectForKeyGC:@"resultcount"] intValue];
        }
        // Category - Result
        else if ([elementName isEqualToString:@"RESULT"])
        {
            int no = [[attributeDict objectForKeyGC:@"no"] intValue];
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
            [resultDic setObject:[NSString stringWithFormat:@"%d", no] forKey:@"No"];
            if (_nCurrentPublicCategory == 0)
                [oms.searchRouteData.routePublicRecommend addObject:resultDic];
            else if (_nCurrentPublicCategory == 1)
                [oms.searchRouteData.routePublicBoth addObject:resultDic];
            else if (_nCurrentPublicCategory == 2)
                [oms.searchRouteData.routePublicBus addObject:resultDic];
            else if (_nCurrentPublicCategory == 3)
                [oms.searchRouteData.routePublicSubway addObject:resultDic];
        }
        // Category - Result - Display
        else if ([elementName isEqualToString:@"DISPLAY"])
        {
            NSMutableDictionary *resultDic = [self getCurrentPublicCategory];
            
            CGPoint pMax, pMin;
            pMin.x = [[attributeDict objectForKeyGC:@"mbr_xmin"] doubleValue];
            pMin.y = [[attributeDict objectForKeyGC:@"mbr_ymin"] doubleValue];
            pMax.x = [[attributeDict objectForKeyGC:@"mbr_xmax"] doubleValue];
            pMax.y = [[attributeDict objectForKeyGC:@"mbr_ymax"] doubleValue];
            
            [resultDic setObject:[NSValue valueWithCGPoint:pMax] forKey:@"MapAreaMax"];
            [resultDic setObject:[NSValue valueWithCGPoint:pMin] forKey:@"MapAreaMin"];
            
            NSMutableArray *methods = [NSMutableArray array];
            [resultDic setObject:methods forKey:@"MethodList"];
            
            NSMutableArray *station = [NSMutableArray array];
            [resultDic setObject:station forKey:@"Station"];
        }
        // Category - Result - Display - Method
        else if ([elementName isEqualToString:@"METHOD"])
        {
            NSMutableDictionary *resultDic = [self getCurrentPublicCategory];
            
            NSMutableArray *methods = [resultDic objectForKeyGC:@"MethodList"];

            NSMutableDictionary *method = [NSMutableDictionary dictionary];
            [method setObject:[NSString stringWithFormat:@"%d",[[attributeDict objectForKeyGC:@"type"] intValue]] forKey:@"Type"];
            
            NSMutableArray *vertexs = [NSMutableArray array];
            [method setObject:vertexs forKey:@"VertexList"];
            
            [methods addObject:method];
        }
        // Category - Result - Display - Method - Vertex
        else if ([elementName isEqualToString:@"VERTEX"])
        {
            NSMutableDictionary *resultDic = [self getCurrentPublicCategory];
            NSMutableArray *methods = [resultDic objectForKeyGC:@"MethodList"];
            NSMutableDictionary *method = [methods objectAtIndexGC:methods.count-1];
            NSMutableArray *vertexs = [method objectForKeyGC:@"VertexList"];

            double x = [[attributeDict objectForKeyGC:@"x"] doubleValue];
            double y = [[attributeDict objectForKeyGC:@"y"] doubleValue];
            
            Coord vertex = CoordMake(x,y);
            
            if (vertexs.count > 0)
            {
                CGPoint p = CGPointMake(0, 0);
                [[vertexs objectAtIndexGC:vertexs.count-1] getValue:&p];

                Coord prevVertex = CoordMake(p.x, p.y);                
                if ( CoordDistance(vertex, prevVertex) != 0 )
                {
                    [vertexs addObject:[NSValue valueWithCGPoint:CGPointMake(vertex.x, vertex.y)]];
                }
            }
            else
            {
                CGPoint point = CGPointMake(x, y);
                [vertexs addObject:[NSValue valueWithCGPoint:point]];
            }
        }
        // Category - Result - Display - Station
        else if ([elementName isEqualToString:@"STATION"])
        {
        }
        // Category - Result - Display - Station - Node
        else if ([elementName isEqualToString:@"NODE"])
        {
            NSMutableDictionary *resultDic = [self getCurrentPublicCategory];
            NSMutableArray *stations = [resultDic objectForKeyGC:@"Station"];

            NSMutableDictionary *station = [NSMutableDictionary dictionary];
            [station setObject:[attributeDict objectForKeyGC:@"id"] forKey:@"ID"];
            [station setObject:[attributeDict objectForKeyGC:@"stationtype"] forKey:@"StationType"];
            [station setObject:[attributeDict objectForKeyGC:@"x"] forKey:@"X"];
            [station setObject:[attributeDict objectForKeyGC:@"y"] forKey:@"Y"];
            
            [stations addObject:station];
        }
        // Category - Result - Route
        else if ([elementName isEqualToString:@"ROUTE"])
        {
            NSMutableDictionary *resultDic = [self getCurrentPublicCategory];
            NSMutableDictionary *route = [NSMutableDictionary dictionary];
            
            [route setObject:[attributeDict objectForKeyGC:@"busnum"] forKey:@"BusCount"];
            [route setObject:[attributeDict objectForKeyGC:@"subwaynum"] forKey:@"SubwayCount"];
            [route setObject:[attributeDict objectForKeyGC:@"totaldistance"] forKey:@"TotalDistance"];
            [route setObject:[attributeDict objectForKeyGC:@"totaltime"] forKey:@"TotalTime"];
            [route setObject:[attributeDict objectForKeyGC:@"rgcount"] forKey:@"RGCount"];
            [route setObject:[attributeDict objectForKeyGC:@"charge"] forKey:@"TotalFare"];
            
            NSMutableArray *gates = [NSMutableArray array];
            [route setObject:gates forKey:@"Gates"];
            
            [resultDic setObject:route forKey:@"RouteGate"];
        }
        // Category - Result - Route - RG
        else if ([elementName isEqualToString:@"RG"])
        {
            NSMutableDictionary *resultDic = [self getCurrentPublicCategory];
            NSMutableDictionary *route = [resultDic objectForKeyGC:@"RouteGate"];
            
            NSMutableArray *gates = [route objectForKeyGC:@"Gates"];
            
            NSMutableDictionary *gate = [NSMutableDictionary dictionary];
            [gate setObject:[attributeDict objectForKeyGC:@"distance"] forKey:@"Distance"];
            [gate setObject:[attributeDict objectForKeyGC:@"distancetype"] forKey:@"DistanceType"];
            [gate setObject:[attributeDict objectForKeyGC:@"eID"] forKey:@"eID"];
            [gate setObject:[attributeDict objectForKeyGC:@"sID"] forKey:@"sID"];
            [gate setObject:[attributeDict objectForKeyGC:@"lID"] forKey:@"lID"];
            [gate setObject:[attributeDict objectForKeyGC:@"startname"] forKey:@"StartName"];
            [gate setObject:[attributeDict objectForKeyGC:@"endname"] forKey:@"EndName"];
            [gate setObject:[attributeDict objectForKeyGC:@"lanename"] forKey:@"LaneName"];
            [gate setObject:[attributeDict objectForKeyGC:@"rgtype"] forKey:@"RgType"];
            [gate setObject:[attributeDict objectForKeyGC:@"methodtype"] forKey:@"MethodType"];
            [gate setObject:[attributeDict objectForKeyGC:@"x"] forKey:@"X"];
            [gate setObject:[attributeDict objectForKeyGC:@"y"] forKey:@"Y"];            
            
            [gates addObject:gate];
        }

    }
    
    
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // XML Elemnt End
    //NSLog(@"SearchRoute(CAR) :: [%@] Element End", elementName);
        
    if ([_strErrorMessage length] > 0)
    {
        
        // 자동차
        if (_nVehicleType == 0)
        {            
            [[[OllehMapStatus sharedOllehMapStatus] searchRouteData] setRouteCarError:[NSString stringWithFormat:@"%@", _strErrorMessage]];
        }
        // 대중교통
        else if (_nVehicleType == 1)
        {
            [[[OllehMapStatus sharedOllehMapStatus] searchRouteData] setRoutePublicError:[NSString stringWithFormat:@"%@", _strErrorMessage]];
        }
        
        /*
        [_strErrorMessage release];
        _strErrorMessage = nil;
        */
    }
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // XML value
    //NSLog(@"foundCharacters  %@", string);
    
    // 길찾기 데이터에 오류체크 된경우 오류메세지 리턴 (현재 한글or영문코드 혼재되어있음)
    // 자동차
    if (_nVehicleType == 0)
    {
        [_strErrorMessage appendString:string];
    }
    // 대중교통
    else if (_nVehicleType == 1)
    {              
        [_strErrorMessage appendString:string];
    }

    
}

- (void) parseRouteData :(NSData *)data
{
    _strErrorMessage = [[[NSMutableString alloc] init] autorelease];
    
    if (_nVehicleType == 0)
    {
        [[OllehMapStatus sharedOllehMapStatus].searchRouteData resetCar];
    }
    // 대중교통
    else if (_nVehicleType == 1)
    {              
        [[OllehMapStatus sharedOllehMapStatus].searchRouteData resetPublic];
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
}


- (NSMutableDictionary *) getCurrentPublicCategory
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    NSMutableDictionary *resultDic = nil;
    switch (_nCurrentPublicCategory) 
    {
        case 0:
            resultDic = [oms.searchRouteData.routePublicRecommend objectAtIndexGC:oms.searchRouteData.routePublicRecommend.count-1];
            break;
        case 1:
            resultDic = [oms.searchRouteData.routePublicBoth objectAtIndexGC:oms.searchRouteData.routePublicBoth.count-1];
            break;
        case 2:
            resultDic = [oms.searchRouteData.routePublicBus objectAtIndexGC:oms.searchRouteData.routePublicBus.count-1];
            break;
        case 3:
            resultDic = [oms.searchRouteData.routePublicSubway objectAtIndexGC:oms.searchRouteData.routePublicSubway.count-1];
            break;
    }
    return resultDic;
}

@end

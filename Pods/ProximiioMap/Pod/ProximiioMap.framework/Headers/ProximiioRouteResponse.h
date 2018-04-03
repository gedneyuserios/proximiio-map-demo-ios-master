//
//  ProximiioRouteResponse.h
//  ProximiioMap
//
//  Created by Matej Drzik on 09/02/2018.
//  Copyright © 2018 Proximi.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ProximiioLeveledPolyline.h"
#import "GeoJSONFeature.h"

@interface ProximiioRouteResponse : NSObject

@property (nonatomic, strong) ProximiioLeveledPolyline *leveledPolyline;
@property (nonatomic, strong) NSArray *steps;
@property (nonatomic, strong) GeoJSONFeature *start;
@property (nonatomic, strong) GeoJSONFeature *finish;
@property (nonatomic, strong) GeoJSONFeature *nearestPoint;
@property (nonatomic, strong) NSNumber *distance;
@property BOOL levelChanges;
@property BOOL successful;

@end

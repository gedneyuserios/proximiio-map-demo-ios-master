//
//  TurfIndexedCoordinate.h
//  DemoWayFinding
//
//  Created by Matej Drzik on 25/01/2018.
//  Copyright © 2018 Office. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TurfIndexedCoordinate : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property int index;
@property double location;
@property (nonatomic) CLLocationDistance distance;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate index:(int)index distance:(CLLocationDistance)distance;

@end

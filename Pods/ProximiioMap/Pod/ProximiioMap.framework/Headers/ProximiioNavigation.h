//
//  ProximiioNavigation.h
//  ProximiioMap
//
//  Created by Matej Drzik on 09/02/2018.
//  Copyright © 2018 Proximi.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ProximiioLeveledPolyline.h"
#import "ProximiioRouteResponse.h"
#import <Proximiio/ProximiioLocation.h>

@interface ProximiioNavigation : NSObject

@property (weak) id delegate;
@property (nonatomic, getter=isActive) BOOL active;
@property (nonatomic) double routeEndDistance;

- (id)initWithToken:(NSString *)token;
- (void)setCurrentLocation:(ProximiioLocation *)location;
- (void)setCurrentLevel:(int)level;
- (void)setTargetLocation:(ProximiioLocation *)location;
- (void)setTargetLevel:(int)level;
- (void)update;
- (CLLocation *)targetLocation;
- (int)targetLevel;

@end

@protocol ProximiioNavigationDelegate

- (void)didUpdateInstructions:(NSArray *)instructions;
- (void)didUpdateRoutingLine:(ProximiioLeveledPolyline *)polyline;

- (void)navigationDidReceiveResponse:(ProximiioRouteResponse *)response;
- (void)navigationDidFinish;

@end


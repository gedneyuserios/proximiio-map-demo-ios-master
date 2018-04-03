//
//  GeoJSONFeature.h
//  DemoWayFinding
//
//  Created by Matej Drzik on 25/01/2018.
//  Copyright © 2018 Office. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoJSONFeature : NSObject

- (id)initWithData:(NSDictionary *)data;
+ (GeoJSONFeature *)lineWithCoordinates:(NSArray *)coordinates properties:(NSDictionary *)properties;
+ (GeoJSONFeature *)emptyLine;

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *geometry;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSDictionary *feature;

@end

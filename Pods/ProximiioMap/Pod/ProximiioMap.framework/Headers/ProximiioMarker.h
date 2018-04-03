//
//  ProximiioMarker.h
//  ProximiioMap
//
//  Created by Matej Drzik on 22/06/2017.
//  Copyright © 2017 Proximi.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface ProximiioMarker : NSObject

-(NSString *)identifier;
-(id)mapAnnotation;
-(UIImage *)image;
-(NSString *)title;
-(void)setTitle:(NSString *)title;
-(NSString *)subtitle;
-(void)setSubtitle:(NSString *)subtitle;
-(void)setCoordinate:(CLLocationCoordinate2D)coordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate identifier:(NSString *)identifier;
-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate identifier:(NSString *)identifier image:(UIImage *)image;
- (id)copyWithZone:(NSZone *)zone;

@end

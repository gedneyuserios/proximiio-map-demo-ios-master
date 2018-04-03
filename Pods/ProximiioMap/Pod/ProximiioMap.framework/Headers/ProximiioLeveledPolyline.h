//
//  ProximiioLeveledPolyline.h
//  ProximiioMap
//
//  Created by Matej Drzik on 09/02/2018.
//  Copyright © 2018 Proximi.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProximiioLeveledPolyline : NSObject

- (void)addPolyline:(id)polyline forLevel:(int)level;
- (id)polylineForLevel:(int)level;

@end

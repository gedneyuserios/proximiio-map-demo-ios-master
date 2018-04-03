//
//  ProximiioLayerManager.h
//  ProximiioMap
//
//  Created by Matej Drzik on 06/02/2018.
//  Copyright © 2018 Proximi.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProximiioLayerManager : NSObject

- (BOOL)hasLayers;
- (void)switchLayersToLevel:(int)level forMap:(id)mapView;

@property (nonatomic, strong) NSArray *layers;

@end

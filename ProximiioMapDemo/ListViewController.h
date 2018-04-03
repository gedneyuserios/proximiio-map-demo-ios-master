//
//  ListViewController.h
//  ProximiioMapDemo
//
//  Copyright © 2017 Proximi.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Proximiio/Proximiio.h>
#import "GeoTargetCell.h"

@interface ListViewController : UITableViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, GeoTargetCellProtocol>

@property (weak) id delegate;
@property (strong, nonatomic) NSArray *features;
@property (strong, nonatomic) NSArray *amenityCategories;
@property (strong, nonatomic) NSArray *amenities;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSNumber *selectedLevel;

@end


@protocol GeofencesTableViewDelegate

- (void)didSelectGeofence:(ProximiioGeofence *)geofence;
- (void)didSelectFeature:(NSDictionary *)feature;
- (void)showLocation:(NSDictionary *)data;
- (void)routeLocation:(NSDictionary *)data;
@end

//
//  GeoTargetCell.h
//  DemoWayFinding
//
//  Created by Matej Drzik on 06/02/2018.
//  Copyright © 2018 Office. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GeoTargetCell : UITableViewCell

@property (weak) id delegate;
@property int level;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIButton *routeButton;
@property (nonatomic, strong) CLLocation *location;

@end

@protocol GeoTargetCellProtocol
-(void)didPressShow:(GeoTargetCell *)cell;
-(void)didPressRoute:(GeoTargetCell *)cell;
@end


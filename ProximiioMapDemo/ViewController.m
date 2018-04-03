//
//  ViewController.m
//
//  Copyright © 2017 Proximi.io. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "HTTPClient.h"

@import UserNotifications;
@import Proximiio;
@import ProximiioMap;

typedef enum {
    kRoutingModeDisabled,
    kRoutingModeEnabled
} RoutingMode;

typedef enum {
    kTrackingModeDisabled,
    kTrackingModeEnabled
} TrackingMode;

#define FLYTO_DURATION 3
#define FLYTO_DISTANCE 50

#define TOKEN @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImlzcyI6ImU5OWQ3MDNjLWMyZWItNDBmOS1iZmIyLTkyMzhmNzQ4ZjEyNiIsInR5cGUiOiJhcHBsaWNhdGlvbiIsImFwcGxpY2F0aW9uX2lkIjoiY2UyMTdmYzQtOGVhZC00N2U1LWFlNTUtZDZhYzM3MDhmOWVlIn0.EcXBu5wLb9HoWW_te4-wRVwzvby6LLOvAoHdl9Llaek"

@interface ViewController ()<ProximiioDelegate, ProximiioMapDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate> {
    ProximiioLocation *routeTarget;
    BOOL tracking;
    BOOL initialView;
    CLLocationManager *locationManager;
    int currentLevel;
    int targetLevel;
    NSString *targetInfo;
    ProximiioLocation *currentLocation;
    ProximiioLocation *carLocation;
    ProximiioFloor *lastFloor;
    int parkedLevel;
    BOOL navigationTargetIsCar;
    UITextView *debugView;
    NSString *locationType;
    RoutingMode routingMode;
    TrackingMode trackingMode;
    ProximiioMarker *targetMarker;
    ProximiioMarker *carMarker;
    NSArray *amenityCategories;
    UIView *trackButton;
    UIView *levelUpButton;
    UIView *levelDownButton;
    UILabel *levelLabel;
    UIView *debugButton;
    UIButton *actionButton;
    CGFloat relativeAltitude;
    CLLocationCoordinate2D closestCoordinate;
}
@property (nonatomic, strong) ProximiioMap *mapView;

@end

@implementation ViewController

- (BOOL)map:(ProximiioMap *)map canShowCallout:(ProximiioMarker *)marker {
    return YES;
}

- (void)map:(ProximiioMap *)map didSelectMarker:(ProximiioMarker *)marker {
//    NSLog(@"selected marker: %@", marker.title);
}

- (void)mapDidChangeState:(ProximiioMap *)map {
    
}

- (void)directionsRouteFinished
{    // Example on how to handle the arrival
    // Let's remove the car marker if we navigated to it, so the user can re-park their car
    if(navigationTargetIsCar)
    {
        [_mapView removeMarker:carMarker];
        carMarker = nil;
        carLocation = nil;
    }
    [self stopNavigation];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Arrival"
                                                                   message:@"You have arrived at your destination."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)levelUp {
    [_mapView setFloor:_mapView.floor + 1 alterRouting:NO];
    [self updateLevel:_mapView.floor];
    [self pulseButton:levelUpButton];
}

- (void)levelDown {
    [_mapView setFloor:_mapView.floor - 1 alterRouting:NO];
    [self updateLevel:_mapView.floor];
    [self pulseButton:levelDownButton];
}

- (void)toggleDebug {
    if (debugView.hidden) {
        debugView.alpha = 0;
        debugView.hidden = NO;
        [self changeButton:debugButton alphaTo:0.5];
        [UIView animateWithDuration:0.3 animations:^{
            debugView.alpha = 1;
        }];
    } else {
        [self changeButton:debugButton alphaTo:0.2];
        [UIView animateWithDuration:0.3 animations:^{
            debugView.alpha = 0;
        } completion:^(BOOL finished) {
            debugView.hidden = YES;
        }];
    }
}

-(void)toggleActionButton:(UIButton *)sender {
    if (currentLocation) {
        if (routingMode == kRoutingModeEnabled) {
            [self stopNavigation];
        } else {
            if ([sender.titleLabel.text isEqualToString:@"PARK HERE"]) {
                parkedLevel = currentLevel;
                carLocation = currentLocation;
                [self updateTitle];
                
                [[NSUserDefaults standardUserDefaults]setInteger:parkedLevel forKey:@"currentLevel"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                //[[NSUserDefaults standardUserDefaults]setObject:[NSKeyedArchiver archivedDataWithRootObject:carLocation] forKey:@"currentLocation"];
                
                [self saveCustomObject:currentLocation key:@"currentLocation"];
                
    
                carMarker = [[ProximiioMarker alloc] initWithCoordinate:carLocation.coordinate identifier:@"my-car" image:[UIImage imageNamed:@"car"]];
                carMarker.title = @"My Car";
                carMarker.subtitle = @"Parked";
                [_mapView addMarker:carMarker];
                
                [sender setTitle:@"LOCATE MY CAR" forState:UIControlStateNormal];
                
            } else if ([sender.titleLabel.text isEqualToString:@"LOCATE MY CAR"]) {
                
                //routeTarget = (ProximiioLocation *)carLocation;
                //targetLevel = parkedLevel;
                
                routeTarget = [self loadCustomObjectWithKey:@"currentLocation"];
                targetLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"currentLevel"];
                
                navigationTargetIsCar = YES;
                [self startNavigation];
                
                
                NSLog(@"Before----->>Level is- %@ and Parked At- %d", routeTarget,targetLevel);
                
                
                //Extra Code...
                //NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"currentLocation"];
               //ProximiioLocation *carLocation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                
                //NSLog(@"After----->>Level is- %ld and Parked At- %@",  (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"currentLevel"]
                  //    , [self loadCustomObjectWithKey:@"currentLocation"]);
                
                
            }
        }
    } else {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"We are sorry"
                                     message:@"Your position is not yet available, it should take no more then few seconds"
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * action) {
                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}



- (void)saveCustomObject:(ProximiioLocation *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

- (ProximiioLocation *)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    ProximiioLocation *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}




- (void)startNavigation {
    routingMode = kRoutingModeEnabled;
    [actionButton setTitle:@"STOP NAVIGATION" forState:UIControlStateNormal];
    [_mapView routeTo:routeTarget levelTo:targetLevel];
    CGRect bounds = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.3 animations:^{
        debugView.frame = CGRectMake(0, bounds.size.height - 150, bounds.size.width, 50);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        actionButton.frame = CGRectMake(0, bounds.size.height - 100, bounds.size.width, 50);
    }];
}

- (void)stopNavigation {
    routingMode = kRoutingModeDisabled;
    if (carLocation == nil) {
        [actionButton setTitle:@"PARK HERE" forState:UIControlStateNormal];
    } else {
        [actionButton setTitle:@"LOCATE MY CAR" forState:UIControlStateNormal];
    }
    routeTarget = nil;
    [_mapView stopRouting];
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    [UIView animateWithDuration:0.3 animations:^{
        actionButton.frame = CGRectMake(0, bounds.size.height - 50, bounds.size.width, 50);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        debugView.frame = CGRectMake(0, bounds.size.height - 110, bounds.size.width, 60);
    }];
}

- (void)didTapFeatures:(NSArray *)features {
    NSDictionary *poi;
    for (NSDictionary *feature in features) {
        if ([_mapView featureIsPOI:feature]) {
            poi = feature;
            break;
        }
    }
    if (poi) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Point of Interest"
                                     message:poi[@"properties"][@"title"]
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Route To"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    NSArray *coordinates = poi[@"geometry"][@"coordinates"];
                                                    CLLocation *location = [[CLLocation alloc] initWithLatitude:[coordinates[1] doubleValue] longitude:[coordinates[0] doubleValue]];
                                                    NSString *title = poi[@"properties"][@"title"];
                                                    targetInfo = title;
                                                    [self routeLocation:@{@"location": location, @"title": title, @"level": @(currentLevel)}];
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * action) {
                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)updateDebugView {
    NSString *location;
    
    if (currentLocation) {
        NSString *levelInfo;
        
        if (routeTarget) {
            levelInfo = [NSString stringWithFormat:@"CURRENT LEVEL: %d   TARGET LEVEL: %d", currentLevel, targetLevel];
        } else {
            levelInfo = [NSString stringWithFormat:@"CURRENT LEVEL: %d", currentLevel];
        }
        location = [NSString stringWithFormat:@"SOURCE: %@ (%@)\nLAT: %1.8f   LNG: %1.8f   ALT: %1.2f\n%@", NSStringFromClass(currentLocation.source.class), locationType,  currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, relativeAltitude, levelInfo];
    } else {
        location = @"NO LOCATION YET";
    }
    
    debugView.text = location;
}

- (void)showLocation:(NSDictionary *)data {
    routingMode = kRoutingModeDisabled;
    trackingMode = kTrackingModeDisabled;
    [self.navigationController popViewControllerAnimated:YES];
    CLLocation *location = data[@"location"];
    
    if (targetMarker != nil) {
        [_mapView removeMarker:targetMarker];
    }

    targetMarker = [[ProximiioMarker alloc] initWithCoordinate:location.coordinate identifier:@"target-marker" image:[UIImage imageNamed:@"icon_pin"]];
    targetMarker.title = data[@"title"];
    targetMarker.subtitle = @"POI Info goes here";
    
    targetInfo = data[@"title"];
    [self updateTitle];
    
    [_mapView addMarker:targetMarker];
    
    [_mapView setFloor:[data[@"level"] intValue] alterRouting:NO];
    [_mapView flyTo:location duration:FLYTO_DURATION distance:FLYTO_DISTANCE pitch:45 heading:_mapView.cameraHeading + 90];
}

- (void)routeLocation:(NSDictionary *)data {
    routingMode = kRoutingModeEnabled;
    trackingMode = kTrackingModeEnabled;
    [self.navigationController popViewControllerAnimated:YES];
    CLLocation *location = data[@"location"];
    if (targetMarker != nil) {
        [_mapView removeMarker:targetMarker];
    }
    targetMarker = [[ProximiioMarker alloc] initWithCoordinate:location.coordinate identifier:@"target-marker" image:[UIImage imageNamed:@"icon_pin"]];
    targetMarker.title = data[@"title"];
    targetMarker.subtitle = @"POI Info goes here";
    [_mapView addMarker:targetMarker];
    
    routeTarget = [ProximiioLocation locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    targetLevel = [data[@"level"] intValue];
    navigationTargetIsCar = NO;
    [self startNavigation];
    self.title = [NSString stringWithFormat:@"To: %@", data[@"title"]];
}

- (void)search {
    ListViewController *vc = [[ListViewController alloc] init];
    NSMutableArray *filtered = [NSMutableArray array];
    for (NSDictionary *feature in _mapView.features) {
        if (feature[@"properties"][@"usecase"] != nil && [feature[@"properties"][@"usecase"] isKindOfClass:NSString.class]) {
            if ([feature[@"properties"][@"usecase"] isEqualToString:@"poi"]) {
                [filtered addObject:feature];
            }
        }
    }
    vc.selectedLevel = @(currentLevel);
    vc.features = _mapView.pointsOfInterests;
    vc.amenityCategories = amenityCategories;
    vc.amenities = _mapView.amenities;
    
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toggleTracking {
    tracking = !tracking;
    trackingMode = tracking ? kTrackingModeEnabled : kTrackingModeDisabled;
    [self pulseButton:trackButton];
    [self changeButton:trackButton imageTo:trackingMode == kTrackingModeEnabled ? @"track_off" : @"track_on"];
    [_mapView setTrackingMode:trackingMode ? kProximiioTrackingModeEnabled : kProximiioTrackingModeDisabled];
}

- (void)updateLevel:(int)level {
    currentLevel = level;
    levelLabel.text = [NSString stringWithFormat:@"%d", _mapView.floor];
    [self updateTitle];
}

-(void)updateTitle {
    if (routingMode == kProximiioRoutingModeEnabled) {
        self.title = [NSString stringWithFormat:@"Route to: %@", targetInfo];
    } else {
        if (lastFloor) {
            self.title = [NSString stringWithFormat:@"Current Level: %d", _mapView.floor];
        } else {
            self.title = @"Proximi.io Map Demo";
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    initialView = YES;
    currentLevel = 0;
    targetLevel = 0;
    relativeAltitude = 0;
    tracking = YES;
    trackingMode = kTrackingModeEnabled;
    routingMode = kRoutingModeDisabled;
    locationType = @"STD";
    navigationTargetIsCar = NO;
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
//    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect bounds = self.view.frame;
    _mapView = [[ProximiioMap alloc] initWithFrame:bounds token:TOKEN delegate:self];
    _mapView.delegate = self;
    _mapView.trackingMode = kProximiioTrackingModeEnabled;
    _mapView.delegate = self;
    _mapView.showPointsOfInterest = NO;
    _mapView.showRasterFloorplans = NO;
    _mapView.defaultPosition = CLLocationCoordinate2DMake(25.337282, 51.480934);
    _mapView.defaultZoomLevel = 16.5;
    _mapView.routeEndDistance = 4;
    
    [self.view addSubview:_mapView.view];
    
    trackButton = [self roundButtonWithImage:@"track_off" selector:@selector(toggleTracking) index:0 left:YES];
    [self.view addSubview:trackButton];
    
    debugButton = [self roundButtonWithImage:@"icon-spy" selector:@selector(toggleDebug) index:1 left:YES];
    [self.view addSubview:debugButton];
    
    levelUpButton = [self roundButtonWithImage:@"icon-up" selector:@selector(levelUp) index:1 left:NO];
    [self.view addSubview:levelUpButton];
    
    levelDownButton = [self roundButtonWithImage:@"icon-down" selector:@selector(levelDown) index:3 left:NO];
    [self.view addSubview:levelDownButton];
    
    levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(levelDownButton.frame) + 10, 80, 50, 50)];
    levelLabel.text = @"0";
    levelLabel.font = [UIFont boldSystemFontOfSize:16.0];
    levelLabel.textAlignment = NSTextAlignmentCenter;
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    levelLabel.layer.cornerRadius = 25;
    levelLabel.clipsToBounds = YES;
    levelLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:levelLabel];

    debugView = [[UITextView alloc] initWithFrame:CGRectMake(0, bounds.size.height - 100, bounds.size.width, 50)];
    debugView.font = [UIFont boldSystemFontOfSize:12];
    debugView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    debugView.textContainerInset = UIEdgeInsetsMake(4, 10, 4, 10);
    debugView.text = @"please wait, initializing";
    debugView.hidden = YES;
    debugView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:debugView];
    
    // initialize proximi.io sdk and set it's delegate to the mapView
    //
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PROXIMIIO_ALTITUDE_CHANGED" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        CMAltitudeData *data = (CMAltitudeData *)note.object;
        relativeAltitude = data.relativeAltitude.floatValue;
        [self updateDebugView];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PROXIMIIO_CLOSEST_COORDINATE" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        closestCoordinate = ((CLLocation *)note.object).coordinate;
        [self updateDebugView];
    }];
     
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PROXIMIIO_MAP_LOCATION" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *locationInfo = (NSDictionary *)note.object;
        locationType = locationInfo[@"type"];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                           target:self
                                                                                           action:@selector(search)];
    
    actionButton = [[UIButton alloc]initWithFrame:CGRectMake(0, bounds.size.height - 50, bounds.size.width, 50)];
    [actionButton setTitle:@"PARK HERE" forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(toggleActionButton:) forControlEvents:UIControlEventTouchUpInside];
    [actionButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [actionButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    actionButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:actionButton];
        
    [HTTPClient GET:@"https://testapi.proximi.fi/v4/geo/amenity_categories" withToken:TOKEN onComplete:^(NSDictionary *jsonData) {
        amenityCategories = (NSArray *)jsonData;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onProximiioReady {
    [self updateDebugView];
}

- (void)proximiioPositionUpdated:(ProximiioLocation *)location {
    currentLocation = location;
    [self updateDebugView];
}

- (void)proximiioFloorChanged:(ProximiioFloor *)floor {
    if (floor) {
        lastFloor = floor;
        [self updateLevel:_mapView.floor];
    }
}

- (BOOL)proximiioHandlePushMessage:(NSString *)title {
    return NO;
}


- (UIView *)roundButtonWithImage:(NSString *)image selector:(SEL)selector index:(int)index left:(BOOL)onLeft {
//    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect bounds = self.view.frame;
    float x = onLeft ? 20 + (index * 60) : bounds.size.width - 20 - (index * 60);
    float y = 80;
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(x, y, 50, 50)];
    background.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    background.layer.cornerRadius = 25;
    background.userInteractionEnabled = YES;
    background.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [background addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:selector]];
    
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    icon.image = [UIImage imageNamed:image];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [background addSubview:icon];
    
    return background;
}

- (void)changeButton:(UIView *)button alphaTo:(float)alpha {
    [UIView animateWithDuration:0.3 animations:^{
        button.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
    }];
}

- (void)pulseButton:(UIView *)button {
    [UIView animateWithDuration:0.075 animations:^{
        button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.075 animations:^{
            button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        }];
    }];
}

- (void)changeButton:(UIView *)button imageTo:(NSString *)image {
    UIImageView *icon = [button subviews][0];
    icon.image = [UIImage imageNamed:image];
}

@end

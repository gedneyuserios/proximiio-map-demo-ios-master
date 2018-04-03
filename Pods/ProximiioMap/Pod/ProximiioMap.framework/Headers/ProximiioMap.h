//
//  ProximiioMap.h
//  ProximiioMap
//

#import <UIKit/UIKit.h>
#import "ProximiioMarker.h"
#import "ProximiioLayerManager.h"
#import "TurfIndexedCoordinate.h"
#import "ProximiioNavigation.h"
#import <Proximiio/ProximiioFloor.h>

FOUNDATION_EXPORT double ProximiioMapVersionNumber;
FOUNDATION_EXPORT const unsigned char ProximiioMapVersionString[];

typedef enum {
    kProximiioRoutingModeDisabled,
    kProximiioRoutingModeEnabled
} ProximiioRoutingMode;

typedef enum {
    kProximiioTrackingModeDisabled,
    kProximiioTrackingModeEnabled
} ProximiioTrackingMode;

typedef enum {
    kProximiioMapLoading,
    kProximiioMapError,
    kProximiioMapReady,
    kProximiioMapNavigating
} ProximiioMapState;

@interface ProximiioMap : NSObject

- (ProximiioMap *)initWithFrame:(CGRect)frame token:(NSString *)token delegate:(id)delegate;

// styling
- (void)setTintColor:(UIColor *)tintColor;
- (void)setDisplayHeadingCalibration:(BOOL)display;

// controlability toggles
- (void)setEnableRotate:(BOOL)enabled;
- (void)setEnablePitch:(BOOL)enabled;

// camera
- (void)flyTo:(CLLocation *)location duration:(float)duration distance:(float)distance pitch:(float)pitch heading:(CLLocationDirection)heading;
- (void)setCameraHeading:(CLLocationDirection)heading;
- (CLLocationDirection)cameraHeading;

// pitch
- (void)setCameraPitch:(CGFloat)pitch;
- (CGFloat)cameraPitch;

// center
- (void)setCenter:(CLLocationCoordinate2D)coordinate;
- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)setCenter:(CLLocationCoordinate2D)coordinate zoomLevel:(double)zoomLevel animated:(BOOL)animated;

// zoom
- (void)setMaximumZoomLevel:(double)zoomLevel;
- (void)setMinimumZoomLevel:(double)zoomLevel;
- (double)zoomLevel;
- (void)setZoomLevel:(double)zoomLevel animated:(BOOL)animated;
- (void)setZoomLevel:(double)zoomLevel;
- (BOOL)featureIsPOI:(NSDictionary *)feature;

// direction
- (void)setDirection:(CLLocationDirection)direction;
- (void)setDirection:(CLLocationDirection)direction animated:(BOOL)animated;

// floorplans
- (void)addFloorPlanForFloor:(ProximiioFloor *)floor;
- (void)removeFloorPlanForFloor:(ProximiioFloor *)floor;

// markers
- (void)addMarker:(ProximiioMarker *)marker;
- (void)removeMarker:(ProximiioMarker *)marker;
- (NSArray *)markers;

// circles
- (void)addCircleWithIdentifier:(NSString *)identifier coordinate:(CLLocationCoordinate2D)coordinate radius:(float)radius;
- (void)removeCircleWithIdentifier:(NSString *)identifier;

// user tracking
- (void)setTrackingMode:(ProximiioTrackingMode)mode;
- (ProximiioTrackingMode)trackingMode;
- (void)setUserLocation:(ProximiioLocation *)location;

// Routing
- (void)routeTo:(ProximiioLocation *)location levelTo:(int)levelTo;
- (void)stopRouting;

// Data Access
- (void)setFloor:(int)_floor alterRouting:(BOOL)alterRouting;
- (int)floor;

@property (nonatomic) BOOL showRasterFloorplans;
@property (nonatomic) BOOL showExtrusion;
@property (nonatomic) BOOL showPolygons;
@property (nonatomic) BOOL showPointsOfInterest;
@property (nonatomic) BOOL showPaths;
@property (nonatomic) BOOL showRoutingLine;
@property (nonatomic) BOOL snapToRoute;

@property (nonatomic) BOOL displayInstructions;
@property (nonatomic) BOOL directionsPlayAudioGuide;
@property (nonatomic) double directionsAudioGuideMinimumDelay;
@property (nonatomic) double directionsAudioGuideMinimumDistanceTravelled;

@property (nonatomic) double routeEndDistance;

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) NSArray *features;
@property (nonatomic, strong) NSArray *amenities;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSArray *pointsOfInterests;
@property (nonatomic, strong) NSArray *levelChangers;

@property (nonatomic, strong) UIColor *routeColor;
@property (nonatomic, strong) NSNumber *routeAlpha;
@property (nonatomic, strong) NSNumber *routeLineWidth;

@property (nonatomic, strong) ProximiioLayerManager *layerManager;

@property (nonatomic) CLLocationCoordinate2D defaultPosition;
@property (nonatomic) double defaultZoomLevel;

@property (weak) id delegate;

@end

@protocol ProximiioMapDelegate
@optional
- (void)mapDidLoad:(ProximiioMap *)map;
- (void)mapDidChangeState:(ProximiioMap *)map;

// marker interaction
- (BOOL)map:(ProximiioMap *)map canShowCallout:(ProximiioMarker *)marker;
- (void)map:(ProximiioMap *)map didSelectMarker:(ProximiioMarker *)marker;
- (void)map:(ProximiioMap *)map didChangeFloor:(int)level;

// features interaction
- (void)map:(ProximiioMap *)map didTapFeatures:(NSArray *)features;

- (void)didTapFeatures:(NSArray *)features; // obsolete

// routing
- (void)directionsRouteFinished;


@end

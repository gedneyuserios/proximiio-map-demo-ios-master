//
//  ListViewController.m
//  ProximiioMapDemo
//
//  Copyright © 2017 Proximi.io. All rights reserved.
//

#import "ListViewController.h"
#import <Proximiio/Proximiio.h>
#import <QRCodeReaderViewController/QRCodeReaderViewController.h>
#import "GeoTargetCell.h"

#define SEGMENT_POI 0
#define SEGMENT_GEOFENCES 1

@interface ListViewController () <QRCodeReaderDelegate> {
    int segment;
    NSDictionary *departments;
    NSMutableDictionary *categorizedAmenities;
    NSArray *sortedDepartments;
    NSArray *departmentTitles;
    NSArray *departmentIds;
    NSMutableDictionary *amenityFeatures;
    NSArray *sortedAmenityCategories;
    NSString *searchQuery;
    UISegmentedControl *floorControl;
}

@property (nonatomic, strong) NSString *qrCode;
@property (nonatomic, strong) NSArray *geofences;

@end

@implementation ListViewController

static NSString *CellIdentifier = @"GeoTargetCell";

- (void)search:(NSString *)query {
    searchQuery = query;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self search:searchText];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self search:searchString];
}

- (void)setGeofences:(NSArray *)geofences {
    _geofences = [geofences sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
}

- (void)searchQR:(id)sender {
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    QRCodeReaderViewController *vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    
    // Set the presentation style
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        _qrCode = resultAsString;
        
        for (ProximiioGeofence *geofence in _geofences) {
            if ([geofence.uuid isEqualToString:_qrCode]) {
                if (_delegate && [_delegate respondsToSelector:@selector(didSelectGeofence:)]) {
                    [self.delegate performSelector:@selector(didSelectGeofence:) withObject:geofence];
                }
                break;
            }
        }
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)segmentChanged:(UISegmentedControl *)control {
    segment = (int)control.selectedSegmentIndex;
    [self.tableView reloadData];
}

- (NSArray *)floors {
    return [[[ProximiioResourceManager sharedManager] allFloors] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"level" ascending:YES]]];
}

- (void)floorChanged:(UISegmentedControl *)control {
    ProximiioFloor *floor = [[self floors] objectAtIndex:control.selectedSegmentIndex];
    _selectedLevel = floor.level;
    [self.tableView reloadData];
}

- (int)segmentIndexForLevel:(int)level {
    int i =0;
    int segmentIndex = 0;
    for (ProximiioFloor *floor in [self floors]) {
        if (floor.level.intValue == level) {
            segmentIndex = i;
        }
        i++;
    }
    return segmentIndex;
}

- (ProximiioFloor *)floorForLevel:(int)level {
    ProximiioFloor *floor;
    for (ProximiioFloor *_floor in [[ProximiioResourceManager sharedManager] allFloors]) {
        if (_floor.level.intValue == level) {
            floor = _floor;
        }
    }
    return floor;
}

- (void)setSelectedLevel:(NSNumber *)selectedLevel {
    _selectedLevel = selectedLevel;
    floorControl.selectedSegmentIndex = [self segmentIndexForLevel:_selectedLevel.intValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    searchQuery = @"";
    [self.tableView registerClass:GeoTargetCell.class forCellReuseIdentifier:@"GeoTargetCell"];
    self.geofences = [[ProximiioResourceManager sharedManager] allGeofences];
    
    NSMutableDictionary *mutableDepartments = [NSMutableDictionary dictionary];
    NSMutableDictionary *departmentIdToNames = [NSMutableDictionary dictionary];
    NSMutableArray *uniqueDepartments = [NSMutableArray array];
    for (ProximiioGeofence *geofence in _geofences) {
        if (geofence.department) {
            if (mutableDepartments[geofence.department.uuid] == nil) {
                departmentIdToNames[geofence.department.uuid] = geofence.department.name;
                mutableDepartments[geofence.department.uuid] = [NSMutableArray arrayWithArray:@[geofence]];
                [uniqueDepartments addObject:geofence.department];
            } else {
                [mutableDepartments[geofence.department.uuid] addObject:geofence];
            }
        }
    }
    
    sortedDepartments = [uniqueDepartments sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    departments = [NSDictionary dictionaryWithDictionary:mutableDepartments];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.showsCancelButton = NO;
    searchBar.placeholder = @"Search here";
    searchBar.delegate = self;
    
    self.searchController.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.navigationItem.titleView = searchBar;
    self.definesPresentationContext = YES;
//    [self.searchController.searchBar sizeToFit];

    [self.tableView registerClass:GeoTargetCell.class forCellReuseIdentifier:CellIdentifier];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIView *segmentedContainer= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    segmentedContainer.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Points Of Interests", @"Geofences", nil]];
    segmentedControl.frame = CGRectMake(20, 5, self.view.frame.size.width - 40, 30);
    segmentedControl.layer.cornerRadius = 0;
    segmentedControl.selectedSegmentIndex = SEGMENT_POI;
    [segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentedContainer addSubview:segmentedControl];

    NSMutableArray *floors = [NSMutableArray array];
    for (ProximiioFloor *floor in [[[ProximiioResourceManager sharedManager] allFloors] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"level" ascending:YES]]]) {
        [floors addObject:[NSString stringWithFormat: @"%d", floor.level.intValue]];
    }
    
    floorControl = [[UISegmentedControl alloc] initWithItems:floors];
    floorControl.frame = CGRectMake(20, 45, self.view.frame.size.width - 40, 30);
    floorControl.layer.cornerRadius = 0;
    [floorControl addTarget:self action:@selector(floorChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentedContainer addSubview:floorControl];

    
    self.tableView.tableHeaderView = segmentedContainer;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                           target:self
                                                                                           action:@selector(searchQR:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAmenities:(NSArray *)amenities {
    _amenities = amenities;
    sortedAmenityCategories = [amenities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    amenityFeatures = [NSMutableDictionary dictionary];
    for (NSDictionary *feature in _features) {
        NSString *amenity = feature[@"properties"][@"amenity"];
        if (amenity == nil) {
            amenity = @"default";
        }
        if (amenityFeatures[amenity] == nil) {
            amenityFeatures[amenity] = [NSMutableArray array];
        }
        [amenityFeatures[amenity] addObject:feature];
    }
    
    for (NSString *key in amenityFeatures.allKeys) {
        amenityFeatures[key] = [amenityFeatures[key] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"properties.title" ascending:YES]]];
    }
    [self.tableView reloadData];
}

- (void)didPressShow:(GeoTargetCell *)cell {
    [self.delegate performSelector:@selector(showLocation:) withObject:@{ @"location": cell.location, @"title": cell.title.text, @"level": @(cell.level) }];
}

- (void)didPressRoute:(GeoTargetCell *)cell {
    [self.delegate performSelector:@selector(routeLocation:) withObject:@{ @"location": cell.location, @"title": cell.title.text, @"level": @(cell.level) }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (segment == SEGMENT_GEOFENCES) {
        return sortedDepartments.count;
    } else {
        return sortedAmenityCategories.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *filtered = [NSMutableArray array];
    if (segment == SEGMENT_GEOFENCES) {
        ProximiioDepartment *department = sortedDepartments[section];
        if ([self shouldFilter]) {
            for (ProximiioGeofence *geofence in departments[department.uuid]) {
                if ([geofence.name.lowercaseString containsString:searchQuery.lowercaseString]) {
                    if (geofence.department && geofence.department.floor && geofence.department.floor.level.intValue == _selectedLevel.intValue) {
                        [filtered addObject:geofence];
                    }
                }
            }
        } else {
            for (ProximiioGeofence *geofence in departments[department.uuid]) {
                if (geofence.department.floor.level.intValue == _selectedLevel.intValue) {
                    [filtered addObject:geofence];
                }
            }
            
        }
    } else {
        NSDictionary *amenity = sortedAmenityCategories[section];
        if ([self shouldFilter]) {
            for (NSDictionary *feature in amenityFeatures[amenity[@"id"]]) {
                if (feature[@"properties"][@"title"] != nil && [[feature[@"properties"][@"title"] lowercaseString] containsString:searchQuery.lowercaseString]) {
                    if (feature[@"properties"][@"level"] != nil && [feature[@"properties"][@"level"] intValue] == _selectedLevel.intValue) {
                        [filtered addObject:feature];
                    }
                }
            }
        } else {
            for (NSDictionary *feature in amenityFeatures[amenity[@"id"]]) {
                if (feature[@"properties"][@"level"] != nil && [feature[@"properties"][@"level"] intValue] == _selectedLevel.intValue) {
                    [filtered addObject:feature];
                }
            }
        }
    }
    return filtered.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (BOOL)shouldFilter {
    return searchQuery.length > 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GeoTargetCell *cell = (GeoTargetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableArray *filtered = [NSMutableArray array];

    if (segment == SEGMENT_GEOFENCES) {
        ProximiioDepartment *department = sortedDepartments[indexPath.section];
        ProximiioGeofence *geofence;
        
        if ([self shouldFilter]) {
            for (ProximiioGeofence *_geofence in departments[department.uuid]) {
                if ([_geofence.name.lowercaseString containsString:searchQuery.lowercaseString]) {
                    [filtered addObject:_geofence];
                }
            }
        } else {
            ProximiioDepartment *department = sortedDepartments[indexPath.section];
            filtered = departments[department.uuid];
        }
        
        NSMutableArray *levelGeofences = [NSMutableArray array];
        for (ProximiioGeofence *_geofence in filtered) {
            if (_geofence.department.floor.level.intValue == _selectedLevel.intValue) {
                [levelGeofences addObject:_geofence];
            }
        }
        
        geofence = levelGeofences[indexPath.row];
        
        cell.title.text = geofence.name;
        int level = 0;
        
        if (geofence.department && geofence.department.floor) {
            level = geofence.department.floor.level.intValue;
        }
        
        cell.level = level;
        cell.subtitle.text = [NSString stringWithFormat:@"%@", [self floorForLevel:level].name];
        cell.location = geofence.area;
    } else {
        NSDictionary *amenity = sortedAmenityCategories[indexPath.section];
        NSDictionary *feature;
        if ([self shouldFilter]) {
            for (NSDictionary *_feature in amenityFeatures[amenity[@"id"]]) {
                if (_feature[@"properties"][@"title"] != nil && [[_feature[@"properties"][@"title"] lowercaseString] containsString:searchQuery.lowercaseString]) {
                    [filtered addObject:_feature];
                }
            }
        } else {
            NSDictionary *amenity = sortedAmenityCategories[indexPath.section];
            for (NSDictionary *_feature in amenityFeatures[amenity[@"id"]]) {
                [filtered addObject:_feature];
            }
        }
        
        NSMutableArray *levelFeatures = [NSMutableArray array];
        for (NSDictionary *_feature in filtered) {
            if (_feature[@"properties"][@"level"] != nil && [_feature[@"properties"][@"level"] intValue] == _selectedLevel.intValue) {
                [levelFeatures addObject:_feature];
            }
        }
        
        feature = levelFeatures[indexPath.row];
        cell.title.text = feature[@"properties"][@"title"];
        NSArray *coordinates = feature[@"geometry"][@"coordinates"];
        cell.location = [[CLLocation alloc] initWithLatitude:[coordinates[1] floatValue] longitude:[coordinates[0] floatValue]];
        int level = [feature[@"properties"][@"level"] intValue];
        cell.level = level;
        cell.subtitle.text = [NSString stringWithFormat:@"%@", [self floorForLevel:level].name];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (segment == SEGMENT_GEOFENCES) {
        ProximiioDepartment *department = sortedDepartments[section];
        if (department) {
            return department.name;
        } else {
            return @"Unknown department";
        }
    } else {
        return sortedAmenityCategories[section][@"title"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 49)];
    background.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    [view addSubview:background];
    
    if (segment == SEGMENT_GEOFENCES) {
        ProximiioDepartment *department = sortedDepartments[section];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, self.view.frame.size.width - 30, 20)];
        title.font = [UIFont boldSystemFontOfSize:12.0];
        title.text = department.name;
        [view addSubview:title];
    }
    
    if (segment == SEGMENT_POI) {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
        
        NSDictionary *amenity = sortedAmenityCategories[section];
        if (amenity[@"icon"]) {
            NSData *data = [[NSData alloc]initWithBase64EncodedString:[amenity[@"icon"] componentsSeparatedByString:@","][1] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            icon.image = [UIImage imageWithData:data];
        } else {
            icon.image = [UIImage imageNamed:@"icon_pin"];
        }
        [view addSubview:icon];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, self.view.frame.size.width - 50, 20)];
        title.font = [UIFont boldSystemFontOfSize:12.0];
        title.text = [amenity[@"title"] uppercaseString];
        [view addSubview:title];
    }
    return view;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    floorControl.selectedSegmentIndex = [self segmentIndexForLevel:_selectedLevel.intValue];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                           target:self
                                                                                           action:@selector(back)];
}
@end

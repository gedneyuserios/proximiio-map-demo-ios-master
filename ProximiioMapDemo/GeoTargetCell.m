//
//  GeoTargetCell.m
//  DemoWayFinding
//
//  Created by Matej Drzik on 06/02/2018.
//  Copyright © 2018 Office. All rights reserved.
//

#import "GeoTargetCell.h"

@implementation GeoTargetCell

- (void)layoutSubviews {
    [super layoutSubviews];
    _title.frame = CGRectMake(20, 5, self.frame.size.width - 50, 20);
    _subtitle.frame = CGRectMake(20, 25, self.frame.size.width - 50, 20);
    _showButton.frame = CGRectMake(self.frame.size.width - 100, 10, 30, 30);
    _routeButton.frame = CGRectMake(self.frame.size.width - 50, 10, 30, 30);
}

- (void)didPressRoute:(id)sender {
    [self.delegate performSelector:@selector(didPressRoute:) withObject:self];
}

- (void)didPressShow:(id)sender {
    [self.delegate performSelector:@selector(didPressShow:) withObject:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userInteractionEnabled = YES;
        
        _title = [[UILabel alloc] initWithFrame:CGRectZero];
        [_title setFont:[UIFont systemFontOfSize:12]];
        _title.textColor = [UIColor blackColor];
        _title.text = @"title";
        [self addSubview:_title];

        _subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
        [_subtitle setFont:[UIFont systemFontOfSize:12]];
        _subtitle.textColor = [UIColor blackColor];
        _subtitle.text = @"title";
        [self addSubview:_subtitle];

        _showButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _showButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [_showButton.layer setBorderColor:[UIColor blueColor].CGColor];
        [_showButton.layer setBorderWidth:1.0];
        [_showButton.layer setCornerRadius:6.0];
//        [_showButton setTitle:@"SHOW" forState:UIControlStateNormal];
        [_showButton setImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
        [_showButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_showButton addTarget:self action:@selector(didPressShow:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_showButton];
        
        _routeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _routeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [_routeButton.layer setBorderColor:[UIColor orangeColor].CGColor];
        [_routeButton.layer setBorderWidth:1.0];
        [_routeButton.layer setCornerRadius:6.0];
//        [_routeButton setTitle:@"ROUTE" forState:UIControlStateNormal];
        [_routeButton setImage:[UIImage imageNamed:@"route_to"] forState:UIControlStateNormal];
        [_routeButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_routeButton addTarget:self action:@selector(didPressRoute:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_routeButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

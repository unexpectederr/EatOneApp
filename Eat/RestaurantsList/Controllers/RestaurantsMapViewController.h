//
//  RestaurantsMapView.h
//  Eat
//
//  Created by Haris Muharemovic on 09/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantModel.h"
#import <GoogleMaps/GoogleMaps.h>

@protocol RestaurantsMapViewProtocol

- (void)didTapOnMarkerInfoWindow:(RestaurantModel*)restaurant;

@end

@interface RestaurantsMapViewController : UIViewController <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *restaurantsMapView;
@property (weak, nonatomic) NSArray<RestaurantModel*> *restaurantsArray;
@property (weak, nonatomic) id<RestaurantsMapViewProtocol> delegate;

@end

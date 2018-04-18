//
//  ViewController.m
//  Eat
//
//  Created by Haris Muharemovic on 08/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import "RegionsViewController.h"
#import "RegionCollectionViewCell.h"
#import "RegionModel.h"
#import "CuisineModel.h"
#import "RestaurantsListViewController.h"
#import "APIManager.h"
#import "CacheManager.h"
#import "Constants.h"
#import "UIHelper.h"

@import CoreTelephony;

static const int regionCellHeight = 75;

@interface RegionsViewController ()

@end

@implementation RegionsViewController {
    
    NSArray *regionsArray;
    int counter;
    BOOL listOfNeighbourhoodsAndCuisinesLoaded;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (regionsArray) {
        [self showRegionList];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getRegions];
    [self getCuisines];
    [self getNeigbourhoods];

    [_regionsCollectionView registerNib:[UINib nibWithNibName:@"RegionCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"regionCollectionViewCell"];

}

- (void)getRegions {
    
    RegionsViewController* __weak welf = self;

    [[APIManager sharedInstance] getRegions:^(id responseObject) {
        
        RegionsViewController* strongSelf = welf;
        if(!strongSelf) return;

        NSMutableArray *regions = [[NSMutableArray alloc] init];
        for (NSDictionary *regionResponse in responseObject) {
            NSError *error;
            RegionModel *region = [[RegionModel alloc] initWithDictionary:regionResponse error:&error];
            [regions addObject:region];
        }
        
        [[CacheManager sharedInstance] saveData:regions withId:REGIONS_DATA];

        [strongSelf preselectOrShowRegionList:regions];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {}];
}

- (void)getCuisines {
    
    RegionsViewController* __weak welf = self;

    [[APIManager sharedInstance] getCuisines:^(id responseObject) {
        
        RegionsViewController* strongSelf = welf;
        if(!strongSelf) return;
        
        NSMutableArray *cuisines = [[NSMutableArray alloc] init];
        for (NSDictionary *cuisinesResponse in responseObject) {
            NSError *error;
            CuisineModel *cuisine = [[CuisineModel alloc] initWithDictionary:cuisinesResponse error:&error];
            [cuisines addObject:cuisine];
        }
        
        [[CacheManager sharedInstance] saveData:cuisines withId:CUISINES_DATA];

        [strongSelf checkIfListOfNeighbourhoodsAndCuisinesLoaded];
    
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {}];
}

- (void)getNeigbourhoods {
    
    RegionsViewController* __weak welf = self;

    [[APIManager sharedInstance] getNeighbourhoods:^(id responseObject) {
        
        RegionsViewController* strongSelf = welf;
        if(!strongSelf) return;
        
        [strongSelf checkIfListOfNeighbourhoodsAndCuisinesLoaded];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {}];
}

- (void)preselectOrShowRegionList:(NSArray<RegionModel*>*)regions {
    
    regionsArray = regions;
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    
    int regionCounter = 0;
    NSString *regionId;
    
    for (RegionModel *region in regions) {
        if ([region.country_code isEqualToString:[carrier.isoCountryCode uppercaseString]]) {
            regionId = region.id;
            regionCounter++;
        }
    }
    
    /*
     if only one region is present for given isCountryCode - open it
     */
    if (regionCounter == 1) {
        [self openListOfRestaurants:regionId];
    } else {
        [self showRegionList];
    }
}

- (void)showRegionList {
    self.welcomeLabel.hidden = NO;
    self.regionsCollectionView.hidden = NO;
    [self.regionsCollectionView reloadData];
}

- (void)checkIfListOfNeighbourhoodsAndCuisinesLoaded {
    counter++;
    if (counter == 2) {
        listOfNeighbourhoodsAndCuisinesLoaded = YES;
        self.loader.hidden = YES;
        if (regionsArray)
            [self.regionsCollectionView reloadData];
    }
}

#pragma <CollectionViewDataSource>

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return regionsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RegionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"regionCollectionViewCell" forIndexPath:indexPath];
    
    RegionModel *region = regionsArray[indexPath.row];
    [cell buildCell:region];
    
    cell.backgroundColor = listOfNeighbourhoodsAndCuisinesLoaded ? [UIColor whiteColor] : [UIColor lightGrayColor];
    cell.userInteractionEnabled = listOfNeighbourhoodsAndCuisinesLoaded ? YES : NO;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width - 100, regionCellHeight);
}

#pragma <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RegionCollectionViewCell *cell = (RegionCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithCGColor:[UIHelper colorFromHexString:@"#74BF7A"].CGColor];
    
    NSString *regionId = ((RegionModel*)regionsArray[indexPath.row]).id;
    
    [self openListOfRestaurants:regionId];
    
}

- (void)openListOfRestaurants:(NSString *)regionId {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RestaurantsListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RestaurantsListViewController"];
    vc.regionCode = regionId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end

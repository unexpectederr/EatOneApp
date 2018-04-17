//
//  RestaurantsListViewController.m
//  Eat
//
//  Created by Haris Muharemovic on 08/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import "RestaurantsListViewController.h"
#import "RestaurantDetailsViewController.h"
#import "RestaurantCollectionViewCell.h"
#import "APIManager.h"
#import <AFNetworking.h>
#import "RestaurantModel.h"
#import "RestaurantsMapViewController.h"
#import "UIHelper.h"

@interface RestaurantsListViewController () <RestaurantsMapViewProtocol>

@end

@implementation RestaurantsListViewController {

    NSMutableArray *restaurantsArray;
    int pageToLoad;
    RestaurantsMapViewController *restaurantsMapView;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageToLoad = 1;
    
    [self getRestaurantsForRegion:_regionCode];

    [_restaurantsCollectionView registerNib:[UINib nibWithNibName:@"RestaurantCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"restaurantCollectionViewCell"];
    
    [_restaurantsCollectionView registerNib:[UINib nibWithNibName:@"LoaderCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"loaderCollectionViewCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemPressed:)];

}

- (void)getRestaurantsForRegion:(NSString*)region {
    
    if (pageToLoad == 1 || [[APIManager sharedInstance].restaurantsLoadingLink containsString:[NSString stringWithFormat:@"page=%li", (long)pageToLoad]]) {
        
        [[APIManager sharedInstance] getRestaurantsForRegion:region andPage:pageToLoad success:^(id responseObject) {
            
            NSMutableArray *restaurants = [UIHelper createListOfRestaurnats:responseObject];
            
            if (restaurants.count) {
                
                if (pageToLoad > 1) {
                    [self addNewSetOfRestaurnats:restaurants];
                } else {
                    [self showRestaurantsList:restaurants];
                }
            } else {
                [self showEmptyContainer];
            }
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            [self showEmptyContainer];
        }];
        
    } else if (pageToLoad > 1) {
        
        [self removeLoadingItem];
        
    }
}

- (void)rightBarButtonItemPressed:(id)sender {
    [self openMapView];
}

#pragma <RestaurantsListPresenterProtocol>

- (void)showEmptyContainer {
    
    self.restaurantsCollectionView.hidden = YES;
    self.emptyListMessage.hidden = NO;
    self.loadingIndicator.hidden = YES;
}

- (void)showRestaurantsList:(NSArray *)restaurants {
    
    restaurantsArray = [NSMutableArray arrayWithArray:restaurants];
    [restaurantsArray addObject:[[RestaurantModel alloc] initLoadingItem]];
    self.restaurantsCollectionView.hidden = NO;
    self.loadingIndicator.hidden = YES;
    [_restaurantsCollectionView reloadData];
    pageToLoad++;
}

- (void)addNewSetOfRestaurnats:(NSArray *)restaurants {
    
    [restaurantsArray addObjectsFromArray:restaurants];
    [restaurantsArray addObject:[[RestaurantModel alloc] initLoadingItem]];
   
    [_restaurantsCollectionView performBatchUpdates:^{
        
        NSMutableArray *indexesToReload = [NSMutableArray new];
        NSUInteger start = restaurantsArray.count - restaurants.count - 1;
        NSUInteger end = restaurantsArray.count;
        for(NSUInteger i = start; i < end; i++){
            [indexesToReload addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [_restaurantsCollectionView insertItemsAtIndexPaths:indexesToReload];
  
    } completion:^(BOOL finished) {
        [self removeLoadingItem];
    }];
    
    pageToLoad++;
}

- (void)removeLoadingItem {
    
    for (int i = 0; i < restaurantsArray.count; i++) {
    
        RestaurantModel *restaurant = (RestaurantModel*) restaurantsArray[i];
        
        if (restaurant.isLoadingItem) {
            [restaurantsArray removeObject:restaurant];
            [_restaurantsCollectionView performBatchUpdates:^{
                [_restaurantsCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            } completion:^(BOOL finished) {}];
            break;
        }
    }
}

#pragma <RestaurantsMapViewDelegate>

- (void)didTapOnMarkerInfoWindow:(RestaurantModel *)restaurant {
    [self openRestaurnatProfile: restaurant];
}

#pragma <CollectionViewDataSource>

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return restaurantsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;

    RestaurantModel *restaurant = restaurantsArray[indexPath.row];
    
    if (restaurant.isLoadingItem) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"loaderCollectionViewCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"restaurantCollectionViewCell" forIndexPath:indexPath];
        [(RestaurantCollectionViewCell*) cell buildCell:restaurant];
    }
   
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantModel *restaurant = restaurantsArray[indexPath.row];
    return CGSizeMake(self.view.bounds.size.width, restaurant.isLoadingItem ? 30 : 240);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == restaurantsArray.count-1) {
        [self getRestaurantsForRegion:_regionCode];
    }
}

#pragma <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self openRestaurnatProfile:(RestaurantModel*) restaurantsArray[indexPath.row]];
}


- (void)openRestaurnatProfile:(RestaurantModel*)restaurant {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RestaurantDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RestaurantDetailsViewController"];
    vc.restaurant = restaurant;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)openMapView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RestaurantsMapViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RestaurantsMapViewController"];
    vc.restaurantsArray = restaurantsArray;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}


@end

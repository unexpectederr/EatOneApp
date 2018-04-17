//
//  APIManager.h
//  Eat
//
//  Created by Haris Muharemovic on 17/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@protocol APIErrorDelegate <NSObject>
- (void)didReceiveAPIError:(NSError *)apiError;
@end

@interface APIManager : NSObject

@property (weak, nonatomic) id<APIErrorDelegate> errorHandlerDelegate;
@property (strong, nonatomic) NSString* restaurantsLoadingLink;

typedef void (^APISuccessBlock)(id responseObject);
typedef void (^APIFailureBlock)(NSURLSessionDataTask *operation, NSError *error);

+ (instancetype)sharedInstance;

- (void)getRegions:(APISuccessBlock)success failure:(APIFailureBlock)failure;
- (void)getCuisines:(APISuccessBlock)success failure:(APIFailureBlock)failure;
- (void)getNeighbourhoods:(APISuccessBlock)success failure:(APIFailureBlock)failure;
- (void)getRestaurantsForRegion:(NSString*)region andPage:(NSInteger)page success:(APISuccessBlock)success failure:(APIFailureBlock)failure;
- (void)getRestaurantsByRegion:(NSString*)region andCusine:(NSString*)cusine success:(APISuccessBlock)success failure:(APIFailureBlock)failure;
- (void)getRestaurantsByNeighbourhood:(NSString*)neighbourhood success:(APISuccessBlock)success failure:(APIFailureBlock)failure;

@end

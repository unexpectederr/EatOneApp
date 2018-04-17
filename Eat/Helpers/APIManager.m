//
//  APIManager.m
//  Eat
//
//  Created by Haris Muharemovic on 17/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import "APIManager.h"
#import "AFHTTPSessionManager.h"
#import "AFURLSessionManager.h"
#import "Constants.h"

@implementation APIManager {
    BOOL _allowInvalidCertificates;
}

- (APIManager *)init {
    if (self = [super init]){
    }
    _allowInvalidCertificates = NO;
    return self;
}

+ (instancetype)sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (AFHTTPSessionManager*) getAFHTTPRequestOperationManager {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    [manager.securityPolicy setValidatesDomainName:NO];
    return manager;
}

- (void)getRegions:(APISuccessBlock)success failure:(APIFailureBlock)failure{

    AFHTTPSessionManager *manager = [self getAFHTTPRequestOperationManager];
    NSString *url = [NSString stringWithFormat:@"%@/consumer/%@/%@", ENDPOINT_URL, API_VERSION, @"regions"];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];    
}

- (void)getCuisines:(APISuccessBlock)success failure:(APIFailureBlock)failure{
    
    AFHTTPSessionManager *manager = [self getAFHTTPRequestOperationManager];
    NSString *url = [NSString stringWithFormat:@"%@/consumer/%@/%@", ENDPOINT_URL, API_VERSION, @"cuisines"];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (void)getNeighbourhoods:(APISuccessBlock)success failure:(APIFailureBlock)failure{
    
    AFHTTPSessionManager *manager = [self getAFHTTPRequestOperationManager];

    NSString *url = [NSString stringWithFormat:@"%@/consumer/%@/%@", ENDPOINT_URL, API_VERSION, @"neighborhoods"];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (void)getRestaurantsForRegion:(NSString*)region andPage:(NSInteger)page success:(APISuccessBlock)success failure:(APIFailureBlock)failure {
    
    AFHTTPSessionManager *manager = [self getAFHTTPRequestOperationManager];

    NSString *url = [NSString stringWithFormat:@"%@/consumer/%@/%@", ENDPOINT_URL, API_VERSION, @"restaurants"];
    
    NSDictionary *params = @{
                             @"region_id": region,
                             @"page": @(page),
                             };
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        /*
         adding info about request so it can be used for pagination
         */
        NSHTTPURLResponse *httpResponse = ((NSHTTPURLResponse *)[task response]);
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            NSDictionary *dictionary = [httpResponse allHeaderFields];
            if (responseObject && dictionary[@"Link"])
                self.restaurantsLoadingLink = dictionary[@"Link"];
        }
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (void)getRestaurantsByRegion:(NSString*)region andCusine:(NSString*)cusine success:(APISuccessBlock)success failure:(APIFailureBlock)failure {
    
    AFHTTPSessionManager *manager = [self getAFHTTPRequestOperationManager];
    
    NSString *url = [NSString stringWithFormat:@"%@/consumer/%@/%@", ENDPOINT_URL, API_VERSION, @"restaurants"];
    
    NSDictionary *params = @{
                             @"region_id": region,
                             @"cuisine_id": cusine,
                             };
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (void)getRestaurantsByNeighbourhood:(NSString*)neighbourhood success:(APISuccessBlock)success failure:(APIFailureBlock)failure {
    
    AFHTTPSessionManager *manager = [self getAFHTTPRequestOperationManager];
    
    NSString *url = [NSString stringWithFormat:@"%@/consumer/%@/%@", ENDPOINT_URL, API_VERSION, @"restaurants"];
    
    NSDictionary *params = @{
                             @"neighborhood_id[]": neighbourhood,
                             };
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

@end

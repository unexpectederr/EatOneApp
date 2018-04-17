//
//  UIHelper.m
//  Eat
//
//  Created by Haris Muharemovic on 08/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import "UIHelper.h"
#import "RestaurantModel.h"

@implementation UIHelper

+ (NSMutableArray*)createListOfRestaurnats:(id)object {
    NSMutableArray *restaurants = [[NSMutableArray alloc] init];
    for (NSDictionary *restaurantResponse in object) {
        NSError *error;
        RestaurantModel *restaurant = [[RestaurantModel alloc] initWithDictionary:restaurantResponse error:&error];
        if (restaurant)
            [restaurants addObject:restaurant];
    }
    return restaurants;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end

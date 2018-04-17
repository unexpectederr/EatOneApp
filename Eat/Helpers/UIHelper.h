//
//  UIHelper.h
//  Eat
//
//  Created by Haris Muharemovic on 08/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIHelper : NSObject

+ (NSMutableArray*)createListOfRestaurnats:(id)object;
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end

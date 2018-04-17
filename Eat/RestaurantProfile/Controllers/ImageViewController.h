//
//  ImageViewController.h
//  Eat
//
//  Created by Haris Muharemovic on 08/04/2018.
//  Copyright © 2018 Haris Muharemovic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (nonatomic, assign) NSUInteger pageIndex;
@property (nonatomic, assign) NSString *imageUrl;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;

@end

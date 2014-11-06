//
//  ISMViewController.m
//  kikky 1235
//
//  Created by Ryusen Sasa on 2013/09/16.
//  Copyright (c) 2013年 Ryusen Sasa. All rights reserved.
//
#import <UIKit/UIKit.h>

static const int TRANSITION_END_VALUE_X = 250;

static const int MENU_OFFSET_X = 20;

static const int MENU_OFFSET_Y = 120;

@interface ISMViewController : UITabBarController <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
{
   
    UIImage *backArray[16];
}


- (void)switchToViewController:(NSUInteger)viewControllerIndex;
@end
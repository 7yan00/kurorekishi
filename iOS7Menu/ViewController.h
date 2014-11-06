//
//  ViewController.h
//  kikky01
//
//  Created by Ryusen Sasa on 2013/08/22.
//  Copyright (c) 2013年 Ryusen Sasa. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Twitter/Twitter.h>
#import <iAd/iAd.h>
#import <Accounts/Accounts.h>

@interface ViewController : UIViewController
                    <UITableViewDelegate,UITableViewDataSource>




{
    UIRefreshControl *_refreshControl;
    
    IBOutlet UIImageView *RbarView ;
    IBOutlet UIImageView *LbarView ;
    IBOutlet UIImageView *ReditView ;
    IBOutlet UIImageView *LeditView ;

    
    UIImage *barArray[16];
    UIImage *backArray[16];
    UIImage *barRArray[16];
    UIImage *LeditArray[16];
    UIImage *ReditArray[16];
}

-(void)getTimeLine;
-(void)alertAccountProblem;
-(void)refreshTable;
-(void)refreshTableOnFront;


@end

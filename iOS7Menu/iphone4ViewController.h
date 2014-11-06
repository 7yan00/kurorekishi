//
//  iphone4ViewController.h
//  iOS7Menu
//
//  Created by Ryusen Sasa on 2013/09/18.
//  Copyright (c) 2013年 monavari.de. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Twitter/Twitter.h>
#import <iAd/iAd.h>
#import <Accounts/Accounts.h>

@interface iphone4ViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource>




{
    UIRefreshControl *_refreshControl;
    
    
    UIImage *barArray[16];
    UIImage *backArray[16];
}

-(void)getTimeLine;
-(void)alertAccountProblem;
-(void)refreshTable;
-(void)refreshTableOnFront;


@end

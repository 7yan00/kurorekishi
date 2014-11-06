//
//  ViewController.m
//  kikky01
//
//  Created by Ryusen Sasa on 2013/08/22.
//  Copyright (c) 2013年 Ryusen Sasa. All rights reserved.
//

#import "ViewController.h"
#import "ISMAppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController : UIViewController {
    
    
    //タイムラインの最新20Tweetを保存する配列
    NSArray *tweets;
    
        IBOutlet ADBannerView *add_test;//広告表示ビュー
    
    //ツイート更新ボタン
    IBOutlet UIButton *reloadButton ;
    
    //ツイート投稿ボタン
    IBOutlet UIButton *tweetButton ;
    
    //Table Viewインスタンス
    IBOutlet UITableView *table ;
    
}


-(void)getTimeline {
    //Twitter APIのURLを準備
    //今回は「statuses/home_timeline.json」を利用
    NSString *apiURL =
    @"http://api.twitter.com/1/statuses/home_timeline.json" ;
    
    
    //iOS内に保存されているTwitterのアカウントの情報を取得
    ACAccountStore *store = [[ACAccountStore alloc] init] ;
    ACAccountType *TwitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //ユーザーにTwitterの認証情報を使うことを確認
    [store requestAccessToAccountsWithType:TwitterAccountType
           withCompletionHandler:^(BOOL granted, NSError *error) {
               
               
               //ユーザーが拒否した場合
               if (!granted) {
                   NSLog(@"Twitterへの承認が拒否されました。");
                   
                   
               //ユーザーの了解がとれた場合
               } else {
                   
                   //デバイスに保存されているTwitterのアカウント情報をすべて取得
                   NSArray *twitterAccounts = [store accountsWithAccountType:TwitterAccountType];
                   
                   //Twitterのアカウントが複数確認された場合
                   if ([twitterAccounts count] > 0 ) {
                       
                       //0番目のアカウントを使用
                       ACAccount *account = [twitterAccounts objectAtIndex:0];
                       
                       
                       //認証が必要な要求に関する設定
                       NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
                       [params setObject:@"1" forKey:@"include_entities"];
                       
                       
                       //リクエストを生成
                       NSURL *url = [NSURL URLWithString:apiURL];
                       TWRequest *request = [[TWRequest alloc]
                                              initWithURL:url parameters:params
                                              requestMethod:TWRequestMethodGET];
                       
                       
                       //リクエストに認証情報を付加
                       [request setAccount:account] ;
                       
                       //ステータスバーのActivity Indicatorを開始
                       [UIApplication sharedApplication].networkActivityIndicatorVisible =  YES;
                       
                       //リクエストを発行
                       [request performRequestWithHandler:
                                                    ^(NSData *responseData,
                                            NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                                                        
                       //twitterから応答がなかった場合
                       if (!responseData) {
                           
                           // inspect the contents of error
                           NSLog(@"response error %@", error) ;
                           
                       
                       //twitterからの返答があった場合
                       }else{
                          //JSONの配列を解析し、TweetをNSArrayの配列に入れる
                           NSError *jsonError ;
                           tweets = [NSJSONSerialization JSONObjectWithData:responseData
                                     options: NSJSONReadingMutableLeaves
                                     error:&jsonError];
                           //Tweet取得完了に伴い、tableViewを更新
                           [self refreshTableOnFront];
                           
                       }
                    }];
                } else {
                    [self alertAccountProblem];
                }
            }
           }];
}

//アカウント情報を設定画面上で編集するかどうかを確認する
-(void)alertAccountProblem {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitterアカウント" message:@"アカウント情報に問題があります。今すぐ設定でアカウントを確認しますか？" delegate:self cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    
    [alert show];
    
                          
}


//alert View上のボタンがクリックされた時の処理
//「はい」がおされた時にはTwitterの設定画面を開く
-(void)alertView:(UIAlertView *)alertView
                          clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex] ;
    
    if ([title isEqualToString:@"はい"]) {
        NSLog(@"設定画面移動");
        //アプリからTwitterの設定を起動
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]] ;
        
    }
    
}

//Table Viewのセクション数を指定
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    NSLog(@"section");
}

//Table Viewのセルの数を指定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweets count];
}





 //各セルにタイトルをセット
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //セルのスタイルを標準のものに指定
    
    static NSString * cellIdentifier = @"TweetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier] ;
    //カスタムセル上のラベル
    UILabel *tweetLabel = (UILabel*)[cell viewWithTag:1];
    UILabel *userLabel = (UILabel*)[cell viewWithTag:2];
    UIImageView *imgView = (UIImageView*)[cell viewWithTag: 3];
    
    //セルに表示するtweetのJSONを解析し、NSDictionaryに
    NSDictionary *tweetMessage = [tweets objectAtIndex:[indexPath row]];
    
    //ユーザー情報を格納するJSONを解析し、NSDictionaryに
    NSDictionary *userInfo = [tweetMessage objectForKey:@"user"];
    
    //SLog(@"userInfo is %@", userInfo);
    
    // img load
    NSURL *url = [NSURL URLWithString: [userInfo objectForKey: @"profile_image_url"]];
    NSData *img_data = [NSData dataWithContentsOfURL: url];
    UIImage *img = [[UIImage alloc] initWithData: img_data];
    
    //セルにtweetの情報とユーザー名を表示
    tweetLabel.text = [tweetMessage objectForKey:@"text"];
    userLabel.text = [userInfo objectForKey:@"screen_name"];
    [imgView setImage: img];
    NSLog(@"%@", img);
    
    return cell;
}








//リスト中のTweetが選択された時の処理

- (void)tableView:(UITableView *) didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルにされているtweetのJSONを解析し、NSDictionaryに
    NSDictionary *tweetMessage =
    [tweets objectAtIndex:[indexPath row]];
    
    //ユーザー情報を格納するJSONを解析し、NSDictionaryに
    NSDictionary *userInfo = [tweetMessage objectForKey:@"text"];
    
    
    //メッセージを表示
    UIAlertView *alert = [[UIAlertView alloc] init ];
    alert.title = [userInfo objectForKey:@"screen_name"];
    alert.message = [tweetMessage objectForKey:@"text"];
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    
}


//フロント側でテーブルを更新
- (void) refreshTableOnFront {
    [self performSelectorOnMainThread:@selector(refreshTable) withObject:self waitUntilDone:TRUE];
}

//テーブルの内容をセット
- (void)refreshTable {
    
    //ステータス上のActivity Indicatorを停止
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO ;
    
    //最新の内容にテーブルをセット
    [table reloadData];
}


//tweet作成画面を起動
- (IBAction)sendEasyTweet:(id)sender {
    //tweetが不可能な場合
    if ([TWTweetComposeViewController canSendTweet] == false) {
        
        //アカウントの問題をalert
        [self alertAccountProblem];
        
        //処理を中断
        return;
        
    }
    
    

    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result){
        NSString *output;
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"キャンセル");
                
                break;
            case TWTweetComposeViewControllerResultDone:
                output = @"Tweet投稿成功";
                break;
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];


    [self presentModalViewController:tweetViewController animated:YES];



}

- (IBAction)sendEasyTweet2:(id)sender {
    //tweetが不可能な場合
    if ([TWTweetComposeViewController canSendTweet] == false) {
        
        //アカウントの問題をalert
        [self alertAccountProblem];
        
        //処理を中断
        return;
        
    }
    
    
    
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result){
        NSString *output;
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"キャンセル");
                
                break;
            case TWTweetComposeViewControllerResultDone:
                output = @"Tweet投稿成功";
                break;
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    [self presentModalViewController:tweetViewController animated:YES];
    
    
    
}


     
-(IBAction)refreshTimeLine:(id)sender {
    [self getTimeline];
}

-(void)viewDidAppear:(BOOL)animated
{

    barArray[0] = [UIImage imageNamed:@"menubar001_03.png"];
    barArray[1] = [UIImage imageNamed:@"menubar02_03.png"];
    barArray[2] = [UIImage imageNamed:@"menubar03_03.png"];
    barArray[3] = [UIImage imageNamed:@"menubar04_03.png"];
    barArray[4] = [UIImage imageNamed:@"menubar05_03.png"];
    barArray[5] = [UIImage imageNamed:@"menubar06.png"];
    barArray[6] = [UIImage imageNamed:@"menubar07_03.png"];
    barArray[7] = [UIImage imageNamed:@"menubar08_03.png"];
    barArray[8] = [UIImage imageNamed:@"menubar09_03.png"];
    barArray[9] = [UIImage imageNamed:@"menubar10_03.png"];
    barArray[10] = [UIImage imageNamed:@"menubar11_03.png"];
    barArray[11] = [UIImage imageNamed:@"menubar12_03.png"];
    barArray[12] = [UIImage imageNamed:@"menubar13_03.png"];
    barArray[13] = [UIImage imageNamed:@"menubar14_03.png"];
    barArray[14] = [UIImage imageNamed:@"menubar15_03.png"];
    barArray[15] = [UIImage imageNamed:@"menubar16_03.png"];
    
    barRArray[0] = [UIImage imageNamed:@"menubar001_R.png"];
    barRArray[1] = [UIImage imageNamed:@"menubar02_R.png"];
    barRArray[2] = [UIImage imageNamed:@"menubar03_R.png"];
    barRArray[3] = [UIImage imageNamed:@"menubar04_R.png"];
    barRArray[4] = [UIImage imageNamed:@"menubar05_R.png"];
    barRArray[5] = [UIImage imageNamed:@"menubar06_R.png"];
    barRArray[6] = [UIImage imageNamed:@"menubar07_R.png"];
    barRArray[7] = [UIImage imageNamed:@"menubar08_R.png"];
    barRArray[8] = [UIImage imageNamed:@"menubar09_R.png"];
    barRArray[9] = [UIImage imageNamed:@"menubar10_R.png"];
    barRArray[10] = [UIImage imageNamed:@"menubar11_R.png"];
    barRArray[11] = [UIImage imageNamed:@"menubar12_R.png"];
    barRArray[12] = [UIImage imageNamed:@"menubar13_R.png"];
    barRArray[13] = [UIImage imageNamed:@"menubar14_R.png"];
    barRArray[14] = [UIImage imageNamed:@"menubar15_R.png"];
    
    ReditArray[0] = [UIImage imageNamed:@"Redit00_02"];
    ReditArray[1] = [UIImage imageNamed:@"Redit01_02"];
    ReditArray[2] = [UIImage imageNamed:@"Redit02_02"];
    ReditArray[3] = [UIImage imageNamed:@"Redit03_02"];
    ReditArray[4] = [UIImage imageNamed:@"Redit04_02"];
    ReditArray[5] = [UIImage imageNamed:@"Redit05_02"];
    ReditArray[6] = [UIImage imageNamed:@"Redit06_02"];
    ReditArray[7] = [UIImage imageNamed:@"Redit07_02"];
    ReditArray[8] = [UIImage imageNamed:@"Redit08_02"];
    ReditArray[9] = [UIImage imageNamed:@"Redit09_02"];
    ReditArray[10] = [UIImage imageNamed:@"Redit10_02"];
    ReditArray[11] = [UIImage imageNamed:@"Redit11_02"];
    ReditArray[12] = [UIImage imageNamed:@"Redit12_02"];
    ReditArray[13] = [UIImage imageNamed:@"Redit13_02"];
    ReditArray[14] = [UIImage imageNamed:@"Redit14_02"];
    
    
    LeditArray[0] = [UIImage imageNamed:@"Ledit_02"];
    LeditArray[1] = [UIImage imageNamed:@"Ledit01_02"];
    LeditArray[2] = [UIImage imageNamed:@"Ledit02_02"];
    LeditArray[3] = [UIImage imageNamed:@"Ledit03_02"];
    LeditArray[4] = [UIImage imageNamed:@"Ledit04_02"];
    LeditArray[5] = [UIImage imageNamed:@"Ledit05_02"];
    LeditArray[6] = [UIImage imageNamed:@"Ledit06_02"];
    LeditArray[7] = [UIImage imageNamed:@"Ledit07_02"];
    LeditArray[8] = [UIImage imageNamed:@"Ledit08_02"];
    LeditArray[9] = [UIImage imageNamed:@"Ledit09_02"];
    LeditArray[10] = [UIImage imageNamed:@"Ledit10_02"];
    LeditArray[11] = [UIImage imageNamed:@"Ledit11_02"];
    LeditArray[12] = [UIImage imageNamed:@"Ledit12_02"];
    LeditArray[13] = [UIImage imageNamed:@"Ledit13_02"];
    LeditArray[14] = [UIImage imageNamed:@"Ledit14_02"];

    
    
    if (kiki=2) {
    
        [RbarView setImage:barRArray[color]];
        [LeditView setImage:LeditArray[color]];
}else{
    if (kiki=1) {
   
        
        [LbarView setImage:barArray[color]];
        [ReditView setImage:ReditArray[color]];
    }
    
    }
    }


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getTimeline];
    
    add_test.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;//広告表示の種類（画面の向き）
    add_test.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [table addSubview:_refreshControl];
    
    [_refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];

    
    table.delegate = self;
    table.dataSource = self;
    
   
    
    
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    window = [[UIApplication sharedApplication].windows objectAtIndex:[[window subviews] count] ];
    window.rootViewController = [window rootViewController];
    
    
    
    

	// Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)fav:(id)sender{


    NSIndexPath *indexPath=[table indexPathForSelectedRow];
    NSDictionary *tweetMessage =
    [tweets objectAtIndex:[indexPath row]];
    
    //ユーザー情報を格納するJSONを解析し、NSDictionaryに
    //NSDictionary *tweetid = [tweetMessage objectForKey:@"id"];
    NSString *tweetid = [tweetMessage objectForKey:@"id"];

    
    NSLog(@"fav%@",tweetid);
    [self favoriteMessage:tweetid];
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"お知らせ";
    alert.message = @"お気に入りに登録されました";
    [alert addButtonWithTitle:@"了解"];
    [alert show];


}
-(IBAction)fav2:(id)sender{
    
    
    NSIndexPath *indexPath=[table indexPathForSelectedRow];
    NSDictionary *tweetMessage =
    [tweets objectAtIndex:[indexPath row]];
    
    //ユーザー情報を格納するJSONを解析し、NSDictionaryに
    //NSDictionary *tweetid = [tweetMessage objectForKey:@"id"];
    NSString *tweetid = [tweetMessage objectForKey:@"id"];
    
    
    NSLog(@"fav%@",tweetid);
    [self favoriteMessage:tweetid];
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"お知らせ";
    alert.message = @"お気に入りに登録されました";
    [alert addButtonWithTitle:@"了解"];
    [alert show];
    
    
}


-(IBAction)ret:(id)sender{
    NSLog(@"ret");
    
    NSIndexPath *indexPath=[table indexPathForSelectedRow];
    NSDictionary *tweetMessage =
    [tweets objectAtIndex:[indexPath row]];
    
    //ユーザー情報を格納するJSONを解析し、NSDictionaryに
    //NSDictionary *tweetid = [tweetMessage objectForKey:@"id"];
    NSString *tweetid = [tweetMessage objectForKey:@"id"];
    
    
    NSLog(@"fav%@",tweetid);
    [self retweetMessage:tweetid];
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"お知らせ";
    alert.message = @"リツイートされました";
    [alert addButtonWithTitle:@"了解"];
    [alert show];


    
}

-(IBAction)ret2:(id)sender{
    NSLog(@"ret");
    
    NSIndexPath *indexPath=[table indexPathForSelectedRow];
    NSDictionary *tweetMessage =
    [tweets objectAtIndex:[indexPath row]];
    
    //ユーザー情報を格納するJSONを解析し、NSDictionaryに
    //NSDictionary *tweetid = [tweetMessage objectForKey:@"id"];
    NSString *tweetid = [tweetMessage objectForKey:@"id"];
    
    
    NSLog(@"fav%@",tweetid);
    [self retweetMessage:tweetid];
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"お知らせ";
    alert.message = @"リツイートされました";
    [alert addButtonWithTitle:@"了解"];
    [alert show];
    
    
    
}
//iAd取得成功
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd取得成功");
    add_test.hidden = NO;
}

//iAd取得失敗
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd取得失敗");
    add_test.hidden = YES;
}

-(IBAction)ref:(id)sender{
    NSLog(@"ref");
    [self getTimeline];


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)favoriteMessage:(NSString *)message
{
    NSString *retweetString = [NSString stringWithFormat:@"https://api.twitter.com/1/favorites/create/%@.json", message];
    NSURL *retweetURL = [NSURL URLWithString:retweetString];
    TWRequest *request = [[TWRequest alloc] initWithURL:retweetURL parameters:nil requestMethod:TWRequestMethodPOST];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *twitterAccountType
    = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts
    = [accountStore accountsWithAccountType:twitterAccountType];
    ACAccount *account = [twitterAccounts objectAtIndex:0];
    
    request.account = account;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData)
        {
            NSError *parseError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
            
            if (!json)
            {
                NSLog(@"Parse Error: %@", parseError);
            }
            else
            {
                NSLog(@"%@", json);
            }
        }
        else
        {
            NSLog(@"Request Error: %@", [error localizedDescription]);
        }
    }];
}



-(void)retweetMessage:(NSString *)message
{
    NSString *retweetString = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/retweet/%@.json", message];
    NSURL *retweetURL = [NSURL URLWithString:retweetString];
    TWRequest *request = [[TWRequest alloc] initWithURL:retweetURL parameters:nil requestMethod:TWRequestMethodPOST];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *twitterAccountType
    = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts
    = [accountStore accountsWithAccountType:twitterAccountType];
    ACAccount *account = [twitterAccounts objectAtIndex:0];
    
    request.account = account;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData)
        {
            NSError *parseError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
            
            if (!json)
            {
                NSLog(@"Parse Error: %@", parseError);
            }
            else
            {
                NSLog(@"%@", json);
            }
        }
        else
        {
            NSLog(@"Request Error: %@", [error localizedDescription]);
        }
    }];
}

- (void)refreshOccured:(id)sender {
    
    [_refreshControl beginRefreshing];
    
    NSLog(@"更新が始まった！");
    [self getTimeline];
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
    
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}





@end

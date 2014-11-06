//
//  iphone4ViewController.m
//  iOS7Menu
//
//  Created by Ryusen Sasa on 2013/09/18.
//  Copyright (c) 2013年 monavari.de. All rights reserved.
//

#import "iphone4ViewController.h"
#import "ISMAppDelegate.h"

@interface iphone4ViewController ()

@end

@implementation iphone4ViewController : UIViewController {
    
    
    //タイムラインの最新20Tweetを保存する配列
    NSArray *tweets;
    
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
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:cellIdentifier] ;
    //カスタムセル上のラベル
    UILabel *tweetLabel = (UILabel*)[cell viewWithTag:4];
    UILabel *userLabel = (UILabel*)[cell viewWithTag:5];
    UIImageView *imgView = (UIImageView*)[cell viewWithTag: 6];
    
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
    
    UIImage *img5 = [UIImage imageNamed:@"3456_03.png"];
    UIImageView *iv5 = [[UIImageView alloc] initWithImage:img5];
    iv5.frame = CGRectMake(-15, -17, 360, 83);
    [self.view addSubview:iv5];
    
    
    UIImage *img4 = [UIImage imageNamed:@"名称未設定-1_03.png"];
    UIImageView *iv4 = [[UIImageView alloc] initWithImage:img4];
    iv4.frame = CGRectMake(205, 5, 120, 120);
    [self.view addSubview:iv4];
    
    
    
    UIImage *img3 = barArray[color];
    UIImageView *iv3 = [[UIImageView alloc] initWithImage:img3];
    iv3.frame = CGRectMake(0, 298, 200, 200);
    [self.view addSubview:iv3];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getTimeline];
    
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
    
    
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [table addSubview:_refreshControl];
    
    [_refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];
    
    
    table.delegate = self;
    table.dataSource = self;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(120, 420, 40, 40);
    [btn setTitle:@"fe" forState:UIControlStateNormal];
    // ボタンがタッチダウンされた時にhogeメソッドを呼び出す
    [btn addTarget:self action:@selector(fav:)
  forControlEvents:UIControlEventTouchDown];
    btn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:btn];
    
    
    UIButton *btn2= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    btn2.frame = CGRectMake(60, 365, 50, 50);
    [btn2 setTitle:@"re" forState:UIControlStateNormal];
    // ボタンがタッチダウンされた時にhogeメソッドを呼び出す
    [btn2 addTarget:self action:@selector(ret:)
   forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn2];
    
    UIButton *btn3= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    btn3.frame = CGRectMake(0, 310, 50, 50);
    [btn3 setTitle:@"rf" forState:UIControlStateNormal];
    // ボタンがタッチダウンされた時にhogeメソッドを呼び出す
    [btn3 addTarget:self action:@selector(ref:)
   forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn3];
    
    
    
    
    
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

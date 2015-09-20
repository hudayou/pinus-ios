//
//  Pinus.m
//  Pinus
//
//  Created by Jacky Hu on 07/14/14.
//

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "ViewController.h"

#define KBtn_width        200
#define KBtn_height       80
#define KXOffSet          (self.view.frame.size.width - KBtn_width) / 2
#define KYOffSet          80

#define kVCTitle          @"Pinus"
#define kBtnFirstTitle    @"捐一分"
#define kWaiting          @"正在获取支付凭据,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"

#define kWXAppId    @"wx8021d78ffef57529"
#define kChannel    @"upmp"
#define kAmount     @"1"
#define kUrl        @"https://pingplusplus.com:8080/example/pay.php"
#define kUser       @"4c4bbf641f9cd7d45620d1110b503acbe02c12a1cd9c7b7fb29e23b9"
#define kPassword   @"8bc523efa052bdd9a01e6bb1bff781b8820ceb95c5d9ae370858cec968c9f339"
#define kAuth       @"Basic NGM0YmJmNjQxZjljZDdkNDU2MjBkMTExMGI1MDNhY2JlMDJjMTJhMWNkOWM3YjdmYjI5ZTIzYjk6OGJjNTIzZWZhMDUyYmRkOWEwMWU2YmIxYmZmNzgxYjg4MjBjZWI5NWM1ZDlhZTM3MDg1OGNlYzk2OGM5ZjMzOQ==";

@interface ViewController ()

@end

@implementation ViewController
@synthesize channel;

- (void)dealloc
{
    self.channel = nil;

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [self titleView];
    self.title = kVCTitle;
    self.channel = kChannel;
    // Do any additional setup after loading the view, typically from a nib.

    // Add the normalTn button
    CGFloat y = KYOffSet;
    UIButton* btnStartPay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnStartPay setTitle:kBtnFirstTitle forState:UIControlStateNormal];
    [btnStartPay addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnStartPay setFrame:CGRectMake(KXOffSet, y, KBtn_width, KBtn_height)];

    [self.view addSubview:btnStartPay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertWait
{
    mAlert = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(mAlert.frame.size.width / 2.0f - 15, mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [mAlert addSubview:aiv];
    [aiv release];
    [mAlert release];
}

- (void)showAlertMessage:(NSString*)msg
{
    mAlert = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:nil cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [mAlert show];
    [mAlert release];
}

- (void)hideAlert
{
    if (mAlert != nil)
    {
        [mAlert dismissWithClickedButtonIndex:0 animated:YES];
        mAlert = nil;
    }
}

- (void)normalPayAction:(id)sender
{
    NSURL* url = [NSURL URLWithString:kUrl];
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:url];

    NSDictionary* dict = @{
        @"channel" : self.channel,
        @"amount"  : kAmount
    };
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSString *authStr = [NSString stringWithFormat:@"%@:%@", kUser, kPassword];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:0]];

    [postRequest setValue:authValue forHTTPHeaderField:@"Authorization"];

    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
    [urlConn start];
    [self showAlertWait];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    long code = [rsp statusCode];
    if (code != 200)
    {
        [self hideAlert];
        [self showAlertMessage:kErrorNet];
        [connection cancel];
        [connection release];
        connection = nil;
    }
    else
    {
        if (mData != nil)
        {
            [mData release];
            mData = nil;
        }
        mData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideAlert];
    NSString* credential = [[NSMutableString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
    NSLog(@"credential=%@", credential);
    if (credential != nil && credential.length > 0)
    {
        [Pinus createPayment:credential viewController:self appURLScheme:kWXAppId delegate:self];
    }
    [credential release];
    [connection release];
    connection = nil;

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self hideAlert];
    [self showAlertMessage:kErrorNet];
    [connection release];
    connection = nil;
}

- (void)paymentResult:(NSString *)result
{
    NSString* msg = [NSString stringWithFormat:kResult, result];
    [self showAlertMessage:msg];
}

- (UIView *)titleView
{
    CGRect frame = CGRectMake(0, 0, 200, 44);
    NSArray *items = [NSArray arrayWithObjects:@"银联", @"微信", @"支付宝", nil];
    UISegmentedControl *titleView = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
    [titleView setFrame:frame];
    titleView.segmentedControlStyle = UISegmentedControlStyleBar;
    [titleView setSelectedSegmentIndex:0];
    [titleView addTarget:self action:@selector(segmanetDidSelected:) forControlEvents:UIControlEventValueChanged];
    return titleView;
}

- (void)segmanetDidSelected:(UISegmentedControl *)segment
{
    // upmp
    if (segment.selectedSegmentIndex == 0) {
        self.channel = @"upmp";
    }

    // wechat
    if (segment.selectedSegmentIndex == 1) {
        self.channel = @"wx";
    }

    // alipay
    if (segment.selectedSegmentIndex == 2) {
        self.channel = @"alipay";
    }
}

@end

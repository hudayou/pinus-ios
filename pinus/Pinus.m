//
//  Pinus.m
//  Pinus
//
//  Created by Jacky Hu on 07/14/14.
//

#import "WXApi.h"
#import "UPPayPlugin.h"
#import "AlixLibService.h"
#import "Pinus.h"

#if __has_feature(objc_arc)
    #define PINUS_AUTORELEASE(exp) exp
    #define PINUS_RELEASE(exp) exp
    #define PINUS_RETAIN(exp) exp
#else
    #define PINUS_AUTORELEASE(exp) [exp autorelease]
    #define PINUS_RELEASE(exp) [exp release]
    #define PINUS_RETAIN(exp) [exp retain]
#endif

#define kSuccess @"success"
#define kFail    @"fail"
#define kCancel  @"cancel"
#define kInvalid @"invalid"

@interface Pinus() <WXApiDelegate, UPPayPluginDelegate, AlixPaylibDelegate>
@end

@implementation Pinus {
    @private
    // delegate
    NSObject<PinusDelegate>* _delegate;
}

+(Pinus*)sharedInstance
{
    static Pinus* _sharedInstance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _sharedInstance = [[Pinus alloc] init];
    });
    return _sharedInstance;
}

+(void)createPayment:(NSString*)credential viewController:(UIViewController*)viewController appURLScheme:(NSString*)scheme delegate:(id<PinusDelegate>)delegate
{
    Pinus* pinus = [Pinus sharedInstance];
    [pinus createPayment:credential viewController:viewController appURLScheme:scheme delegate:delegate];
}

+(void)handleOpenURL:(NSURL *)url delegate:(id<PinusDelegate>)delegate
{
    Pinus* pinus = [Pinus sharedInstance];
    [pinus handleOpenURL:url delegate:delegate];
}

-(void)createPayment:(NSString*)credential viewController:(UIViewController*)viewController appURLScheme:(NSString*)scheme delegate:(id<PinusDelegate>)delegate
{
    _delegate = delegate;
    NSData* data = [credential dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(obj && [obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = (NSDictionary*) obj;
        if(dict[@"upmp"]) {
            dict = dict[@"upmp"];
            NSString* tn = dict[@"tn"];
            NSString* mode = dict[@"mode"];
            [UPPayPlugin startPay:tn mode:mode viewController:viewController delegate:self];
        }
        else if(dict[@"wechat"]) {
            dict = dict[@"wechat"];
            NSString* appId = dict[@"appId"];
            [WXApi registerApp:appId];
            PayReq *req   = PINUS_AUTORELEASE([[PayReq alloc] init]);
            req.partnerId = dict[@"partnerId"];
            req.prepayId  = dict[@"prepayId"];
            req.package   = dict[@"packageValue"];
            req.nonceStr  = dict[@"nonceStr"];
            req.timeStamp = [dict[@"timeStamp"] longLongValue];
            req.sign      = dict[@"sign"];
            [WXApi safeSendReq:req];
        }
        else if(dict[@"alipay"]) {
            dict = dict[@"alipay"];
            NSString *orderInfo = dict[@"orderInfo"];
            SEL result = @selector(paymentResult:);
            [AlixLibService payOrder:orderInfo AndScheme:scheme seletor:result target:self];
        }
        else {
            [self done:kFail];
            return;
        }
    }
    else {
        [self done:kFail];
        return;
    }
}

-(void)handleOpenURL:(NSURL*)url delegate:(id<PinusDelegate>)delegate
{
    _delegate = delegate;
    if (url) {
        NSString* host = [url host];
        if([host isEqualToString:@"safepay"]) {
            NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            int resultStatus = [self extractResultStatusFromJson:query];
            if(resultStatus == 9000)
                [self done:kSuccess];
            else if(resultStatus == 6001)
                [self done:kCancel];
            else
                [self done:kFail];
            //alipay
        } else if([host isEqualToString:@"pay"]) {
            //wechat
            [WXApi handleOpenURL:url delegate:self];
        }
    }
}

// asynchronous result from wechat
-(void)onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        if(resp.errCode == WXSuccess)
            [self done:kSuccess];
        else if(resp.errCode == WXErrCodeUserCancel)
            [self done:kCancel];
        else
            [self done:kFail];
    }
}

-(void) onReq:(BaseReq*)req
{
}

// asynchronous result from upmp
-(void)UPPayPluginResult:(NSString*)result
{
    if(!result)
        [self done:kFail];
    else if([result caseInsensitiveCompare:kSuccess] == NSOrderedSame)
        [self done:kSuccess];
    else if([result caseInsensitiveCompare:kFail] == NSOrderedSame)
        [self done:kFail];
    else if([result caseInsensitiveCompare:kCancel] == NSOrderedSame)
        [self done:kCancel];
    else
        [self done:kFail];
}

// asynchronous result from alipay wap pay
-(void)paymentResult:(NSString*)result
{
    int resultStatus = [self extractResultStatus:result];
    if(resultStatus == 9000)
        [self done:kSuccess];
    else if(resultStatus == 6001)
        [self done:kCancel];
    else
        [self done:kFail];
}

-(int)extractResultStatusFromJson:(NSString*)result
{
    NSData* data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(obj && [obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = (NSDictionary*) obj;
        dict = dict[@"memo"];
        if (dict == nil) {
            return 0;
        }
        else {
            NSMutableString* resultStatus = dict[@"ResultStatus"];
            if(resultStatus)
                return [resultStatus intValue];
            else
                return 0;
        }
    }
    else {
        return 0;
    }
}

-(int)extractResultStatus:(NSString*)result
{
    NSString* resultString = result;
    NSMutableString* name = PINUS_AUTORELEASE([[NSMutableString alloc] init]);
    NSMutableString* resultStatus = PINUS_AUTORELEASE([[NSMutableString alloc] init]);
    NSMutableString* memo = PINUS_AUTORELEASE([[NSMutableString alloc] init]);
    NSMutableString* resultd = PINUS_AUTORELEASE([[NSMutableString alloc] init]);
    NSMutableString* temp = PINUS_AUTORELEASE([[NSMutableString alloc] init]);
    for (int i= 0; i<[resultString  length]; i++)
    {
        unichar tChar = [resultString characterAtIndex:i];
        switch (tChar)
        {
            case '=':
            {
                if (i<[resultString length]-1)
                {
                    unichar tChar2 = [resultString characterAtIndex:i+1];

                    if (tChar2 == '{')
                    {
                        [name appendString:temp];
                        [temp setString:@""];
                        i+=1;

                    }
                    else
                        [temp appendFormat:@"%C",tChar];

                }
            }
                break;
            case '}':
            {
                if (i<[resultString length]-1)
                {
                    unichar tChar2 = [resultString characterAtIndex:i+1];

                    if (tChar2 != ';')
                    {
                        [temp appendFormat:@"%C",tChar];
                        break;
                    }
                }

                i+=1;

                if ([name compare:@"resultStatus"] == 0)
                {
                    [resultStatus appendString:temp];
                }
                else if([name compare:@"memo"] == 0)
                {
                    [memo appendString:temp];
                }
                else if([name compare:@"result"] == 0)
                {
                    [resultd appendString:temp];
                }
                //save value
                [temp setString:@""];
                [name setString:@""];
            }
                break;
            default:
            {
                [temp appendFormat:@"%C",tChar];
            }
                break;
        }
    }

    return [resultStatus intValue];
}

// synchronous result from alipay for
// [AlixLibService payOrder:AndScheme:seletor:target:]
-(void)paymentResultDelegate:(NSString*)result
{
}

-(void)done:(NSString*)result
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(paymentResult:)])
        [_delegate paymentResult:result];
    _delegate = nil;
}

@end

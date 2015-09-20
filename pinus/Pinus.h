//
//  Pinus.h
//  Pinus
//
//  Created by Jacky Hu on 07/14/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PinusDelegate <NSObject>

-(void)paymentResult:(NSString *)result;

@end

@interface Pinus : NSObject

+(void)createPayment:(NSString*)credential viewController:(UIViewController*)viewController appURLScheme:(NSString*)scheme delegate:(id<PinusDelegate>)delegate;

+(void)handleOpenURL:(NSURL *)url delegate:(id<PinusDelegate>)delegate;

@end

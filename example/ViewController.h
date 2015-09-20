//
//  Pinus.m
//  Pinus
//
//  Created by Jacky Hu on 07/14/14.
//

#import <UIKit/UIKit.h>
#import "Pinus.h"

@interface ViewController : UIViewController<PinusDelegate, UIAlertViewDelegate>
{
    UIAlertView* mAlert;
    NSMutableData* mData;
}

@property(nonatomic, retain)NSString *channel;

- (void)showAlertWait;
- (void)showAlertMessage:(NSString*)msg;
- (void)hideAlert;

- (UIView *)titleView;

- (void)segmanetDidSelected:(UISegmentedControl *)segment;

@end

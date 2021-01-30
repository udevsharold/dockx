#include "common.h"
#include "UIShortTapGestureRecognizer.h"

#define UISHORT_TAP_MAX_DELAY 0.2

@implementation UIShortTapGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UISHORT_TAP_MAX_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        // Enough time has passed and the gesture was not recognized -> It has failed.
        if  (self.state != UIGestureRecognizerStateRecognized)
        {
            self.state = UIGestureRecognizerStateFailed;
        }
    });
}

@end


#import "UITableView+Toches.h"

@implementation MYTableView

// Override touchesBegan to pass event to all child subviews
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //let the tableview handle cell selection
    [super touchesBegan:touches withEvent:event];
    
    // give the controller a chance for handling touch events
    [self.nextResponder touchesBegan:touches withEvent:event];
}

@end

#import <UIKit/UIKit.h>
#import "UITableView+Toches.h"

// Forward declaration of the GameViewController - main class which
// contains basic quiz game logic
@class GameViewController;

// Game Delegate protocol contains method to notify delegate about
// button 'Share results' tap
@protocol GameViewControllerDelegate

// This method will be called when user taps on 'Share results' button where
// |passed| - number of questions totally passed
// |correctAnswers| - total number of correct answers
// |errors| - total number of incorrect answers
// |correctInSequence| - total number of correct answers passed in sequence
- (void)shareResults:(int)passed
      correctAnswers:(int)correctAnswers
              errors:(int)errors
   correctInSequence:(int)correctInSequence;

@end

// Game Data source protocol contains methods to get data to
// display for questions
@protocol GameViewControllerDataSource

// This method requests from data source for how many tasks / questions does
// data source have
// |controller| - current instance of GameViewController
// Returns integer value - number of tasks / questions
- (NSInteger)numberOfTasksForGameController:(GameViewController *)controller;

// This method requests from data source for the question by index
// |controller| - current instance of GameViewController
// |index| - index of the requested question
// Returns string representation of the question
- (NSString*)gameController:(GameViewController *)controller
       taskQuestionForIndex:(int)index;

// This method requests from data source for the correct answer by
// question index
// |controller| - current instance of GameViewController
// |index| - index of the requested question
// Returns string representation of the correct answer
- (NSString*)gameController:(GameViewController *)controller
        correctTextForIndex:(int)index;

// This method requests from data source for the incorrect (option 1) answer by
// question index
// |controller| - current instance of GameViewController
// |index| - index of the requested question
// Returns string representation of the incorrect answer
- (NSString*)gameController:(GameViewController *)controller
     incorrectText1ForIndex:(int)index;

// This method requests from data source for the incorrect (option 2) answer by
// question index
// |controller| - current instance of GameViewController
// |index| - index of the requested question
// Returns string representation of the incorrect answer
- (NSString*)gameController:(GameViewController *)controller
     incorrectText2ForIndex:(int)index;

// This method requests from data source for the incorrect (option 3) answer by
// question index
// |controller| - current instance of GameViewController
// |index| - index of the requested question
// Returns string representation of the incorrect answer
- (NSString*)gameController:(GameViewController *)controller
     incorrectText3ForIndex:(int)index;

@end

// GameViewController - main class which contains basic quiz game logic
// All data pass in and out using custom protocols
@interface GameViewController : UIViewController <UITableViewDataSource,
                                                  UITableViewDelegate>

// Data source property to set
@property (nonatomic, strong) id<GameViewControllerDataSource> dataSource;

// Delegate property to set
@property (nonatomic, strong) id<GameViewControllerDelegate> delegate;

// This method (optional) adds back button in case of UINavigationController use
- (void)addBackButton;

@end

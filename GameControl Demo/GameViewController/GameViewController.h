//
//  GameViewController.h
//  
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import <UIKit/UIKit.h>
#import "UITableView+Toches.h"

@class GameViewController;

@protocol GameViewControllerDelegate

- (void)shareResults: (int)passed correctAnswers: (int)correctAnswers errors: (int)errors correctInSequence: (int)correctInSequence;

@end

@protocol GameViewControllerDataSource

- (NSInteger) numberOfTasksForGameController:(GameViewController *)controller;
- (NSString*) gameController:(GameViewController *)controller taskQuestionForIndex:   (int)index;
- (NSString*) gameController:(GameViewController *)controller correctTextForIndex:    (int)index;
- (NSString*) gameController:(GameViewController *)controller incorrectText1ForIndex: (int)index;
- (NSString*) gameController:(GameViewController *)controller incorrectText2ForIndex: (int)index;
- (NSString*) gameController:(GameViewController *)controller incorrectText3ForIndex: (int)index;

@end


@interface GameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id<GameViewControllerDataSource> dataSource;
@property (nonatomic, strong) id<GameViewControllerDelegate> delegate;

- (void)addBackButton;

@end

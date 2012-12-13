//
//  GameViewController.m
//  
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import <AVFoundation/AVFoundation.h>

#import "GameViewController.h"
#import "FlatPillButton.h"

#define GAME_CORRECT_ANSWERS_LEVEL1 11
#define BUTTON_SIZE 250

typedef enum gameTableMode
{
    kModeInit,
    kModeStart,
    kModeGame,
    kModeScore
} gameTableMode;

@interface GameViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) gameTableMode tableMode;
@property (nonatomic, strong) NSArray *task;
@property (nonatomic) int score;
@property (nonatomic) int errors;
@property (nonatomic) int totalPassed;
@property (nonatomic) int allPassed;
@property (nonatomic) int inSequence;
@property (nonatomic) int maxInSequence;
@property (nonatomic) BOOL isTimedMode;
@property (nonatomic) BOOL isTimed;
@property (nonatomic) int seconds;
@property (nonatomic) int correctWordIndex;
@property (strong, nonatomic) NSTimer *secondsCounter;
@property (strong, nonatomic) UILabel *timeLabel;
@property (nonatomic) int numberOfTasks;
@property (nonatomic) int currentTaskIndex;

@end

@implementation GameViewController

@synthesize tableView = _tableView;
@synthesize tableMode = _tableMode;
@synthesize task = _task;
@synthesize score = _score;
@synthesize errors = _errors;
@synthesize totalPassed = _totalPassed;
@synthesize inSequence = _inSequence;
@synthesize maxInSequence = _maxInSequence;
@synthesize isTimed = _isTimed;
@synthesize allPassed = _allPassed;
@synthesize isTimedMode = _isTimedMode;
@synthesize seconds = _seconds;
@synthesize secondsCounter = _secondsCounter;
@synthesize timeLabel = _timeLabel;
@synthesize correctWordIndex = _correctWordIndex;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize numberOfTasks = _numberOfTasks;
@synthesize currentTaskIndex = _currentTaskIndex;

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
    }
    return self;
}

- (void) setTableMode:(gameTableMode)tableMode
{
    _tableMode = tableMode;    
}

- (void)startNewGame: (UIView*) button
{
    [self.secondsCounter invalidate];

    if (button != nil)
    {
        [button removeFromSuperview];
    }
    
    self.score = 0;
    self.errors = 0;
    self.totalPassed = 0;
    self.correctWordIndex = 0;
    self.inSequence = 0;
    self.seconds = 0;
    self.currentTaskIndex = 0;
    self.numberOfTasks = 0;
    
    self.tableMode = kModeGame;
    [self generateNextTask];
}

- (void)nextTaskButton: (FlatPillButton*) button
{
    if ([button.titleLabel.text isEqualToString: self.task[self.correctWordIndex]])
    {
        self.timeLabel.hidden = YES;
        self.isTimed = NO;
    }
    else
    {
        self.timeLabel.hidden = NO;
        self.isTimed = YES;
    }
        
    // Start the game
    self.tableMode = kModeGame;
    
    [self generateNextTask];
}

- (void)resetGame
{
    self.timeLabel.hidden = YES;

    self.navigationItem.title = NSLocalizedString(@"Game", nil);

    self.score = 0;
    self.errors = 0;
    self.totalPassed = 0;
    self.correctWordIndex = 0;
    self.inSequence = 0;
    self.seconds = 0;
    self.currentTaskIndex = 0;
    self.numberOfTasks = 0;
    
    self.task = @[@"", @"", @"", @"", @"", @"", @"", @""];
    [self.tableView reloadData];
    
    self.tableMode = kModeStart;
    
    self.task = @[@"", NSLocalizedString(@"Game mode:", nil), @"", NSLocalizedString(@"To one error", nil), NSLocalizedString(@"Timed", nil)];
    self.correctWordIndex = 3;
    
    [self.tableView reloadData];
}

- (void)showScore
{
    self.timeLabel.hidden = YES;
    [self.secondsCounter invalidate];
    
    self.navigationItem.title = NSLocalizedString(@"Game", nil);
    
    self.tableMode = kModeScore;
    
    if (self.isTimed)
    {
        self.task = @[NSLocalizedString(@"Total:", nil), NSLocalizedString(@"Time:", nil), NSLocalizedString(@"Errors:", nil), NSLocalizedString(@"Correct:", nil), NSLocalizedString(@"Correct in sequence:", nil), @"", NSLocalizedString(@"Play again", nil), NSLocalizedString(@"Share", nil)];

    }
    else
    {
        self.task = @[NSLocalizedString(@"Total:", nil), NSLocalizedString(@"Score:", nil), @"", @"", @"", @"", NSLocalizedString(@"Play again", nil), NSLocalizedString(@"Share", nil)];
    }
    self.correctWordIndex = 6;

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    [self.tableView reloadData];
}

- (NSString*)getNextWord
{
    NSString *word = nil;

    if (self.dataSource != nil)
    {
        word = [self.dataSource gameController: self correctTextForIndex: self.currentTaskIndex];
    }
    
    return [word lowercaseString];
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (void)generateNextTask
{    
    if (self.dataSource != nil)
    {
        self.numberOfTasks = [self.dataSource numberOfTasksForGameController: self];
    }
    else
    {
        return;
    }
    
    [self.secondsCounter invalidate];
    
    if (self.isTimed && (self.totalPassed == self.numberOfTasks))
    {
        [self showScore];
        return;
    }
        
    NSString *baseWord = nil;
    NSString *firstIncorrect = nil;
    NSString *secondIncorrect = nil;
    NSString *thirdIncorrect = nil;
    NSString *question = nil;
    
    baseWord = [self getNextWord];

    firstIncorrect = [self.dataSource gameController:self incorrectText1ForIndex:self.currentTaskIndex];
    secondIncorrect = [self.dataSource gameController:self incorrectText2ForIndex:self.currentTaskIndex];
    thirdIncorrect = [self.dataSource gameController:self incorrectText3ForIndex:self.currentTaskIndex];

    int permut = arc4random() % 4;
    question = [self.dataSource gameController:self taskQuestionForIndex:self.currentTaskIndex];
    
    switch (permut)
    {
        case 0:
            self.task = @[@"", question, @"", baseWord, firstIncorrect, secondIncorrect, thirdIncorrect];
            self.correctWordIndex = 3;
            break;
        case 1:
            self.task = @[@"", question, @"", firstIncorrect, baseWord, secondIncorrect, thirdIncorrect];
            self.correctWordIndex = 4;
            break;
        case 2:
            self.task = @[@"", question, @"", firstIncorrect, secondIncorrect, baseWord, thirdIncorrect];
            self.correctWordIndex = 5;
            break;
        case 3:
            self.task = @[@"", question, @"", firstIncorrect, secondIncorrect, thirdIncorrect, baseWord];
            self.correctWordIndex = 6;
            break;
            
        default:
            break;
    }
    
    if (self.isTimed)
    {
        self.navigationItem.title = [NSString stringWithFormat: NSLocalizedString(@"%d of %d", nil), self.totalPassed + 1, self.numberOfTasks];
    }
    else
    {
        if (self.totalPassed < GAME_CORRECT_ANSWERS_LEVEL1)
        {
            self.navigationItem.title = [NSString stringWithFormat: NSLocalizedString(@"Correct just: %d", nil), self.totalPassed];
        }
        else
        {
            self.navigationItem.title = [NSString stringWithFormat: NSLocalizedString(@"Correct already: %d", nil), self.totalPassed];
        }
    }
    [self.tableView reloadData];
    
    self.secondsCounter = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onSecondsTimer) userInfo:nil repeats:YES];
}

- (void) setSeconds:(int)seconds
{
    _seconds = seconds;
    
    int minutes = seconds / 60;
    int leftSeconds = seconds % 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d : %02d", minutes, leftSeconds];
}

- (void)onSecondsTimer
{
    self.seconds++;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.tableView = [[MYTableView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style: UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setUserInteractionEnabled:YES];
    
    [self.view addSubview:self.tableView];
        
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG.png"]];
    
    [self resetGame];
}

- (void)addBackButton
{
    UIImage *navBarImage = [UIImage imageNamed:@"ipad-menubar"];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    UIImage* buttonImage = [UIImage imageNamed:@"back"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)goBack: (UIView *) button
{
    if (button != nil)
    {
        [button removeFromSuperview];
    }
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.task.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellForGameTable";
    float xPoint = self.tableView.frame.size.width/2 - BUTTON_SIZE/2;
    
    if ((self.tableMode == kModeScore) && ((indexPath.row == 1) || (indexPath.row == 2) || (indexPath.row == 3) || (indexPath.row == 4)))
    {
        CellIdentifier = @"CellForScoreTable";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        if ([CellIdentifier isEqualToString:@"CellForGameTable"])
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    for (UIView *subButton in cell.subviews)
    {
        if ([subButton isKindOfClass:[FlatPillButton class]])
        {
            [subButton removeFromSuperview];
        }
    }
    
    switch (self.tableMode)
    {
        case kModeInit:
            cell.imageView.image = nil;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = NO;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 1;

            cell.textLabel.text = self.task [indexPath.row];

            break;
        
        case kModeStart:
            
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
            cell.textLabel.text = @"";

            if (indexPath.row == 3 || indexPath.row == 4)
            {
                // EASY and HARD
                cell.imageView.image = nil;
                cell.userInteractionEnabled = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:26.0f];

                FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                button.enabled = YES;
                
                [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
                [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                
                [button addTarget:self action:@selector(nextTaskButton:) forControlEvents: UIControlEventTouchUpInside];
                button.titleLabel.font = cell.textLabel.font;

                [cell addSubview: button];
            }
            else
            {
                cell.imageView.image = nil;
                cell.userInteractionEnabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = self.task [indexPath.row];
            }
            
            break;
            
        case kModeGame:
            
            if (self.isTimed && indexPath.row == 0 && self.timeLabel == nil)
            {
                self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 220, 10, 200, 50)];
                self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 20.0f];
                self.timeLabel.backgroundColor = [UIColor clearColor];
                self.timeLabel.textColor = [UIColor darkGrayColor];
                self.timeLabel.textAlignment = NSTextAlignmentRight;
                self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                [self.view addSubview: self.timeLabel];
            }

            if (indexPath.row == 1)
            {
                // Question cell
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 26.0f];
                cell.textLabel.numberOfLines = 2;
                cell.imageView.image = nil;
                cell.userInteractionEnabled = NO;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 24.0f];
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
                if ([self.task [indexPath.row] isEqualToString:@""])
                {
                    cell.imageView.image = nil;
                    cell.userInteractionEnabled = NO;
                }
                else
                {
                    cell.imageView.image = [UIImage imageNamed:@"point2"];
                    cell.userInteractionEnabled = YES;
                }
            }
            
            cell.textLabel.text = self.task [indexPath.row];

            break;
            
        case kModeScore:
            
            cell.imageView.image = nil;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = NO;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.text = @"";
            cell.imageView.image = nil;

            if ((indexPath.row == 0) || (indexPath.row == 6) || (indexPath.row == 7))
            {
                cell.imageView.image = nil;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text = self.task [indexPath.row];

                if (indexPath.row == 6)
                {
                    cell.textLabel.text = @"";

                    FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                    button.enabled = YES;
                    
                    [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
                    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

                    [button addTarget:self action:@selector(resetGame) forControlEvents: UIControlEventTouchUpInside];
                    [cell addSubview: button];
                    
                    cell.userInteractionEnabled = YES;
                }
                else if (indexPath.row == 7)
                {
                    cell.textLabel.text = @"";
                    
                    FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                    button.enabled = YES;
                    
                    [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
                    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    
                    [button addTarget:self action:@selector(showShareResults:) forControlEvents: UIControlEventTouchUpInside];
                    [cell addSubview: button];
                    
                    cell.userInteractionEnabled = YES;
                }
            }
            else
            {
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                cell.textLabel.text = self.task [indexPath.row];

                if (self.isTimed)
                {
                    if (indexPath.row == 1)
                    {
                        int minutes = self.seconds / 60;
                        int leftSeconds = self.seconds % 60;
                        
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d : %02d", minutes, leftSeconds];
                    }
                    else if (indexPath.row == 2)
                    {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.errors];
                    }
                    else if (indexPath.row == 3)
                    {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.score];
                    }
                    else if (indexPath.row == 4)
                    {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.maxInSequence];
                    }
                }
                else
                {
                    if (indexPath.row == 1)
                    {                    
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.totalPassed];
                    }
                    else
                    {
                        cell.detailTextLabel.text = @"";
                    }
                }
            }

            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated: YES];
    
    if (self.tableMode == kModeStart)
    {
        if (indexPath.row == self.correctWordIndex)
        {            
            // Start the game
            self.tableMode = kModeGame;
            [self generateNextTask];
        }
        else
        {
            // Quit somehow
            [self goBack: nil];
        }
    }
    else
    {
        UITableViewCell *cell = nil;
        
        for (int i=0; i<self.task.count; i++)
        {
            cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: i inSection:0]];
            cell.userInteractionEnabled = NO;

            if (cell.imageView.image != nil)
            {
                if (i == self.correctWordIndex)
                {
                    cell.imageView.image = [UIImage imageNamed:@"correct2"];
                }
                else
                {
                    cell.imageView.image = [UIImage imageNamed:@"wrong"];
                }
            }
        }

        self.currentTaskIndex++;

        if (indexPath.row == self.correctWordIndex)
        {
            self.score++;
            self.inSequence++;
            
            if (self.inSequence > self.maxInSequence)
            {
                self.maxInSequence = self.inSequence;
            }
            
            if (self.tableMode == kModeScore)
            {
                [self startNewGame: nil];
            }
        }
        else
        {
            self.inSequence = 0;
            self.errors++;
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            if (self.isTimed == NO && self.tableMode == kModeGame)
            {
                self.totalPassed++;
                [self showScore];
                return;
            }
        }
        self.totalPassed++;
        self.allPassed++;
        
        [self performSelector:@selector(generateNextTask) withObject:nil afterDelay:1];
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.tableMode == kModeScore) && (indexPath.row > 0))
    {
        if ((indexPath.row == 6) || (indexPath.row == 7))
        {
            return 60;
        }
        else
        {
            return 40;
        }
    }
    else
    {
        return 60;
    }
}

- (void)showShareResults: (UIView*) button
{
    NSLog (@"Show Share Results");
    
    if (self.delegate != nil)
    {
        [self.delegate shareResults: self.totalPassed correctAnswers: self.score errors: self.errors correctInSequence: self.maxInSequence];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

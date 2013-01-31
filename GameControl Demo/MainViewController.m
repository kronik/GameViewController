#import "MainViewController.h"
#import "GameViewController.h"
#import "FlatPillButton.h"

@interface MainViewController () <GameViewControllerDelegate, GameViewControllerDataSource>

@property (nonatomic, strong) NSArray *tasks;

@end

@implementation MainViewController

@synthesize tasks = _tasks;

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        // Create some sample tasks
        self.tasks = @[@[@"1 + 2 = ?", @"3", @"1", @"2", @"0"], @[@"2 + 2 = ?", @"4", @"1", @"2", @"5"], @[@"1 + X = ?", @"X + 1", @"X", @"Y", @"Z"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(0, 0, 240, 50)];
    button.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    button.enabled = YES;
    
    [button setTitle: NSLocalizedString(@"Play?", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(startGame) forControlEvents: UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont boldSystemFontOfSize: 24.0f];
    
    [self.view addSubview: button];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG.png"]];
    self.navigationItem.title = @"GameViewController Demo";
}

- (void) startGame
{
    GameViewController *gameController = [[GameViewController alloc] init];
    
    gameController.delegate = self;
    gameController.dataSource = self;
    
    [gameController addBackButton];
    
    [self.navigationController pushViewController: gameController animated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfTasksForGameController:(GameViewController *)controller
{
    return self.tasks.count;
}

- (NSString*) gameController:(GameViewController *)controller taskQuestionForIndex:   (int)index
{
    return self.tasks[index][0];
}

- (NSString*) gameController:(GameViewController *)controller correctTextForIndex:    (int)index
{
    return self.tasks[index][1];
}

- (NSString*) gameController:(GameViewController *)controller incorrectText1ForIndex: (int)index
{
    return self.tasks[index][2];
}

- (NSString*) gameController:(GameViewController *)controller incorrectText2ForIndex: (int)index
{
    return self.tasks[index][3];
}

- (NSString*) gameController:(GameViewController *)controller incorrectText3ForIndex: (int)index
{
    return self.tasks[index][4];
}

- (void)shareResults: (int)passed correctAnswers: (int)correctAnswers errors: (int)errors correctInSequence: (int)correctInSequence
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"You won!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end

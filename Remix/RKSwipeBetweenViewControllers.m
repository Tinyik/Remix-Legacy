//
//  RKSwipeBetweenViewControllers.m
//  RKSwipeBetweenViewControllers
//
//  Created by Richard Kim on 7/24/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for regular updates

#import "RKSwipeBetweenViewControllers.h"
#import <ChameleonFramework/Chameleon.h>
#import "Remix-Swift.h"
#import <SafariServices/SafariServices.h>
#import <MessageUI/MessageUI.h>


//%%% customizeable button attributes
CGFloat X_BUFFER = 0.0; //%%% the number of pixels on either side of the segment
CGFloat Y_BUFFER = 44.0; //%%% number of pixels on top of the segment
CGFloat HEIGHT = 30.0; //%%% height of the segment

//%%% customizeable selector bar attributes (the black bar under the buttons)
CGFloat BOUNCE_BUFFER = 10.0; //%%% adds bounce to the selection bar when you scroll
CGFloat ANIMATION_SPEED = 0.2; //%%% the number of seconds it takes to complete the animation
CGFloat SELECTOR_Y_BUFFER = 74.0; //%%% the y-value of the bar that shows what page you are on (0 is the top)
CGFloat SELECTOR_HEIGHT = 4.0; //%%% thickness of the selector bar

CGFloat X_OFFSET = 8.0; //%%% for some reason there's a little bit of a glitchy offset.  I'm going to look for a better workaround in the future


@interface RKSwipeBetweenViewControllers ()

@property (nonatomic) UIScrollView *pageScrollView;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) BOOL isPageScrollingFlag; //%%% prevents scrolling / segment tap crash
@property (nonatomic) BOOL hasAppearedFlag; //%%% prevents reloading (maintains state)
@property (nonatomic) UIColor *themeColor_1;
@end

@implementation RKSwipeBetweenViewControllers
@synthesize viewControllerArray;
@synthesize selectionBar;
@synthesize pageController;
@synthesize navigationView;
@synthesize buttonText;
@synthesize indicatorButtons;
@synthesize themeColor_1;
@synthesize cityLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    themeColor_1 = FlatBlueDark;
    [self.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationBar.barTintColor = themeColor_1; //%%% bartint
    self.navigationBar.translucent = YES;
    indicatorButtons = [NSMutableArray new];
    viewControllerArray = [[NSMutableArray alloc]init];
    self.currentPageIndex = 0;
    self.isPageScrollingFlag = NO;
    self.hasAppearedFlag = NO;
    
}


#pragma mark Customizables

//%%% color of the status bar
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
//    return UIStatusBarStyleDefault;
}

//%%% sets up the tabs using a loop.  You can take apart the loop to customize individual buttons, but remember to tag the buttons.  (button.tag=0 and the second button.tag=1, etc)
-(void)setupSegmentButtons {
    navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,self.navigationBar.frame.size.height)];
    
    NSInteger numControllers = [viewControllerArray count];
    
    if (!buttonText) {
         buttonText = [[NSArray alloc]initWithObjects: @"first",@"second",@"third",@"fourth",@"etc",@"etc",@"etc",@"etc",nil]; //%%%buttontitle
    }
    for (int i = 0; i<numControllers; i++) {
        //SET BUTTON FRAME
        CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
        if (SCREEN_WIDTH == 414) {
            X_OFFSET = 12;
        }
        
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(i*[UIScreen mainScreen].bounds.size.width/3-X_OFFSET, 44, SCREEN_WIDTH/3, HEIGHT)];
        [self.navigationView addSubview:button];
        [indicatorButtons addObject:button];
        button.hidden = NO;
        button.tag = i; //%%% IMPORTANT: if you make your own custom buttons, you have to tag them appropriately
        button.backgroundColor = themeColor_1;//%%% buttoncolors
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitle:[buttonText objectAtIndex:i] forState:UIControlStateNormal]; //%%%buttontitle
    }
    UIButton *showSettings = [[UIButton alloc] initWithFrame:CGRectMake(self.navigationBar.frame.size.width-50, 12, 25, 25)];
    [showSettings addTarget:self action:@selector(presentSettingsVCFromNaviController) forControlEvents:UIControlEventTouchUpInside];
    [showSettings setBackgroundImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
    UIImageView *barLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleLogo"]];
    barLogoView.userInteractionEnabled = YES;
    barLogoView.frame = CGRectMake(self.navigationBar.frame.size.width/2-52, 10, 70, 26);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchRemixCity)];
     UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchRemixCity)];
    [barLogoView addGestureRecognizer:tap];
    UIButton *showAdd = [[UIButton alloc] initWithFrame:CGRectMake(5, 12, 25, 25)];
    [showAdd addTarget:self action:@selector(recommendActivityAndLocation) forControlEvents:UIControlEventTouchUpInside];
    [showAdd setBackgroundImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(barLogoView.frame.origin.x + 75, barLogoView.frame.origin.y + 14, 40, 10)];
    cityLabel.text = @"全国";
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.font = [UIFont systemFontOfSize:12];
    [cityLabel addGestureRecognizer:tap2];
    cityLabel.userInteractionEnabled = YES;
    [cityLabel sizeToFit];
    [navigationView addSubview:cityLabel];
    [navigationView addSubview:barLogoView];
    [navigationView addSubview:showSettings];
    [navigationView addSubview:showAdd];
    pageController.navigationController.navigationBar.topItem.titleView = navigationView;
    
    
    [self setupSelector];
}

- (void)recommendActivityAndLocation {
   // Please refer to RMSwipeBetweenViewControllers
}

- (void)switchRemixCity{
    // Please refer to RMSwipeBetweenViewControllers
}

- (void)presentSettingsVCFromNaviController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    SettingsViewController *settingsVC = [storyboard instantiateViewControllerWithIdentifier: @"SettingsVC"];
    UINavigationController *naviController = [[RMNavigationController alloc]initWithRootViewController:settingsVC];
    [self presentViewController:naviController animated:YES completion:NULL];
}


//%%% sets up the selection bar under the buttons on the navigation bar
-(void)setupSelector {
    selectionBar = [[UIView alloc]initWithFrame:CGRectMake(X_BUFFER-X_OFFSET, SELECTOR_Y_BUFFER,(self.view.frame.size.width-2*X_BUFFER)/[viewControllerArray count], SELECTOR_HEIGHT)];
    selectionBar.backgroundColor = [UIColor flatRedColor]; //%%% sbcolor
    selectionBar.alpha = 0.8; //%%% sbalpha
    [navigationView addSubview:selectionBar];
}


//generally, this shouldn't be changed unless you know what you're changing
#pragma mark Setup

-(void)viewWillAppear:(BOOL)animated {
    if (!self.hasAppearedFlag) {
        [self setupPageViewController];
        [self setupSegmentButtons];
        self.hasAppearedFlag = YES;
    }
  
}



//%%% generic setup stuff for a pageview controller.  Sets up the scrolling style and delegate for the controller
-(void)setupPageViewController {
    pageController = (UIPageViewController*)self.topViewController;
    pageController.delegate = self;
    pageController.dataSource = self;
    [pageController setViewControllers:@[[viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self syncScrollView];
}

//%%% this allows us to get information back from the scrollview, namely the coordinate information that we can link to the selection bar.
-(void)syncScrollView {
    for (UIView* view in pageController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
        }
    }
}

//%%% methods called when you tap a button or scroll through the pages
// generally shouldn't touch this unless you know what you're doing or
// have a particular performance thing in mind

#pragma mark Movement

//%%% when you tap one of the buttons, it shows that page,
//but it also has to animate the other pages to make it feel like you're crossing a 2d expansion,
//so there's a loop that shows every view controller in the array up to the one you selected
//eg: if you're on page 1 and you click tab 3, then it shows you page 2 and then page 3
-(void)tapSegmentButtonAction:(UIButton *)button {
    
    if (!self.isPageScrollingFlag) {
        
        NSInteger tempIndex = self.currentPageIndex;
        
        __weak typeof(self) weakSelf = self;
        
        //%%% check to see if you're going left -> right or right -> left
        if (button.tag > tempIndex) {
            
            //%%% scroll through all the objects between the two points
            for (int i = (int)tempIndex+1; i<=button.tag; i++) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                    
                    //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                    //then it updates the page that it's currently on
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
        
        //%%% this is the same thing but for going right -> left
        else if (button.tag < tempIndex) {
            for (int i = (int)tempIndex-1; i >= button.tag; i--) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
    }
}

//%%% makes sure the nav bar is always aware of what page you're on
//in reference to the array of view controllers you gave
-(void)updateCurrentPageIndex:(int)newIndex {
    self.currentPageIndex = newIndex;
}

//%%% method is called when any of the pages moves.
//It extracts the xcoordinate from the center point and instructs the selection bar to move accordingly
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xFromCenter = self.view.frame.size.width-scrollView.contentOffset.x; //%%% positive for right

    NSInteger xCoor = X_BUFFER+selectionBar.frame.size.width*self.currentPageIndex-X_OFFSET;
    
    selectionBar.frame = CGRectMake(xCoor-xFromCenter/[viewControllerArray count], selectionBar.frame.origin.y, selectionBar.frame.size.width, selectionBar.frame.size.height);
}


//%%% the delegate functions for UIPageViewController.
//Pretty standard, but generally, don't touch this.
#pragma mark UIPageViewController Delegate Functions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [viewControllerArray indexOfObject:viewController];

    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [viewControllerArray indexOfObject:viewController];

    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [viewControllerArray count]) {
        return nil;
    }
    return [viewControllerArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currentPageIndex = [viewControllerArray indexOfObject:[pageViewController.viewControllers lastObject]];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = NO;
}

@end

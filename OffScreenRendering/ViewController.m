//
//  ViewController.m
//  OffScreenRendering
//
//  Created by ICBC_App_2 on 2020/12/14.
//

#import "ViewController.h"
#import "MainView.h"
#import "ViewController2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView {
    self.view = [[MainView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view.contentMode = UIViewContentModeRedraw;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchMainView)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"drawRect";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"圆角" style:UIBarButtonItemStylePlain target:self action:@selector(cornerRadiusPage)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.view.frame = UIScreen.mainScreen.bounds;
}

- (void)touchMainView {
    [self.view setNeedsDisplay];
}

- (void)cornerRadiusPage {
    ViewController2 * v2 = [[ViewController2 alloc] init];
    [self.navigationController pushViewController:v2 animated:YES];
}

@end

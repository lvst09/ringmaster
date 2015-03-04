//
//  SecondViewController.m
//  catRing
//
//  Created by sky on 15/2/17.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "SecondViewController.h"
//#import "CameraViewController.h"
#import "RosyWriterViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onVideoRecordingButtonPressed:(UIButton *)sender {
    RosyWriterViewController *cameraController = [[RosyWriterViewController alloc] init];
//    [self.navigationController pushViewController:cameraController animated:YES];
    [self presentViewController:cameraController animated:YES completion:NULL];
}
@end

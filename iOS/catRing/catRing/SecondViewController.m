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
#import "FirstViewController.h"
#import "DWUtility.h"

@interface SecondViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *movieForLocals;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SecondViewController

// ref. ThumbRetriever.m +(NSMutableArray*) GetFileList
-(void)reloadLocalData {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    BOOL only_show_video_files = [defaults boolForKey:@"only_show_video_files"];
    
    NSString *documentDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentDirectory = [paths objectAtIndex:0];
    
    NSMutableArray *tmpArrs = [NSMutableArray array];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:nil];
    
    
    NSMutableArray* acceptedFileTypes = [NSMutableArray array];
//    [acceptedFileTypes addObject:@"rmvb"];
//    [acceptedFileTypes addObject:@"mp4"];
//    [acceptedFileTypes addObject:@"wmv"];
//    [acceptedFileTypes addObject:@"flv"];
//    [acceptedFileTypes addObject:@"3gp"];
//    
//    [acceptedFileTypes addObject:@"avi"];
    [acceptedFileTypes addObject:@"mov"];
//    [acceptedFileTypes addObject:@"f4v"];
//    [acceptedFileTypes addObject:@"rm"];
//    [acceptedFileTypes addObject:@"mkv"];
    
//    [acceptedFileTypes addObject:@"vob"];
    [acceptedFileTypes addObject:@"m4v"];
//    [acceptedFileTypes addObject:@"asf"];
//    [acceptedFileTypes addObject:@"mpg"];
//    [acceptedFileTypes addObject:@"mpeg"];
//    [acceptedFileTypes addObject:@"dat"];
    
    for (NSString *filename in tmplist) {
        NSString *filenamelowercase = [filename lowercaseString];
        NSString *pathExtension = [filenamelowercase pathExtension];
        if ([acceptedFileTypes containsObject:pathExtension]) {
            [tmpArrs addObject:[documentDirectory stringByAppendingPathComponent:filename]];
        }
    }
    self.movieForLocals = tmpArrs;
//    [[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 1;
//    }
    return self.movieForLocals.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    int row = indexPath.row;
//    int section = indexPath.section;
//   
//    if (0 == section) {
//        cell.textLabel.text = @"Movie12347.m4v";
//    } else
    if (row < self.movieForLocals.count) {
        NSString *fileFullPath = [self.movieForLocals objectAtIndex:row];
        cell.textLabel.text = [fileFullPath lastPathComponent];
//        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    int section = indexPath.section;
    int row = indexPath.row;
    NSString *fullPath = nil;
//    if (0 == section) {
////        cell.textLabel.text = @"Movie12347.m4v";
//        fullPath = [[NSBundle mainBundle] pathForResource:@"Movie12347" ofType:@"m4v"];
//    } else
    if (row < self.movieForLocals.count) {
        fullPath = [self.movieForLocals objectAtIndex:row];
//        cell.textLabel.text = [fileFullPath lastPathComponent];
        //        cell.detailTextLabel.text = @"";
    }
    FirstViewController *vc = [[FirstViewController alloc] init];
    vc.videoPath = fullPath;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *addVideoButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addVideoButton addTarget:self action:@selector(onVideoRecordingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:addVideoButton];
    self.navigationItem.rightBarButtonItem = item;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 20) style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    
    NSString *fullPath = nil;
    fullPath = [[NSBundle mainBundle] pathForResource:@"Movie12347" ofType:@"m4v"];
    
    NSString *dest = [documentPath() stringByAppendingPathComponent:@"Movie12347.m4v"];
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:fullPath toPath:dest error:&error];
    NSLog(@"error=%@, from = %@, dest = %@", error, fullPath, dest);
    [self reloadLocalData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadLocalData];
    [self.tableView reloadData];
}

- (IBAction)onVideoRecordingButtonPressed:(UIButton *)sender {
    RosyWriterViewController *cameraController = [[RosyWriterViewController alloc] init];
//    [self.navigationController pushViewController:cameraController animated:YES];
    [self presentViewController:cameraController animated:YES completion:NULL];
}
@end

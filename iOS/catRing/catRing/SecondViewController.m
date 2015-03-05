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

@interface SecondViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *movieForLocals;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SecondViewController

// ref. ThumbRetriever.m +(NSMutableArray*) GetFileList
-(void)reloadLocalData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL only_show_video_files = [defaults boolForKey:@"only_show_video_files"];
    
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
//        if (only_show_video_files) {
            //        NSString *fullpath = [[WMCDirectoryManager getDocumentPath] stringByAppendingPathComponent:filename];
            NSString *filenamelowercase = [filename lowercaseString];
            NSString *pathExtension = [filenamelowercase pathExtension];
            if ([acceptedFileTypes containsObject:pathExtension]) {
                [tmpArrs addObject:[documentDirectory stringByAppendingPathComponent:filename]];
            }
            //        if ( ([pathExtension isEqualToString:@"wmv"]) || ([pathExtension isEqualToString:@"mp4"]) || ([pathExtension isEqualToString:@"avi"])  || ([pathExtension isEqualToString:@"mov"]) || ([pathExtension isEqualToString:@"rmvb"]) || ([pathExtension isEqualToString:@"mkv"])) {
            //            [tmpArrs addObject:[[WMCDirectoryManager getDocumentPath] stringByAppendingPathComponent:filename]];
            //        }
//        } else {
//            [tmpArrs addObject:[documentDirectory stringByAppendingPathComponent:filename]];
//        }
    }
    self.movieForLocals = tmpArrs;
    [[self tableView] reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    int section = indexPath.section;
   
    if (row<self.movieForLocals.count) {
        NSString *fileFullPath = [self.movieForLocals objectAtIndex:row];
        cell.textLabel.text = [fileFullPath lastPathComponent];
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView registerClass:<#(__unsafe_unretained Class)#> forCellReuseIdentifier:<#(NSString *)#>
    [self.view addSubview:self.tableView];
    [self reloadLocalData];
    [self.tableView reloadData];
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

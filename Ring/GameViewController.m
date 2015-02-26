//
//  GameViewController.m
//  Ring
//
//  Created by sky on 15/2/8.
//  Copyright (c) 2015年 NoName. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"4.dae"];

    scene.background.contents = nil;
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    SCNCamera *cam = cameraNode.camera;
    cam.xFov = 0;
    cam.yFov = 45;
    cam.zFar = 0.51650673151016235;
    cam.zNear = 0.0020660269074141979;
    cam.aperture = 0.125;
    cam.focalDistance = 10;
//    cameraNode.position = SCNVector3Make(0.0, 0.006, 0.0);
    cameraNode.position = SCNVector3Make(0.0, 0.011091, 0.030776*3);
    NSLog(@"camera=%@", scene.rootNode.camera);
    [scene.rootNode addChildNode:cameraNode];
//
//    // place the camera
    
//    (0.000000 0.011091 0.030776)
//    <SCNView: 0x7b844a30 | scene=<SCNScene: 0x7b848400> sceneTime=0.000000 frame={{0, 0}, {320, 480}} pointOfView=<SCNNode: 0x7b848c20 pos(0.000000 0.011091 0.030776) | camera=<SCNCamera: 0x7b8490a0> | no child>>
//    <SCNView: 0x14564e10 | scene=<SCNScene: 0x1455d3d0> sceneTime=0.000000 frame={{0, 0}, {320, 568}} pointOfView=<SCNNode: 0x14659f40 'kSCNFreeViewCameraName' pos(0.000835 0.063774 -0.000784) rot(-0.999907 0.013367 -0.002859 1.625832) scale(1.000000 1.000000 1.000000) | camera=<SCNCamera: 0x14659a70 'kSCNFreeViewCameraNameCamera'> | no child>>
//    // create and add a light to the scene
//    SCNNode *lightNode = [SCNNode node];
//    lightNode.light = [SCNLight light];
//    lightNode.light.type = SCNLightTypeOmni;
//    lightNode.position = SCNVector3Make(0, 10, 10);
//    [scene.rootNode addChildNode:lightNode];
//    
//    // create and add an ambient light to the scene
//    SCNNode *ambientLightNode = [SCNNode node];
//    ambientLightNode.light = [SCNLight light];
//    ambientLightNode.light.type = SCNLightTypeAmbient;
//    ambientLightNode.light.color = [UIColor darkGrayColor];
//    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
//    SCNNode *ship = [scene.rootNode childNodeWithName:@"Yellow_gold_18K" recursively:YES];
//    ship.camera = [SCNCamera camera];
//    [ship addChildNode:cameraNode];
    
    
    // animate the 3d object
//    [ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    scnView.backgroundColor = [UIColor redColor];
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor clearColor];
    
//    scene.rootNode.position = SCNVector3Make(0, 0, -0.09);
    scene.rootNode.position = SCNVector3Make(0, 0, 0);
    SCNVector3 eulerAngles = scene.rootNode.eulerAngles;
    NSLog(@"original eulerangles, x=%f, y=%f, z=%f", eulerAngles.x, eulerAngles.y, eulerAngles.z);
//    scene.rootNode.eulerAngles = SCNVector3Make(eulerAngles.x+0.89*M_PI_2, eulerAngles.y+0.*M_PI_4, eulerAngles.z+0.*M_PI_4);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SCNVector3 v1 = SCNVector3Make(0, 0, 0);
        SCNVector3 v2 = SCNVector3Make(0, 0, 0);
        
        BOOL ret = [scene.rootNode getBoundingBoxMin:&v1 max:&v2];
//        v1 = SCNVector3Make((v1.x+v2.x)/2.f, (v1.y+v2.y)/2.f, (v1.z+v2.z)/2.f);
        NSLog(@"v1, x=%f, y=%f, z=%f", v1.x, v1.y, v1.z);
        NSLog(@"v2, x=%f, y=%f, z=%f", v2.x, v2.y, v2.z);
//        NSLog(@"1ret=%d, v1=%@, v2=%@", ret, v1, v2);
        SCNVector3 view1 = [scnView projectPoint:v1];
        SCNVector3 view2 = [scnView projectPoint:v2];
        NSLog(@"view1, x=%f, y=%f, z=%f", view1.x, view1.y, view1.z);
        NSLog(@"view2, x=%f, y=%f, z=%f", view2.x, view2.y, view2.z);
        
        view1 = [scnView unprojectPoint:v1];
        view2 = [scnView unprojectPoint:v2];
        NSLog(@"view1, x=%f, y=%f, z=%f", view1.x, view1.y, view1.z);
        NSLog(@"view2, x=%f, y=%f, z=%f", view2.x, view2.y, view2.z);
        
        [scnView convertPoint:CGPointZero fromCoordinateSpace:nil];
    });

//    scene.rootNode.scale = SCNVector3Make(0.5, 0.5, 0.5);
    
    scnView.pointOfView = nil;
//    scnView.pointOfView.rotation = SCNVector4Make(0, 0, 0, M_PI_4);
//    scnView.pointOfView.rotation = SCNVector4Make(1,1,1,M_PI_2);
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
    
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * (11+1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SCNView *view = (SCNView *)self.view;
        NSLog(@"self.view=%@, camera=%@", self.view, view.scene.rootNode.camera);
        
        for (SCNNode *node in view.scene.rootNode.childNodes) {
            NSLog(@"node=%@, camera=%@", node, node.camera);
        }
        
    });
    for (int i = 0; i <= 10; i ++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * (i+1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            
            [self rotateX:0 Y:0.f z:i / 10.f];
            
        });
    }
}

- (void)rotateX:(CGFloat)x Y:(CGFloat)y z:(CGFloat)z {
    SCNView *scnView = (SCNView *)self.view;
//    scnView.scene.rootNode
//    SCNVector3 eulerAngles = .rootNode.eulerAngles;
    scnView.scene.rootNode.eulerAngles = SCNVector3Make((0.89+x)*M_PI_2, y*M_PI_2, z*M_PI_2);
//    [SCNTransaction commit];
//    [scnView setNeedsDisplay];
//    scnView.playing = YES;
//    sleep(1);
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *filename = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ANG_x%f_y%f_z%f.JPG", x, y, z]];
        [self saveAsPNGForView:scnView filename:filename];
//    });
}

- (void)saveAsPNGForView:(SCNView *)scnView filename:(NSString *)filename
{
    NSLog(@"get image=%@", filename);
    UIImage *image = [scnView snapshot];
    NSData *pngData = UIImagePNGRepresentation(image);
    
    [pngData writeToFile:filename atomically:YES];
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
//    BOOL ret = [scene.rootNode getBoundingBoxMin:v1 max:v2];
//    NSLog(@"ret=%d, v1=%@, v2=%@", ret, v1, v2);
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        {
            SCNVector3 v1 = SCNVector3Make(0, 0, 0);
            SCNVector3 v2 = SCNVector3Make(0, 0, 0);
            
            BOOL ret = [result.node getBoundingBoxMin:&v1 max:&v2];
            //        v1 = SCNVector3Make((v1.x+v2.x)/2.f, (v1.y+v2.y)/2.f, (v1.z+v2.z)/2.f);
            NSLog(@"getBoundingBoxMin:v1, x=%f, y=%f, z=%f", v1.x, v1.y, v1.z);
            NSLog(@"getBoundingBoxMin:v2, x=%f, y=%f, z=%f", v2.x, v2.y, v2.z);
            //        NSLog(@"1ret=%d, v1=%@, v2=%@", ret, v1, v2);
            SCNVector3 view1 = [scnView projectPoint:v1];
            SCNVector3 view2 = [scnView projectPoint:v2];
            NSLog(@"getBoundingBoxMin:view1, x=%f, y=%f, z=%f", view1.x, view1.y, view1.z);
            NSLog(@"getBoundingBoxMin:view2, x=%f, y=%f, z=%f", view2.x, view2.y, view2.z);
            
//            view1 = [scnView unprojectPoint:v1];
//            view2 = [scnView unprojectPoint:v2];
//            NSLog(@"view1, x=%f, y=%f, z=%f", view1.x, view1.y, view1.z);
//            NSLog(@"view2, x=%f, y=%f, z=%f", view2.x, view2.y, view2.z);
            
            [scnView convertPoint:CGPointZero fromCoordinateSpace:nil];
        }
        
        SCNVector3 v1 = result.node.position;
        SCNVector3 v2 = result.worldCoordinates;
        NSLog(@"v1, x=%f, y=%f, z=%f", v1.x, v1.y, v1.z);
        NSLog(@"v2, x=%f, y=%f, z=%f", v2.x, v2.y, v2.z);
        SCNVector3 view1 = [scnView projectPoint:v1];
        NSLog(@"view1xm, x=%f, y=%f, z=%f", view1.x, view1.y, view1.z);
        SCNVector3 view2 = [scnView projectPoint:v2];
        NSLog(@"view2xm, x=%f, y=%f, z=%f", view2.x, view2.y, view2.z);
        
        result.node.rotation = SCNVector4Make(0, 0, 1, 0);
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
    NSString *filename = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ANG%ld.JPG", (long)1]];
    
    
    [self saveAsPNGForView:scnView filename:filename];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end

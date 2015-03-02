//
//  DWRotationManager.m
//  catRing
//
//  Created by sky on 15/3/1.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "DWRotationManager.h"

//#import "CC3Environment.h"

@implementation DWRotationManager

- (NSMutableArray *)input {
    if (!_input) {
        _input = [[NSMutableArray alloc] initWithCapacity:128];
    }
    return _input;
}

- (void)pushAngleX:(CGFloat)angleX angleY:(CGFloat)angleY angleZ:(CGFloat)angleZ {
    GLKVector3 rotation = GLKVector3Make(angleX, angleY, angleZ);// cc3v(60, 30, 0);
    NSValue *value = [NSValue valueWithBytes:&rotation objCType:@encode(GLKVector3)];
    [self.input addObject:value];
}


- (void)getOutput:(completeBlk)blk {
    // 先调用cocos3d的vc，然后生成图片，最后dismiss
/*
    NSDictionary *config = @{
                             CCSetupDepthFormat: @GL_DEPTH_COMPONENT16,				// Change to @GL_DEPTH24_STENCIL8 if using shadow volumes, which require a stencil buffer
                             CCSetupShowDebugStats: @(YES),							// Show the FPS and draw call label.
                             CCSetupAnimationInterval: @(1.0 / 60),	// Framerate (defaults to 60 FPS).
                             CCSetupScreenOrientation: CCScreenOrientationAll,		// Support all device orientations dyanamically
                             //	   CCSetupMultiSampling: @(YES),							// Use multisampling on the main view
                             //	   CCSetupNumberOfSamples: @(4),							// Number of samples to use per pixel (max 4)
                             };
    {
        // Create the main window
        UIWindow *window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        
        // CCGLView creation
        // viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
        //  - Possible values: any CGRect
        // pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
        //	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
        // depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
        //  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
        // sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
        //  - Possible values: nil, or any valid EAGLSharegroup group
        // multiSampling: Whether or not to enable multisampling
        //  - Possible values: YES, NO
        // numberOfSamples: Only valid if multisampling is enabled
        //  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
        CCGLView *glView = [CCGLView
                            viewWithFrame:[window_ bounds]
                            pixelFormat:config[CCSetupPixelFormat] ?: kEAGLColorFormatRGBA8
                            depthFormat:[config[CCSetupDepthFormat] unsignedIntValue]
                            preserveBackbuffer:[config[CCSetupPreserveBackbuffer] boolValue]
                            sharegroup:nil
                            multiSampling:[config[CCSetupMultiSampling] boolValue]
                            numberOfSamples:[config[CCSetupNumberOfSamples] unsignedIntValue]
                            ];
        
        CCDirectorIOS* director = (CCDirectorIOS*) [CCDirector sharedDirector];
        
        director.wantsFullScreenLayout = YES;
        
        //#if DEBUG
        // Display FSP and SPF
        [director setDisplayStats:[config[CCSetupShowDebugStats] boolValue]];
        //#endif
        
        // set FPS at 60
        NSTimeInterval animationInterval = [(config[CCSetupAnimationInterval] ?: @(1.0/60.0)) doubleValue];
        [director setAnimationInterval:animationInterval];
        
        director.fixedUpdateInterval = [(config[CCSetupFixedUpdateInterval] ?: @(1.0/60.0)) doubleValue];
        
        // attach the openglView to the director
        [director setView:glView];
        
        if([config[CCSetupScreenMode] isEqual:CCScreenModeFixed]){
            CGSize size = [CCDirector sharedDirector].viewSizeInPixels;
            CGSize fixed = {568, 384};
            
            if([config[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait]){
                CC_SWAP(fixed.width, fixed.height);
            }
            
            // Find the minimal power-of-two scale that covers both the width and height.
            CGFloat scaleFactor = MIN(FindPOTScale(size.width, fixed.width), FindPOTScale(size.height, fixed.height));
            
            director.contentScaleFactor = scaleFactor;
            director.UIScaleFactor = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1.0 : 0.5);
            
            // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
            [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor: 2.0];
            
            director.designSize = fixed;
            [director setProjection:CCDirectorProjectionCustom];
        } else {
            // Setup tablet scaling if it was requested.
            if(
               UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
               [config[CCSetupTabletScale2X] boolValue]
               ){
                // Set the director to use 2 points per pixel.
                director.contentScaleFactor *= 2.0;
                
                // Set the UI scale factor to show things at "native" size.
                director.UIScaleFactor = 0.5;
                
                // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
                [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
            }
            
            [director setProjection:CCDirectorProjection2D];
        }
        
        // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
        // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
        // You can change this setting at any time.
        [CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
        
        // Initialise OpenAL
        [OALSimpleAudio sharedInstance];
        
        // Create a Navigation Controller with the Director
        CCNavigationController *navController_ = [[CCNavigationController alloc] initWithRootViewController:director];
        navController_.navigationBarHidden = YES;
//        navController_.appDelegate = self;
//        navController_.screenOrientation = (config[CCSetupScreenOrientation] ?: CCScreenOrientationLandscape);
        
        // for rotation and other messages
        [director setDelegate:navController_];
        
//        // set the Navigation Controller as the root view controller
//        [window_ setRootViewController:navController_];
//        
//        // make main window visible
//        [window_ makeKeyAndVisible];
    }
   */
}
@end

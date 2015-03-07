/**
 *  catRingScene.m
 *  catRing
 *
 *  Created by sky on 15/3/1.
 *  Copyright DW 2015年. All rights reserved.
 */

#import "catRingScene.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3UtilityMeshNodes.h"


// for snapshot
#import "CCDirector.h"

// for output center point
#import "DWRingPositionInfo.h"
#import "DWRotationManager.h"

@interface catRingScene()

@property (nonatomic, strong) CC3ResourceNode* rezNode;

@property (nonatomic, assign) CC3Vector aRotation;

@property (nonatomic, strong) NSMutableDictionary *filenamePositionInfoDic;

@end

@implementation catRingScene

/**
 * Constructs the 3D scene prior to the scene being displayed.
 *
 * Adds 3D objects to the scene, loading a 3D 'hello, world' message
 * from a POD file, and creating the camera and light programatically.
 *
 * When adapting this template to your application, remove all of the content
 * of this method, and add your own to construct your 3D model scene.
 *
 * You can also load scene content asynchronously while the scene is being displayed by
 * loading on a background thread. You can add code that loads content to the 
 * addSceneContentAsynchronously method, and it will automatically be loaded immediately
 * after the scene is opened, and smoothly inserted into the scene, as the existing scene
 * content is being displayed.
 *
 * NOTES:
 *
 * 1) To help you find your scene content once it is loaded, the onOpen method below contains
 *    code to automatically move the camera so that it frames the scene. You can remove that
 *    code once you know where you want to place your camera.
 *
 * 2) The POD file used for the 'hello, world' message model is fairly large, because converting a
 *    font to a mesh results in a LOT of triangles. When adapting this template project for your own
 *    application, REMOVE the POD file 'hello-world.pod' from the Resources folder of your project.
 */
-(void) initializeScene {

	// Optionally add a static solid-color, or textured, backdrop, by uncommenting one of these lines.
//	self.backdrop = [CC3Backdrop nodeWithColor: ccc4f(0.4, 0.5, 0.9, 1.0)];
//	self.backdrop = [CC3Backdrop nodeWithTexture: [CC3Texture textureFromFile: @"Default.png"]];

	// Create the camera, place it back a bit, and add it to the scene
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.0, 18.0 );
    cam.nearClippingDistance = 0.1;
	[self addChild: cam];

	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the scene
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -2.0, 2.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];
	
	// Create and load a POD resource file and add its entire contents to the scene.
	// If needed, prior to adding the loaded content to the scene, you can customize the
	// nodes in the resource, remove unwanted nodes from the resource (eg- extra cameras),
	// or extract only specific nodes from the resource to add them directly to the scene,
	// instead of adding the entire contents.
	CC3ResourceNode* rezNode = [CC3PODResourceNode nodeFromFile: @"ringModel.pod"];
	[self addChild: rezNode];
	
	// Or, if you don't need to modify the resource node at all before adding its content,
	// you can simply use the following as a shortcut, instead of the previous lines.
//	[self addContentFromPODFile: @"hello-world.pod"];
	
	// In some cases, PODs are created with opacity turned off by mistake. To avoid the possible
	// surprise of an empty scene, the following line ensures that all nodes loaded so far will
	// be visible. However, it also removes any translucency or transparency from the nodes, which
	// may not be what you want. If your model contains transparency or translucency, remove this line.
	self.opacity = kCCOpacityFull;
	
	// Select the appropriate shaders for each mesh node in this scene now. If this step is
	// omitted, a shaders will be selected for each mesh node the first time that mesh node is
	// drawn. Doing it now adds some additional time up front, but avoids potential pauses as
	// the shaders are loaded, compiled, and linked, the first time it is needed during drawing.
	// This is not so important for content loaded in this initializeScene method, but it is
	// very important for content loaded in the addSceneContentAsynchronously method.
	// Shader selection is driven by the characteristics of each mesh node and its material,
	// including the number of textures, whether alpha testing is used, etc. To have the
	// correct shaders selected, it is important that you finish configuring the mesh nodes
	// prior to invoking this method. If you change any of these characteristics that affect
	// the shader selection, you can invoke the removeShaders method to cause different shaders
	// to be selected, based on the new mesh node and material characteristics.
	[self selectShaders];

	// With complex scenes, the drawing of objects that are not within view of the camera will
	// consume GPU resources unnecessarily, and potentially degrading app performance. We can
	// avoid drawing objects that are not within view of the camera by assigning a bounding
	// volume to each mesh node. Once assigned, the bounding volume is automatically checked
	// to see if it intersects the camera's frustum before the mesh node is drawn. If the node's
	// bounding volume intersects the camera frustum, the node will be drawn. If the bounding
	// volume does not intersect the camera's frustum, the node will not be visible to the camera,
	// and the node will not be drawn. Bounding volumes can also be used for collision detection
	// between nodes. You can create bounding volumes automatically for most rigid (non-skinned)
	// objects by using the createBoundingVolumes on a node. This will create bounding volumes
	// for all decendant rigid mesh nodes of that node. Invoking the method on your scene will
	// create bounding volumes for all rigid mesh nodes in the scene. Bounding volumes are not
	// automatically created for skinned meshes that modify vertices using bones. Because the
	// vertices can be moved arbitrarily by the bones, you must create and assign bounding
	// volumes to skinned mesh nodes yourself, by determining the extent of the bounding
	// volume you need, and creating a bounding volume that matches it. Finally, checking
	// bounding volumes involves a small computation cost. For objects that you know will be
	// in front of the camera at all times, you can skip creating a bounding volume for that
	// node, letting it be drawn on each frame. Since the automatic creation of bounding
	// volumes depends on having the vertex location content in memory, be sure to invoke
	// this method before invoking the releaseRedundantContent method.
	[self createBoundingVolumes];
	
	// Create OpenGL buffers for the vertex arrays to keep things fast and efficient, and to
	// save memory, release the vertex content in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantContent];

	
	// ------------------------------------------
	
	// That's it! The scene is now constructed and is good to go.
	
	// To help you find your scene content once it is loaded, the onOpen method below contains
	// code to automatically move the camera so that it frames the scene. You can remove that
	// code once you know where you want to place your camera.
	
	// If you encounter problems displaying your models, you can uncomment one or more of the
	// following lines to help you troubleshoot. You can also use these features on a single node,
	// or a structure of nodes. See the CC3Node notes for more explanation of these properties.
	// Also, the onOpen method below contains additional troubleshooting code you can comment
	// out to move the camera so that it will display the entire scene automatically.
	
	// Displays short descriptive text for each node (including class, node name & tag).
	// The text is displayed centered on the pivot point (origin) of the node.
//	self.shouldDrawAllDescriptors = YES;
	
	// Displays bounding boxes around those nodes with local content (eg- meshes).
	self.shouldDrawAllLocalContentWireframeBoxes = YES;
	
	// Displays bounding boxes around all nodes. The bounding box for each node
	// will encompass its child nodes.
//	self.shouldDrawAllWireframeBoxes = YES;
	
	// If you encounter issues creating and adding nodes, or loading models from
	// files, the following line is used to log the full structure of the scene.
	LogInfo(@"The structure of this scene is: %@", [self structureDescription]);
	
	// ------------------------------------------

	// And to add some dynamism, we'll animate the 'hello, world' message
	// using a couple of actions...
	
	// Fetch the 'hello, world' object that was loaded from the POD file and start it rotating
    //	CC3MeshNode* helloTxt = (CC3MeshNode*)[self getNodeNamed: @"Yellow_gold_18K"];
    CGFloat scale1 = 1;
    NSLog(@"1rezNode x=%f, y=%f, z=%f", rezNode.location.x, rezNode.location.y, rezNode.location.z);
    [rezNode runAction: [CC3ActionScaleTo actionWithDuration:0 scaleTo: cc3v(scale1, scale1 , scale1)]];// actionWithRotationRate: cc3v(0, 0, 30)]];
    //	[rezNode runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(30, 0, 0)]];
    NSLog(@"2rezNode x=%f, y=%f, z=%f", rezNode.location.x, rezNode.location.y, rezNode.location.z);
    CC3Vector aRotation = cc3v(90, 0, 0);
    self.aRotation = aRotation;
    [rezNode runAction:[CC3ActionRotateTo actionWithDuration:0 rotateTo:aRotation]];
    NSLog(@"3rezNode x=%f, y=%f, z=%f", rezNode.location.x, rezNode.location.y, rezNode.location.z);
    
    NSMutableArray *arr = [NSMutableArray array];
    NSInteger count = 0;
//    for (int i = 0; i < count; ++i) {
//        GLKVector3 rotation = GLKVector3Make(10 * i, 0, 0);// cc3v(60, 30, 0);
//        NSValue *value = [NSValue valueWithGLKVector3:rotation];
//        [arr addObject:value];
//    }
    arr = [[DWRotationManager sharedManager] input];
    count = arr.count;
    for (int i = 0; i < count; ++i) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 + 2 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSValue *value = arr[i];
            GLKVector3 storedVector;
            [value getValue:&storedVector];
            CC3Vector aRotation = cc3v(storedVector.x, storedVector.y, storedVector.z);
            self.aRotation = aRotation;
            NSLog(@"aRotation x=%f, y=%f, z=%f", aRotation.x, aRotation.y, aRotation.z);
            [rezNode runAction:[CC3ActionRotateTo actionWithDuration:0 rotateTo:aRotation]];
            NSLog(@"3rezNode x=%f, y=%f, z=%f", rezNode.location.x, rezNode.location.y, rezNode.location.z);
        });
    }
    // To make things a bit more appealing, set up a repeating up/down cycle to
    // change the color of the text from the original red to blue, and back again.
    //	GLfloat tintTime = 8.0f;
    //	CCColorRef startColor = helloTxt.color;
    //	CCColorRef endColor = CCColorRefFromCCC4F(ccc4f(0.2, 0.0, 0.8, 1.0));
    //	CCActionInterval* tintDown = [CCActionTintTo actionWithDuration: tintTime color: endColor];
    //	CCActionInterval* tintUp   = [CCActionTintTo actionWithDuration: tintTime color: startColor];
    //	[helloTxt runAction: [[CCActionSequence actionOne: tintDown two: tintUp] repeatForever]];
    
    // And let's make this interactive, by allowing the hello text to be touched.
    // When the node is touched, it will be passed to the nodeSelected:byTouchEvent:at: method below.
    //	helloTxt.touchEnabled = YES;
    
    self.color = CCColorRefFromCCC4F(ccc4f(1, 0, 1, 1.f));
    
    // 遮盖住cocos生成图片的过程
#if 0
    UIView *view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    view.backgroundColor = [UIColor redColor];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
#endif
}

/**
 * By populating this method, you can add add additional scene content dynamically and
 * asynchronously after the scene is open.
 *
 * This method is invoked from a code block defined in the onOpen method, that is run on a
 * background thread by the CC3Backgrounder available through the backgrounder property.
 * It adds content dynamically and asynchronously while rendering is running on the main
 * rendering thread.
 *
 * You can add content on the background thread at any time while your scene is running, by
 * defining a code block and running it on the backgrounder. The example provided in the
 * onOpen method is a template for how to do this, but it does not need to be invoked only
 * from the onOpen method.
 *
 * Certain assets, notably shader programs, will cause short, but unavoidable, delays in the
 * rendering of the scene, because certain finalization steps from shader compilation occur on
 * the main thread when the shader is first used. Shaders and certain other critical assets can
 * be pre-loaded and cached in the initializeScene method, prior to the opening of this scene.
 */
-(void) addSceneContentAsynchronously {}


#pragma mark Updating custom activity

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities before
 * any changes are applied to the transformMatrix of the 3D nodes in the scene.
 *
 * For more info, read the notes of this method on CC3Node.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities after
 * the transformMatrix of the 3D nodes in the scen have been recalculated.
 *
 * For more info, read the notes of this method on CC3Node.
 */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
    NSLog(@"updateAfterTransform");
    [self snapshot];
}


#pragma mark Scene opening and closing

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene is first displayed.
 *
 * This method is a good place to invoke one of CC3Camera moveToShowAllOf:... family
 * of methods, used to cause the camera to automatically focus on and frame a particular
 * node, or the entire scene.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onOpen {

	// Add additional scene content dynamically and asynchronously, on a background thread
	// after rendering has begun on the rendering thread, using the CC3Backgrounder singleton.
	// Asynchronous loading must be initiated after the scene has been attached to the view.
	// It cannot be started in the initializeScene method. However, it does not need to be
	// invoked only from the onOpen method. You can use the code in the line here as a template
	// for use whenever your app requires background content loading after the scene has opened.
	[CC3Backgrounder.sharedBackgrounder runBlock: ^{ [self addSceneContentAsynchronously]; }];

	// Move the camera to frame the scene. The resulting configuration of the camera is output as
	// an [info] log message, so you know where the camera needs to be in order to view your scene.
	[self.activeCamera moveWithDuration: 0.f toShowAllOf: self withPadding: 3.f];

	// Uncomment this line to draw the bounding box of the scene.
//	self.shouldDrawWireframeBox = YES;
}

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene has been removed from display.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onClose {}


#pragma mark Drawing

/**
 * Template method that draws the content of the scene.
 *
 * This method is invoked automatically by the drawScene method, once the 3D environment has
 * been established. Once this method is complete, the 2D rendering environment will be
 * re-established automatically, and any 2D billboard overlays will be rendered. This method
 * does not need to take care of any of this set-up and tear-down.
 *
 * This implementation simply invokes the default parent behaviour, which turns on the lighting
 * contained within the scene, and performs a single rendering pass of the nodes in the scene 
 * by invoking the visit: method on the specified visitor, with this scene as the argument.
 * Review the source code of the CC3Scene drawSceneContentWithVisitor: to understand the
 * implementation details, and as a starting point for customization.
 *
 * You can override this method to customize the scene rendering flow, such as performing
 * multiple rendering passes on different surfaces, or adding post-processing effects, using
 * the template methods mentioned above.
 *
 * Rendering output is directed to the render surface held in the renderSurface property of
 * the visitor. By default, that is set to the render surface held in the viewSurface property
 * of this scene. If you override this method, you can set the renderSurface property of the
 * visitor to another surface, and then invoke this superclass implementation, to render this
 * scene to a texture for later processing.
 *
 * When overriding the drawSceneContentWithVisitor: method with your own specialized rendering,
 * steps, be careful to avoid recursive loops when rendering to textures and environment maps.
 * For example, you might typically override drawSceneContentWithVisitor: to include steps to
 * render environment maps for reflections, etc. In that case, you should also override the
 * drawSceneContentForEnvironmentMapWithVisitor: to render the scene without those additional
 * steps, to avoid the inadvertenly invoking an infinite recursive rendering of a scene to a
 * texture while the scene is already being rendered to that texture.
 *
 * To maintain performance, by default, the depth buffer of the surface is not specifically
 * cleared when 3D drawing begins. If this scene is drawing to a surface that already has
 * depth information rendered, you can override this method and clear the depth buffer before
 * continuing with 3D drawing, by invoking clearDepthContent on the renderSurface of the visitor,
 * and then invoking this superclass implementation, or continuing with your own drawing logic.
 *
 * Examples of when the depth buffer should be cleared are when this scene is being drawn
 * on top of other 3D content (as in a sub-window), or when any 2D content that is rendered
 * behind the scene makes use of depth drawing. See also the closeDepthTestWithVisitor:
 * method for more info about managing the depth buffer.
 */
-(void) drawSceneContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super drawSceneContentWithVisitor: visitor];
}


#pragma mark Handling touch events 

/**
 * This method is invoked from the CC3Layer whenever a touch event occurs, if that layer
 * has indicated that it is interested in user interaction.
 *
 * This default implementation simply delegates to the superclass behaviour, which selects a 3D node
 * on each touch-down event. You can modify this method to perform more sophisticated touch handling.
 *
 * This method is not invoked when gestures are used for user interaction. When gestures are used,
 * your custom CC3Layer should process them and invoke higher-level application-defined behaviour
 * on this customized CC3Scene subclass.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
	[super touchEvent: touchType at: touchPoint];
}

/**
 * This callback template method is invoked automatically when a node has been picked
 * by the invocation of the pickNodeFromTapAt: or pickNodeFromTouchEvent:at: methods,
 * as a result of a touch event or tap gesture.
 *
 * Modify this method to perform activities on 3D nodes that have been selected by the user.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
	
	// Provide some user feedback by "pulsing" the touched node. We do this by temporarily making
	// it grow larger and then shrink down again. Because the user might touch the node again while
	// it is in the middle of a pulse, we stop the previous pulse action before creating a new one.
	// At this point the hello text node has several actions running on it simultaneously. We can
	// locate the pulse action we want to stop by giving it a unique tag when it is added to the node.
	
	NSInteger pulseActionTag = 19;				// Can be any integer that will be unique among actions on this node.
	[aNode stopActionByTag: pulseActionTag];	// Remove any existing pulse action first.
	
	// Now, create a new pulse action and run it with the same tag so we can find it later if we want to stop it.
	CCActionInterval* grow = [CC3ActionScaleTo actionWithDuration: 0.25 scaleUniformlyTo: 1.1];
	CCActionInterval* shrink = [CC3ActionScaleTo actionWithDuration: 0.25 scaleUniformlyTo: 1.0];
	CCAction* pulse = [CCActionSequence actionOne: grow two: shrink];
	[aNode runAction: pulse withTag: pulseActionTag];
}


#pragma mark -
#pragma mark misc

- (NSMutableDictionary *)filenamePositionInfoDic {
    if (!_filenamePositionInfoDic) {
        _filenamePositionInfoDic = [[NSMutableDictionary alloc] initWithCapacity:128];
    }
    return _filenamePositionInfoDic;
}

- (void)snapshot {
    CGSize s = [[CCDirector sharedDirector] viewSizeInPixels];
//    CCRenderTexture *texture = [CCRenderTexture renderTextureWithWidth:s.width height:s.height];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CCRenderTexture *texture = [CCRenderTexture renderTextureWithWidth:screenSize.width height:screenSize.height];
    [texture begin];
    [[[CCDirector sharedDirector] runningScene] visit];
    [texture end];
    
    NSString *filename = [NSString stringWithFormat:@"MYIMG_ANG_x%d_y%d_z%d.png", (int)self.aRotation.x, (int)self.aRotation.y, (int)self.aRotation.z];
    UIImage *image = [texture getUIImage];
    NSLog(@"image=%@", image);
    CGPoint pt = self.projectedPosition;
    NSLog(@"pt=%@", [NSValue valueWithCGPoint:pt]);
    
    if ([texture saveToFile:filename format:CCRenderTextureImageFormatPNG]) {
        NSLog(@"succ, filename=%@", filename);
    } else {
        NSLog(@"failed, filename=%@", filename);
    }
    
    [self.activeCamera projectNode:self];
    NSLog(@"node x=%f, y=%f", self.projectedPosition.x, self.projectedPosition.y);
    DWRingPositionInfo *posInfo = [[DWRingPositionInfo alloc] init];
    posInfo.centerPoint = CGPointMake(self.projectedPosition.x, self.projectedPosition.y);
    
    CC3Vector minimum;
    CC3Vector maximum;
    minimum = self.boundingBox.minimum;
    maximum = self.boundingBox.maximum;
    CC3Vector m1 = [self.activeCamera projectLocation:minimum];
    CC3Vector m2 = [self.activeCamera projectLocation:maximum];
    NSLog(@"m1 node x=%f, y=%f", m1.x, m1.y);
    NSLog(@"m2 node x=%f, y=%f", m2.x, m2.y);
    posInfo.minPoint = CGPointMake(m1.x, m1.y);
    posInfo.maxPoint = CGPointMake(m2.x, m2.y);
    [self.filenamePositionInfoDic setObject:posInfo forKey:filename];
    [DWRotationManager sharedManager].output = self.filenamePositionInfoDic;
    
    NSLog(@"key:%@, value:%@", filename, posInfo);
}

@end


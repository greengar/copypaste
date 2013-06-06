#HOW TO BUILD WHITEBOARD FRAMEWORK
1. Select `BuildWhiteboardSDK` Scheme
2. Press `Command` + `B` to build the project
3. Open Finder, go to WhiteboardSDK/Products/
4. Drag `Whiteboard.framework` into your project
5. Open Finder, go to `WhiteboardSDK/Products/Whiteboard.framework/Resources/`
6. Drag `Whiteboard.bundle` to your project
7. Add `OpenGLES.framework` and `QuartzCore.framework` to your project
8. Go to your project Build Settings, add an Other Linker Flags: `-lstdc++`
9. Use the framework:

** Import the framework
```Objective-C
#import <Whiteboard/Whiteboard.h>
```

** Use the protocol

```Objective-C
YourViewController <WBSessionDelegate>
```

** Call the endpoint to show the view controller

```Objective-C
[[WBSession activeSession] presentSmartboardControllerFromController:/* your view controller */
                                                           withImage:/* your image to edit */
                                                            delegate:/* callback */];
```

** Implement the protocol callback to get the output

```Objective-C
- (void)doneEditingPhotoWithResult:(UIImage *)image {
    // You have the UIImage here 
}
```

#HOW TO RUN AND DEVELOP WHITEBOARD CODE

1. Select `WhiteboardSDK` Scheme
2. Press `Command` + `R` to run the project

#CREDIT
[GreenGar](www.greengar.com)

#DEVELOPMENT
[Hector Zhao](https://github.com/longtrieu)
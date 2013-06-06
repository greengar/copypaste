HOW TO BUILD AND USE SMARTBOARD DRAWING SDK

1. Select BuildSmartDrawingSDK Scheme
2. Press "Command+B" to build the project
3. In Finder, navigate to SmartDrawing SDK/Products/
4. Drag the SmartDrawing.framework into your project
5. In Finder, open SmartDrawing SDK/Products/SmartDrawing.framework/Resources/
6. Drag the SmartDrawing.bundle to your project
7. Add OpenGLES.framework and QuartzCore.framework to your project (if you don't already have them)
8. Go to your project Build Settings, add an Other Linker Flags: -lstdc++
9. \#import <SmartDrawing/SmartDrawing.h> to use
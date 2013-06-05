HOW TO BUILD AND USE WHITEBOARD SDK
=================================================

1. Select BuildWhiteboardSDK Scheme
2. Press "Command+B" to build the project
3. Open Finder, go to WhiteboardSDK/Products/
4. Drag Whiteboard.framework into your project
5. Open Finder, go to WhiteboardSDK/Products/Whiteboard.framework/Resources/
6. Drag Whiteboard.bundle to your project
7. Add OpenGLES.framework and QuartzCore.framework to your project
8. Go to your project Build Settings, add an Other Linker Flags: -lstdc++
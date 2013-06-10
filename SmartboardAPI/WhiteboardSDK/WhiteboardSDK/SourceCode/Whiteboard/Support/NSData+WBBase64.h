//
//  NSData+WBBase64.h
//

#import <Foundation/Foundation.h>

void *WBNewBase64Decode(
                        const char *inputBuffer,
                        size_t length,
                        size_t *outputLength);

char *WBNewBase64Encode(
                        const void *inputBuffer,
                        size_t length,
                        bool separateLines,
                        size_t *outputLength);

@interface NSData (WBBase64)

+ (NSData *)wbDataFromBase64String:(NSString *)aString;
- (NSString *)wbBase64EncodedString;

@end
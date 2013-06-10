//
//  NSData+GSBase64.h
//

#import <Foundation/Foundation.h>

void *GSNewBase64Decode(
                        const char *inputBuffer,
                        size_t length,
                        size_t *outputLength);

char *GSNewBase64Encode(
                        const void *inputBuffer,
                        size_t length,
                        bool separateLines,
                        size_t *outputLength);

@interface NSData (GSBase64)

+ (NSData *)gsDataFromBase64String:(NSString *)aString;
- (NSString *)gsBase64EncodedString;

@end

#import "B9Debug.h"

#if DEBUG
void ThrowExceptionToPause(void) {
    @try {
        @throw [NSException exceptionWithName:@"Debugger" reason:nil userInfo:nil];
    }
    @catch (NSException *exception) { }
}
#endif

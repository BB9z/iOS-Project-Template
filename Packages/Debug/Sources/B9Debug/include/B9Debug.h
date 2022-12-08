/*
 B9Debug

 Copyright © 2022 BB9z.
 https://github.com/b9swift/B9Debug

 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <Foundation/Foundation.h>

/**
 抛出一个 objc 异常以暂停，用以在调试时提示需要注意的事

 仅在 DEBUG 环境可用，开启 Objective-C 异常断点后可断住

 Throw an objc exception to pause to indicate things for attention while debugging.

 Only available in DEBUG configuration. Active when the Objective-C exception breakpoint is turned on.
 */
#if DEBUG
FOUNDATION_EXPORT void ThrowExceptionToPause(void);
#else
NS_INLINE void ThrowExceptionToPause(void) {
    // Do nothing
};
#endif

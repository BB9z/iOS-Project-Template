
#import "ShortCuts.h"
#import "Common.h"

NavigationController *__nullable AppNavigationController(void) {
    return [MBApp status].globalNavigationController;
}

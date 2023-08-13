/*
 MBNavigationController ReleaseChecking
 MBDebug
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBNavigationController.h"

#if RFDEBUG

@interface MBNavigationController (MBDebugReleaseChecking)
@end

#endif

@protocol MBDebugNavigationReleaseChecking
@optional
- (BOOL)debugShouldIgnoralCheckReleaseForViewController:(UIViewController *)viewController;
@end


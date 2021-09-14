/*
 CALayer+MBAnimationPersistence
 
 基于 Matej Bukovinski 在 https://gist.github.com/matej/9639064 发布的基础上
 
 Copyright (c) 2014 Matej Bukovinski

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <QuartzCore/QuartzCore.h>

// @MBDependency:2
/**
 CALayer 的动画在 view 移出 window 和应用进入后台都会被移除，
 这个扩展可以在应用进入后台后自动恢复动画，切换界面导致的动画移除需要手动调用 MBResumePersistentAnimationsIfNeeded
 
 在恢复前，需要调用 MBPersistCurrentAnimations 或指定 MBPersistentAnimationKeys 决定哪些动画需要恢复
 
 @code
 
 - (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];

     // 恢复动画
     [self.animateView.layer MBResumePersistentAnimationsIfNeeded];

     // 为便于演示，添加动画也放在这
     if (!self.animationAdded) {

         self.animationAdded = YES;

         // 一个 UIView 动画
         self.animateView.y = -100;
         [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
             self.animateView.y = 100;
         } completion:nil];
         // 标记当前动画需要恢复
         [sl.layer MBPersistCurrentAnimations];
     }
 }

 @endcode
 */
@interface CALayer (MBAnimationPersistence)

/**
 Animation keys for animations that should be persisted.
 Inspect the `animationKeys` array to find valid keys for your layer.
 
 `CAAnimation` instances associated with the provided keys will be copied and held onto,
 when the applications enters background mode and restored when exiting background mode.
 
 Set to `nil`to disable persistence.
 */
@property (nonatomic, nullable) NSArray<NSString *> *MBPersistentAnimationKeys;

/**
 Set all current `animationKeys` as persistent.
 */
- (void)MBPersistCurrentAnimations;

/**
 Resume any persistent animation which currently not attached to the layer.
 */
- (void)MBResumePersistentAnimationsIfNeeded;

@end

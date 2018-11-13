/*
 MBCellStackView
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <MBAppKit/MBAppKit.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:1
/**
 复用填充一组 view
 
 在 Swift 中需要用 typealias 声明一下，直接带 generic type IB 的表现会异常
 */
@interface MBCellStackView<ViewType, ObjectType> : UIStackView <
    RFInitializing
>

@property (nullable, nonatomic) NSArray<ObjectType> *items;
@property (nullable) UINib *cellNib;

/// 设置后即清空，仅用于更新 cellNib
@property (nullable) IBInspectable NSString *cellNibName;

@property (nullable, nonatomic) void (^configureCell)(MBCellStackView *__nonnull stackView, ViewType __nonnull cell, NSInteger index, ObjectType __nonnull item);

@end

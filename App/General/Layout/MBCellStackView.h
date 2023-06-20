/*
 MBCellStackView
 
 Copyright © 2018-2019 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
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

/// 如未设置，尝试在 cell 上执行 setItem:
@property (nullable, nonatomic) void (^configureCell)(MBCellStackView *__nonnull stackView, ViewType __nonnull cell, NSInteger index, ObjectType __nonnull item);

@end

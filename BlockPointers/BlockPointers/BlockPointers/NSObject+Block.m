//
//  NSObject+Block.m
//  BlockPointers
//
//  Created by imac on 2018/1/11.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

#import "NSObject+Block.h"
#import <objc/runtime.h>

static Class _BPBlockRootClass() {
    static dispatch_once_t onecToken;
    static Class block_class = nil;
    dispatch_once(&onecToken, ^{
        void(^temp_blck)(void) = ^{};
        block_class = object_getClass((id)temp_blck);
        while (class_getSuperclass(block_class) && class_getSuperclass(block_class) != [NSObject class]) {
            block_class = class_getSuperclass(block_class);
        }
    });
    return block_class;
}

@implementation NSObject (Block)

- (BOOL)isBlock {
    return [object_getClass(self) isSubclassOfClass:_BPBlockRootClass()];
}

- (struct _block_literal *)blockify {
    if ([self isBlock]) {
        return (__bridge struct _block_literal *)self;
    }
    return NULL;
}

@end

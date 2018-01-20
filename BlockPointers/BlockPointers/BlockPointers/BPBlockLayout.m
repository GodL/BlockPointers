//
//  BPBlockLayout.m
//  BlockPointers
//
//  Created by imac on 2018/1/11.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

#import "BPBlockLayout.h"
#import <objc/runtime.h>
#import "NSObject+Block.h"

/**
 Using clever trickery from Circle:
 https://github.com/mikeash/Circle/blob/master/Circle/CircleIVarLayout.m
 */
struct _block_byref_block;
@interface _BPBlockReleaseDetector : NSObject {
    // __block fakery
    void *forwarding;
    int flags;   //refcount;
    int size;
    void (*byref_keep)(struct _block_byref_block *dst, struct _block_byref_block *src);
    void (*byref_dispose)(struct _block_byref_block *);
    void *captured[16];
}

@property (nonatomic,assign,getter=isStrong) BOOL strong;

+ (void *)make;

@end


static void byref_keep_nop(struct _block_byref_block *dst, struct _block_byref_block *src) {}
static void byref_dispose_nop(struct _block_byref_block *param) {}

@implementation _BPBlockReleaseDetector

+ (void)initialize {
    Method release_method = class_getInstanceMethod(self, @selector(new_release));
    class_addMethod(self, sel_getUid("release"), method_getImplementation(release_method), method_getTypeEncoding(release_method));
}

+ (void *)make {
    void *obj = calloc(class_getInstanceSize(self), 1);
    __unsafe_unretained _BPBlockReleaseDetector *detector = (__bridge __unsafe_unretained id)obj;
    object_setClass(detector, self);
    detector->forwarding = obj;
    detector->byref_keep = byref_keep_nop;
    detector->byref_dispose = byref_dispose_nop;
    return obj;
}

- (void)new_release {
    _strong = YES;
}

@end


NSIndexSet *BlockAllReferenceLayout(id obj) {
    struct _block_literal * block = [obj blockify];
    if (block == NULL) {
        return nil;
    }
    if ((block->flags & BLOCK_HAS_CTOR)
        || !(block->flags & BLOCK_HAS_COPY_DISPOSE)) {
        return nil;
    }
    struct _block_descriptor *descriptor = block->descriptor;
    void (*dispose_helper)(void *src) = descriptor->dispose_helper;
    const size_t ptrSize = sizeof(void *);
    const size_t elements = (descriptor->size + ptrSize - 1) / ptrSize;
    void *objs[elements];
    void *detectors[elements];
    for (size_t i = 0; i < elements; i++) {
        objs[i] = detectors[i] = [_BPBlockReleaseDetector make];
    }
    
    @autoreleasepool {
        dispose_helper(objs);
    }
    
    NSMutableIndexSet *layout = [NSMutableIndexSet indexSet];
    for (size_t i = 0; i < elements; i++) {
         __unsafe_unretained _BPBlockReleaseDetector *detector = (__bridge __unsafe_unretained id)detectors[i];
        if (detector.isStrong) {
            [layout addIndex:i];
        }
        free(detectors[i]);
    }
    return layout;
}

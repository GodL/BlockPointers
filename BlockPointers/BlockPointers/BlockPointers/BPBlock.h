//
//  BPBlock.h
//  BlockPointers
//
//  Created by imac on 2018/1/11.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Block structure:
 See  http://clang.llvm.org/docs/Block-ABI-Apple.html
 */

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

struct _block_descriptor {
    unsigned long int reserved;
    unsigned long int size;
    //optional help functions
    void (*copy_helper)(void *dst, void *src); // IFF (1<<25)
    void (*dispose_helper)(void *src);         // IFF (1<<25)
    const char *signature;                     // IFF (1<<30)
};

struct _block_literal {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *,...);
    struct _block_descriptor *descriptor;
    // imported variables
};


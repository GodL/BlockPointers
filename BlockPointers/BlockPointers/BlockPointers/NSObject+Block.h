//
//  NSObject+Block.h
//  BlockPointers
//
//  Created by imac on 2018/1/11.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPBlock.h"

@interface NSObject (Block)

- (BOOL)isBlock;

- (struct _block_literal *)blockify;

@end

/*
 * Copyright (c) 2018 - present Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
#import <Foundation/NSObject.h>

@class RCBlock;

typedef void (^MyHandler)(RCBlock* name);

@interface RCBlock : NSObject {
  RCBlock* child;
}

@property(nonatomic, strong) MyHandler handler;

@property(nonatomic, strong) RCBlock* child;

@end

@implementation RCBlock

// This code can be executed and one can check that there's a cycle because
// "Dealloc" is not being printed.
- (void)dealloc {
  NSLog(@"Dealloc");
}

- (void)retain_self_in_block {
  self.handler = ^(RCBlock* b) {
    self->_child = b;
  };
}

- (void)retain_weak_self_in_block {
  __weak typeof(self) weak_self = self;
  self.handler = ^(RCBlock* b) {
    __strong typeof(self) strong_self = weak_self;
    if (strong_self)
      strong_self->_child = b;
  };
}

@end

int call_retain_self_in_block_cycle() {
  RCBlock* c = [[RCBlock alloc] init];
  [c retain_self_in_block];
  return 0;
}

int call_retain_weak_self_in_block_no_cycle() {
  RCBlock* c = [[RCBlock alloc] init];
  [c retain_weak_self_in_block];
  return 0;
}

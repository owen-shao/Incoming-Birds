//
//  Bird.m
//  MyGame
//
//  Created by Shao on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bird.h"

@implementation Bird



- (void)didLoadFromCCB {
    self.pooped = FALSE;
    self.physicsBody.collisionType = @"bird";
}

@end

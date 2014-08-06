//
//  Projectile.m
//  MyGame
//
//  Created by Shao on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"projectile";
}

@end

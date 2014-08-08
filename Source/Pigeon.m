//
//  Pigeon.m
//  MyGame
//
//  Created by Shao on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Pigeon.h"

@implementation Pigeon

- (id)init
{
    self = [super init];
    self.health = 2;
    self.afterDeathCCBName = @"Deadpigeon";
    self.swallowLifeCounter = 0;
    self.pigeonLifeCounter = 1;
    self.ravenLifeCounter = 0;
    
    return self;
}

@end

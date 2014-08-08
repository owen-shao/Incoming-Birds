//
//  Raven.m
//  MyGame
//
//  Created by Shao on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Raven.h"

@implementation Raven

- (id)init
{
    self = [super init];
    self.health = 4;
    self.afterDeathCCBName = @"Deadraven";
    self.swallowLifeCounter = 0;
    self.pigeonLifeCounter = 0;
    self.ravenLifeCounter = 1;
    
    return self;
}

@end

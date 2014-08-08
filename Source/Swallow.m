//
//  Swallow.m
//  MyGame
//
//  Created by Shao on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Swallow.h"

@implementation Swallow

- (id)init
{
    self = [super init];
    self.health = 1;
    self.afterDeathCCBName = @"Deadswallow";
    self.swallowLifeCounter = 1;
    self.pigeonLifeCounter = 0;
    self.ravenLifeCounter = 0;
    
    return self;
}



@end

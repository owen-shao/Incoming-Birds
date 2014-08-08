//
//  Bird.h
//  MyGame
//
//  Created by Shao on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Bird : CCSprite

@property (nonatomic, assign) BOOL pooped;
@property (nonatomic, assign) int health;
@property (nonatomic, assign) NSString* afterDeathCCBName;
@property (nonatomic, assign) int swallowLifeCounter;
@property (nonatomic, assign) int pigeonLifeCounter;
@property (nonatomic, assign) int ravenLifeCounter;

@end

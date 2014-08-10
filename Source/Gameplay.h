//
//  Gameplay.h
//  MyGame
//
//  Created by Shao on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate>

@property (nonatomic, assign) NSString* currentWeapon;
@property (nonatomic, assign) int weaponIndex;


@end

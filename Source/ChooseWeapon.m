//
//  ChooseWeapon.m
//  MyGame
//
//  Created by Shao on 8/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ChooseWeapon.h"
#import "Gameplay.h"

@implementation ChooseWeapon

- (void) pistol {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *scene = (Gameplay *)gameplayScene.children.firstObject;
    scene.currentWeapon = @"Pistol";
    scene.weaponIndex = 1;
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) shotgun {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *scene = (Gameplay *)gameplayScene.children.firstObject;
    scene.currentWeapon = @"Shotgun";
    scene.weaponIndex = 2;
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) micromachine {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *scene = (Gameplay *)gameplayScene.children.firstObject;
    scene.currentWeapon = @"Micromachine";
    scene.weaponIndex = 3;
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) sniperrifle {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *scene = (Gameplay *)gameplayScene.children.firstObject;
    scene.currentWeapon = @"Sniperrifle";
    scene.weaponIndex = 4;
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) cabin {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *scene = (Gameplay *)gameplayScene.children.firstObject;
    scene.currentWeapon = @"Cabin";
    scene.weaponIndex = 5;
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) machinegun {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *scene = (Gameplay *)gameplayScene.children.firstObject;
    scene.currentWeapon = @"Machinegun";
    scene.weaponIndex = 6;
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


@end

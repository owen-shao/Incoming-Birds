//
//  Recap.m
//  MyGame
//
//  Created by Shao on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Recap.h"

@implementation Recap {
    CCLabelTTF *_swallowNumber;
    CCLabelTTF *_pigeonNumber;
    CCLabelTTF *_ravenNumber;
    CCLabelTTF *_totalNumber;
    
}

- (void)onEnter{
    [super onEnter];
    _swallowNumber.string = [NSString stringWithFormat:@"%d", self.swallowKilled];
    _pigeonNumber.string = [NSString stringWithFormat:@"%d", self.pigeonKilled];
    _ravenNumber.string = [NSString stringWithFormat:@"%d", self.ravenKilled];
    _totalNumber.string = [NSString stringWithFormat:@"%d", (self.swallowKilled + self.pigeonKilled + self.ravenKilled )];
    
}

- (void)restart {
    CCScene *chooseWeaponScene = [CCBReader loadAsScene:@"ChooseWeapon"];
    [[CCDirector sharedDirector] replaceScene:chooseWeaponScene];
}

@end

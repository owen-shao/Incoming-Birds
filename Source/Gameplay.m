//
//  Gameplay.m
//  MyGame
//
//  Created by Shao on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <math.h>
#import "Gameplay.h"
#import "Bird.h"
#import "Projectile.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#define M_PI        3.14159265358979323846264338327950288
static const int TOTAL_LIVES = 10;
int remaining_Lives;

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_ccNode;
    CCNode *_car;
    CCLabelTTF *_health;
}


// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    // tell this scene to accept touches
    _car.physicsBody.collisionType = @"car";
    _car.physicsBody.sensor = TRUE;
    remaining_Lives = TOTAL_LIVES;
    _health.string = [NSString stringWithFormat:@"%d", remaining_Lives];
    
    self.userInteractionEnabled = TRUE;
    [self schedule:@selector(oneBirdAppears) interval:2.0f];
    
}

// called on every touch in this scene
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_ccNode];
    CCLOG(@"%@", NSStringFromCGPoint(touchLocation));
    [self launchProjectile: touchLocation];
    
}

- (void)launchProjectile: (CGPoint )touchLocation {
    double launchAngel, rotationAngel;
    if (touchLocation.x == self.boundingBox.size.width/2){
        launchAngel = M_PI/2;
        rotationAngel = 0;
    }
    else if(touchLocation.x < self.boundingBox.size.width/2) {
        launchAngel = atan(touchLocation.y/(self.boundingBox.size.width/2 - touchLocation.x));
        rotationAngel = launchAngel*180/M_PI - 90;
    }
    else {
        launchAngel = atan(touchLocation.y/(touchLocation.x - self.boundingBox.size.width/2));
        rotationAngel = 90 - launchAngel*180/M_PI;
    }
    // loads the Penguin.ccb we have set up in Spritebuilder
    CCNode* projectile = [CCBReader load:@"Projectile"];
    // position the penguin at the bowl of the catapult
    projectile.position = ccp(self.boundingBox.size.width/2, 0);
    projectile.rotation = rotationAngel;
    
    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:projectile];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection;
    if (touchLocation.x < self.boundingBox.size.width/2) {
        launchDirection.x = -cos(launchAngel);
        launchDirection.y = sin(launchAngel) ;
    }
    else {
        launchDirection.x = cos(launchAngel);
        launchDirection.y = sin(launchAngel) ;
    }
    CGPoint force = ccpMult(launchDirection, 600);
    CCLOG(@"%@", NSStringFromCGPoint(force));
    
    [projectile.physicsBody applyImpulse:force];
}

- (void)update:(CCTime)delta
{
    for (id object in _physicsNode.children){
        if ([object isKindOfClass:[Projectile class]]){
            Projectile *j = object;
            if ((j.position.x < 0) || (j.position.x > self.boundingBox.size.width) || (j.position.y > self.boundingBox.size.height)){
                [[_physicsNode space] addPostStepBlock:^{
                    [self oneObjectRemoved:j];
                } key:j];
            }
        }
        else if ([object isKindOfClass:[Bird class]]) {
            Bird *i = object;
            if (i.position.y < self.boundingBox.size.height/2){
                if (i.pooped == FALSE) {
                  CCNode* poopinfly = [CCBReader load:@"Poopinfly"];
                  poopinfly.physicsBody.sensor = TRUE;
                  poopinfly.position = i.position;
                
                
                  [[_physicsNode space] addPostStepBlock:^{
                      [_physicsNode addChild:poopinfly];
                  } key:poopinfly];
                    i.pooped = TRUE;
                }
                CCLOG(@"y speed :%f", i.physicsBody.velocity.y);
                if (i.physicsBody.velocity.y < 0 ){
                    i.position = ccp(i.position.x ,self.boundingBox.size.height/2);
                    i.rotation = 180 - i.rotation;
                    [i.physicsBody applyForce:ccp(0,6000)];
                }
            }
            if  (i.position.y > self.boundingBox.size.height){
                [[_physicsNode space] addPostStepBlock:^{
                    [self oneObjectRemoved:i];
                } key:i];
            }
            if ( i.position.x < 10) {
                i.position = ccp(10 ,i.position.y);
                i.rotation = -i.rotation;
                [i.physicsBody applyForce:ccp(-i.physicsBody.velocity.x*200 ,0)];
            }
            if (i.position.x > self.boundingBox.size.width - 10 ) {
                i.position = ccp(self.boundingBox.size.width - 10 ,i.position.y);
                i.rotation = -i.rotation;
                [i.physicsBody applyForce:ccp(-i.physicsBody.velocity.x*200 ,0)];
            }
        }else{
            CCNode *k = object;
            if (k.position.y < 0){
                [[_physicsNode space] addPostStepBlock:^{
                    [self oneObjectRemoved:k];
                } key:k];
            }
            
        }
    }
}



- (void)oneBirdAppears {
    double r1 = arc4random() % 100;
    double r2 = arc4random() % 100;
    double r3 = arc4random() % 100;
    double x;
    double birdAngel;
    if (r3 > 50) { x = 1;}else{ x = -1;}
    birdAngel = - (atan(x * (1500 + 15 * r2)/3000))*180/M_PI;
    CCLOG(@"angel %f", birdAngel);
    CCNode* bird = [CCBReader load:@"Bird"];
    bird.physicsBody.sensor = TRUE;
    bird.position = ccp( (20 + r1*(self.boundingBox.size.width - 20)/100) ,self.boundingBox.size.height - 10);
    bird.rotation = birdAngel;
    [_physicsNode addChild:bird];
    CGPoint flydirection = ccp( x * (1500 + 15 * r2), -3000);
    [bird.physicsBody applyForce:flydirection];
    
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bird:(CCNode *)nodeA projectile:(CCNode *)nodeB {
    [[_physicsNode space] addPostStepBlock:^{
    [self oneObjectRemoved:nodeA];
    } key:nodeA];
    [[_physicsNode space] addPostStepBlock:^{
    [self oneObjectRemoved:nodeB];
    } key:nodeB];
    
    CCParticleSystem *blood = (CCParticleSystem *)[CCBReader load:@"Swallowshot"];
    blood.autoRemoveOnFinish = TRUE;
    blood.position = nodeA.position;
    [_physicsNode addChild:blood];
    
    CCNode* deadswallow = [CCBReader load:@"Deadswallow"];
    deadswallow.physicsBody.sensor = TRUE;
    deadswallow.position = nodeA.position;
    
    [[_physicsNode space] addPostStepBlock:^{
        [_physicsNode addChild:deadswallow];
    } key:deadswallow];
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair poopinfly:(CCNode *)nodeA car:(CCNode *)nodeB {
    [[_physicsNode space] addPostStepBlock:^{
        [self oneObjectRemoved:nodeA];
    } key:nodeA];
    CCNode* pooponcar = [CCBReader load:@"Pooponcar"];
    pooponcar.position = nodeA.position;
    [_ccNode addChild:(pooponcar)];
    remaining_Lives --;
    _health.string = [NSString stringWithFormat:@"%d", remaining_Lives];
    if (remaining_Lives == 0) {
        CCScene *recapScene = [CCBReader loadAsScene:@"Recap"];
        [[CCDirector sharedDirector] replaceScene:recapScene];
    }
    return TRUE;
}

- (void)oneObjectRemoved:(CCNode *)object {
    [object removeFromParent];
}


@end

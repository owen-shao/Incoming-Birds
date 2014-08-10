//
//  Gameplay.m
//  MyGame
//
//  Created by Shao on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <math.h>
#import "Gameplay.h"
#import "Recap.h"
#import "Bird.h"
#import "Projectile.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#define M_PI        3.14159265358979323846264338327950288
static const int TOTAL_LIVES = 10;
static const double SHOTGUN_BULLET_ANGLE_DIFFERENCE = 6;
static const double SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC = (SHOTGUN_BULLET_ANGLE_DIFFERENCE * M_PI)/180;
static const double BULLET_SPEED = 350;
int remaining_Lives;
int swallowKilledNumber , pigeonKilledNumber, ravenKilledNumber;
CCNode* weaponPNG , *reload;
CGPoint touchLocation;
int remainingAmmo, ammoCapacity;
int bulletDamage;
BOOL shotIntervalPassed ;
BOOL bulletPenetration;
float shotInterval ;
CCTime swallowInterval, pigeonInterval, ravenInterval;
NSUInteger swallowAppearNumber, pigeonAppearNumber, ravenAppearNumber;



@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_ccNode;
    CCNode *_car;
    CCLabelTTF *_health;
    CCLabelTTF *_magReading;
    CCNode *_reloadAlert;
    CCButton *_reloadButton;
}


// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    // tell this scene to accept touches
    _car.physicsBody.collisionType = @"car";
    _car.physicsBody.sensor = TRUE;
    shotIntervalPassed = TRUE;
    remaining_Lives = TOTAL_LIVES;
    _health.string = [NSString stringWithFormat:@"%d", remaining_Lives];
    swallowKilledNumber = pigeonKilledNumber = ravenKilledNumber = 0 ;
    
    [self schedule:@selector(oneSwallowAppears) interval:3.0f repeat:3 delay:0];
    [self schedule:@selector(onePigeonAppears) interval:4.0f repeat:1 delay:12];
    [self schedule:@selector(oneRavenAppears) interval:5.0f repeat:1 delay:20];
    [self scheduleOnce:@selector(startRealGame) delay:35];
    self.userInteractionEnabled = TRUE;
    
    swallowInterval = 8;
    swallowAppearNumber = 4;
    pigeonInterval = 10;
    pigeonAppearNumber = 2;
    ravenInterval = 15;
    ravenAppearNumber = 1;
    
    _reloadButton.enabled = YES;
    
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"gunshotsound"];
}

- (void)onEnter{
    [super onEnter];
    _reloadAlert.visible = FALSE;
    CCNode* weapon = [CCBReader load:self.currentWeapon];
    weaponPNG = weapon;
    weapon.position = ccp( self.boundingBox.size.width /2 ,0);
    [_ccNode addChild:weapon];
    switch (self.weaponIndex) {
        case 1:
            ammoCapacity = 12;
            remainingAmmo = ammoCapacity;
            [self sychronizeAmmo];
            shotInterval = 0.5;
            bulletDamage = 1;
            bulletPenetration = FALSE;
            break;
            
        case 2:
            ammoCapacity = 7;
            remainingAmmo = ammoCapacity;
            [self sychronizeAmmo];
            shotInterval = 0.5;
            bulletDamage = 1;
            bulletPenetration = FALSE;
            break;
            
        case 3:
            ammoCapacity = 30;
            remainingAmmo = ammoCapacity;
            [self sychronizeAmmo];
            shotInterval = 0.1;
            bulletDamage = 1;
            bulletPenetration = FALSE;
            break;
            
        case 4:
            ammoCapacity = 10;
            remainingAmmo = ammoCapacity;
            [self sychronizeAmmo];
            shotInterval = 0.5;
            bulletDamage = 2;
            bulletPenetration = TRUE;
            break;
            
        case 5:
            ammoCapacity = 30;
            remainingAmmo = ammoCapacity;
            [self sychronizeAmmo];
            shotInterval = 0.1;
            bulletDamage = 2;
            bulletPenetration = TRUE;
            break;
            
        case 6:
            ammoCapacity = 100;
            remainingAmmo = ammoCapacity;
            [self sychronizeAmmo];
            shotInterval = 0.08;
            bulletDamage = 2;
            bulletPenetration = TRUE;
            break;
            
        default:
            break;
    }
}

// called on every touch in this scene
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    touchLocation = [touch locationInNode:_ccNode];
    [self schedule:@selector(launchProjectile) interval:shotInterval];
    
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    touchLocation = [touch locationInNode:_ccNode];
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self unschedule:@selector(launchProjectile)];
}

- (void)launchProjectile {
    if ( (remainingAmmo > 0) && shotIntervalPassed && (touchLocation.y > 80)) {
    
        remainingAmmo --;
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:@"gunshotsound"];
        if (remainingAmmo == 0) {
            _reloadAlert.visible = TRUE;
        }
        [self sychronizeAmmo];
        shotIntervalPassed = FALSE;
        [self scheduleOnce:@selector(resetShotIntervalPassed) delay:shotInterval];
        //calculate launch angel and corresponding rotation angel
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
        
        CGPoint startPosition ;
        if (touchLocation.x < self.boundingBox.size.width/2) {
            startPosition = ccp ( (self.boundingBox.size.width/2 - weaponPNG.boundingBox.size.height * cos(launchAngel)), weaponPNG.boundingBox.size.height * sin(launchAngel));
        }
        else {
            startPosition = ccp ( (self.boundingBox.size.width/2 + weaponPNG.boundingBox.size.height * cos(launchAngel)), weaponPNG.boundingBox.size.height * sin(launchAngel));
        }
        
        CCNode* projectile = [CCBReader load:@"Projectile"];
    
        projectile.position = startPosition;
        projectile.rotation = rotationAngel;
        weaponPNG.rotation = rotationAngel;
    
        [_physicsNode addChild:projectile];
    
        CGPoint launchDirection;
        if (touchLocation.x < self.boundingBox.size.width/2) {
            launchDirection.x = -cos(launchAngel);
            launchDirection.y = sin(launchAngel) ;
        }
        else {
            launchDirection.x = cos(launchAngel);
            launchDirection.y = sin(launchAngel) ;
        }
        CGPoint force = ccpMult(launchDirection, BULLET_SPEED);
        CCLOG(@"%@", NSStringFromCGPoint(force));
    
        [projectile.physicsBody applyImpulse:force];
        if (self.weaponIndex == 2) {
            CCNode* projectile2 = [CCBReader load:@"Projectile"];
            CCNode* projectile3 = [CCBReader load:@"Projectile"];
            CCNode* projectile4 = [CCBReader load:@"Projectile"];
            CCNode* projectile5 = [CCBReader load:@"Projectile"];
            projectile2.position = projectile3.position = projectile4.position = projectile5.position =startPosition;
            projectile2.rotation = rotationAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE;
            projectile3.rotation = rotationAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE * 2;
            projectile4.rotation = rotationAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE;
            projectile5.rotation = rotationAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE * 2;
            
            [_physicsNode addChild:projectile2];
            [_physicsNode addChild:projectile3];
            [_physicsNode addChild:projectile4];
            [_physicsNode addChild:projectile5];
            
            CGPoint launchDirection2, launchDirection3, launchDirection4, launchDirection5;
            if (touchLocation.x < self.boundingBox.size.width/2) {
                launchDirection2.x = -cos(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC);
                launchDirection2.y = sin(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC) ;
                launchDirection3.x = -cos(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2);
                launchDirection3.y = sin(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2) ;
                launchDirection4.x = -cos(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC);
                launchDirection4.y = sin(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC) ;
                launchDirection5.x = -cos(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2);
                launchDirection5.y = sin(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2) ;
                
            }
            else {
                launchDirection2.x = cos(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC);
                launchDirection2.y = sin(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC) ;
                launchDirection3.x = cos(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2);
                launchDirection3.y = sin(launchAngel - SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2) ;
                launchDirection4.x = cos(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC);
                launchDirection4.y = sin(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC) ;
                launchDirection5.x = cos(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2);
                launchDirection5.y = sin(launchAngel + SHOTGUN_BULLET_ANGLE_DIFFERENCE_IN_ARC * 2) ;
            }
            CGPoint force2 = ccpMult(launchDirection2, BULLET_SPEED);
            CGPoint force3 = ccpMult(launchDirection3, BULLET_SPEED);
            CGPoint force4 = ccpMult(launchDirection4, BULLET_SPEED);
            CGPoint force5 = ccpMult(launchDirection5, BULLET_SPEED);
            [projectile2.physicsBody applyImpulse:force2];
            [projectile3.physicsBody applyImpulse:force3];
            [projectile4.physicsBody applyImpulse:force4];
            [projectile5.physicsBody applyImpulse:force5];
            
            
        }
    }
}

- (void)resetShotIntervalPassed {
    shotIntervalPassed = TRUE;
}

- (void)update:(CCTime)delta
{
    for (id object in _physicsNode.children){
        if ([object isKindOfClass:[Projectile class]]){
            Projectile *j = object;
            if ((j.position.x < 0) || (j.position.x > self.boundingBox.size.width) || (j.position.y > self.boundingBox.size.height) || (j.position.y < 0)){
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
                i.position = ccp(12 ,i.position.y);
                i.rotation = -i.rotation;
                [i.physicsBody applyForce:ccp(-i.physicsBody.velocity.x*200 ,0)];
            }
            if (i.position.x > self.boundingBox.size.width - 10 ) {
                i.position = ccp(self.boundingBox.size.width - 12 ,i.position.y);
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

- (void)oneSwallowAppears {
    double r1 = arc4random() % 100;
    double r2 = arc4random() % 100;
    double r3 = arc4random() % 100;
    double x;
    double birdAngel;
    if (r3 > 50) { x = 1;}else{ x = -1;}
    birdAngel = - (atan(x * (1500 + 15 * r2)/3000))*180/M_PI;
    CCLOG(@"angel %f", birdAngel);
    CCNode* bird = [CCBReader load:@"Swallow"];
    bird.physicsBody.sensor = TRUE;
    bird.position = ccp( (20 + r1*(self.boundingBox.size.width - 20)/100) ,self.boundingBox.size.height - 10);
    bird.rotation = birdAngel;
    [_physicsNode addChild:bird];
    CGPoint flydirection = ccp( x * (1500 + 15 * r2), -3000);
    [bird.physicsBody applyForce:flydirection];
    
}

- (void)onePigeonAppears {
    double r1 = arc4random() % 100;
    double r2 = arc4random() % 100;
    double r3 = arc4random() % 100;
    double x;
    double birdAngel;
    if (r3 > 50) { x = 1;}else{ x = -1;}
    birdAngel = - (atan(x * (1500 + 15 * r2)/3000))*180/M_PI;
    CCLOG(@"angel %f", birdAngel);
    CCNode* bird = [CCBReader load:@"Pigeon"];
    bird.physicsBody.sensor = TRUE;
    bird.position = ccp( (20 + r1*(self.boundingBox.size.width - 20)/100) ,self.boundingBox.size.height - 10);
    bird.rotation = birdAngel;
    [_physicsNode addChild:bird];
    CGPoint flydirection = ccp( x * (1500 + 15 * r2), -3000);
    [bird.physicsBody applyForce:flydirection];
    
}

- (void)oneRavenAppears {
    double r1 = arc4random() % 100;
    double r2 = arc4random() % 100;
    double r3 = arc4random() % 100;
    double x;
    double birdAngel;
    if (r3 > 50) { x = 1;}else{ x = -1;}
    birdAngel = - (atan(x * (1500 + 15 * r2)/3000))*180/M_PI;
    CCLOG(@"angel %f", birdAngel);
    CCNode* bird = [CCBReader load:@"Raven"];
    bird.physicsBody.sensor = TRUE;
    bird.position = ccp( (20 + r1*(self.boundingBox.size.width - 20)/100) ,self.boundingBox.size.height - 10);
    bird.rotation = birdAngel;
    [_physicsNode addChild:bird];
    CGPoint flydirection = ccp( x * (1500 + 15 * r2), -3000);
    [bird.physicsBody applyForce:flydirection];
    
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bird:(Bird *)nodeA projectile:(CCNode *)nodeB {
    nodeA.health -= bulletDamage;
    CCParticleSystem *blood = (CCParticleSystem *)[CCBReader load:@"Birdshot"];
    blood.autoRemoveOnFinish = TRUE;
    blood.position = nodeA.position;
    [_physicsNode addChild:blood];
    
    if (nodeA.health <= 0) {
        swallowKilledNumber += nodeA.swallowLifeCounter;
        pigeonKilledNumber += nodeA.pigeonLifeCounter;
        ravenKilledNumber += nodeA.ravenLifeCounter;
        
        [[_physicsNode space] addPostStepBlock:^{
        [self oneObjectRemoved:nodeA];
        } key:nodeA];
    
        CCNode* deadbird = [CCBReader load:nodeA.afterDeathCCBName];
        deadbird.physicsBody.sensor = TRUE;
        deadbird.position = nodeA.position;
        [[_physicsNode space] addPostStepBlock:^{
            [_physicsNode addChild:deadbird];
        } key:deadbird];
    }
    if (bulletPenetration == FALSE) {
        [[_physicsNode space] addPostStepBlock:^{
            [self oneObjectRemoved:nodeB];
        } key:nodeB];
        
    }
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
        Recap *scene = (Recap *)recapScene.children.firstObject;
        scene.swallowKilled = swallowKilledNumber;
        scene.pigeonKilled = pigeonKilledNumber;
        scene.ravenKilled = ravenKilledNumber;
        
        [[CCDirector sharedDirector] replaceScene:recapScene];
    }
    return TRUE;
}

- (void)oneObjectRemoved:(CCNode *)object {
    [object removeFromParent];
}

- (void)startReload {
    CCNode* reloadAnim = [CCBReader loadAsScene:@"ReloadAnim"];
    reload = reloadAnim;
    reloadAnim.position = ccp(60 , 60);
    [_magReading.parent addChild:(reloadAnim)];
    CCLOG(@"before: %i",remainingAmmo);
    if (_reloadAlert.visible == TRUE) {
        _reloadAlert.visible = FALSE;
    }
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"reloadsound"];
    remainingAmmo = 0;
    [self sychronizeAmmo];
    [self scheduleOnce:@selector(endReload) delay:2];
    _reloadButton.enabled = NO;
    CCLOG(@"ing: %i",remainingAmmo);
}

- (void)endReload {
    [self oneObjectRemoved:reload];
    remainingAmmo = ammoCapacity;
    [self sychronizeAmmo];
    CCLOG(@"after: %i",remainingAmmo);
    _reloadButton.enabled = YES;
}

- (void) sychronizeAmmo {
    _magReading.string = [NSString stringWithFormat:@"%d", remainingAmmo];
}

- (void) startRealGame {
    [self schedule:@selector(scheduleToAddBirds) interval:45.0f];
}

- (void) scheduleToAddBirds {
    swallowInterval = swallowInterval/2;
    pigeonInterval = pigeonInterval/2;
    ravenInterval = ravenInterval/2;
    swallowAppearNumber = (swallowAppearNumber + 1) * 2 - 1;
    pigeonAppearNumber = (pigeonAppearNumber + 1) * 2 - 1;
    ravenAppearNumber = (ravenAppearNumber + 1) * 2 - 1;
    [self schedule:@selector(oneSwallowAppears) interval:swallowInterval repeat:swallowAppearNumber delay:0];
    [self schedule:@selector(onePigeonAppears) interval:pigeonInterval repeat:pigeonAppearNumber delay:5];
    [self schedule:@selector(oneRavenAppears) interval:ravenInterval repeat:ravenAppearNumber delay:10];
}

@end

//
//  LevelTwo.m
//  minimalisticTown
//
//  Created by Victor Souza on 2/24/15.
//  Copyright (c) 2015 Victor Souza. All rights reserved.
//

#import "LevelTwo.h"
#import "LevelOne.h"

@implementation LevelTwo
{
    SKSpriteNode *_escada;
    SKSpriteNode *_ambulancia;
    SKSpriteNode *_balao;
    
    BOOL _hideIt;
    BOOL _escadaBOOL;
    BOOL _escadaRotate;
}

-(void)didMoveToView:(SKView *)view {
    
//    Flags
    
    _hideIt = YES;
    _escadaBOOL = NO;
    _escadaRotate = NO;
    
//    Background
    
    SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"Fundo-Level2@3x.png"];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:self.view.frame.size];
    background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
    background.zPosition = 1;
    [self addChild:background];
    
//    Hospital
    
    SKSpriteNode *hospital = [SKSpriteNode spriteNodeWithImageNamed:@"Hospital-Level2"];
    hospital.position = CGPointMake(self.size.width - hospital.size.width/1.8, self.size.height/2.5);
    hospital.zPosition = 2;
    [self addChild:hospital];
    
    
//    Escada
    
    _escada = [SKSpriteNode spriteNodeWithImageNamed:@"Escada-Level2"];
    _escada.zPosition = 3;
    _escada.position = CGPointMake(hospital.position.x + 3.9 * _escada.size.width,
                                   hospital.position.y - _escada.size.height/3.6);
    _escada.name = @"escada";
    [self addChild:_escada];
    
//    Carro
    
    _ambulancia = [SKSpriteNode spriteNodeWithImageNamed:@"Ambulancia-Level2"];
    _ambulancia.position = CGPointMake(self.size.width/2 - _ambulancia.size.width/2,
                                       self.size.height/8);
    _ambulancia.zPosition = 3;
    [self addChild:_ambulancia];
    
//    Balao
    
    _balao = [SKSpriteNode spriteNodeWithImageNamed:@"Balao-Level2"];
    _balao.position = CGPointMake(_ambulancia.position.x + _balao.size.width/3, _ambulancia.position.y);
    _balao.zPosition = 2;
    _balao.anchorPoint = CGPointMake(0, 0);
    _balao.hidden = YES;
    [self addChild:_balao];
    
    SKAction *hide = [SKAction performSelector:@selector(hide) onTarget:self];
    SKAction *waitWhileShown = [SKAction waitForDuration:1];
    SKAction *waitWhileHidden = [SKAction waitForDuration:1];
    [_balao runAction:[SKAction repeatActionForever:
                       [SKAction sequence:@[waitWhileHidden,hide,waitWhileShown,hide]]] withKey:@"hideAction"];
    
//    Rotation recognizer
    
    rotationGesture = [[UIRotationGestureRecognizer alloc]
                       initWithTarget:self action:@selector(handleRotation:)];
    [view addGestureRecognizer:rotationGesture];
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *test = [self nodeAtPoint:location];
        if ([test.name isEqualToString:@"escada"]) {
            _escadaBOOL = YES;
            _escadaRotate = YES;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        if (_escadaBOOL) {
            _escada.position = CGPointMake(_escada.position.x + location.x - previousLocation.x,
                                           _escada.position.y + location.y - previousLocation.y);
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _escadaBOOL = NO;
    if (_escada.position.y >= 0.11 * self.size.height && _escada.position.y <= 0.15 * self.size.height) {
        if (_escada.position.x >= 0.08 * self.size.width && _escada.position.x <= 0.17 * self.size.width) {
            [self nextLevel];
        }
    }
}

-(void)handleRotation: (UIRotationGestureRecognizer *) recognizer  {
    if(_escadaRotate) {
        SKAction *rotate = [SKAction rotateToAngle:M_PI/2 duration:0.5];
        rotate.timingMode = SKActionTimingEaseOut;
        [_escada runAction:rotate];
    }
}

-(void)hide {
    if (_hideIt) {
        _balao.hidden = !_balao.hidden;
    }
}

-(void)nextLevel {
    
    SKTransition *transition = [SKTransition fadeWithDuration:0.5];
    
    SKScene *scene = [[LevelOne alloc] initWithSize:self.size];
    
    [self.view presentScene:scene transition:transition];
}

@end

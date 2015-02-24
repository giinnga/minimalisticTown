//
//  GameScene.m
//  minimalisticTown
//
//  Created by Victor Souza on 2/24/15.
//  Copyright (c) 2015 Victor Souza. All rights reserved.
//

#import "LevelOne.h"
#import "LevelTwo.h"

@implementation LevelOne
{
    BOOL _cloud;
    BOOL _hideIt;
    
    SKSpriteNode *_cloudNode;
    SKSpriteNode *_balao;
    
    SKEmitterNode *_explosionEmitter;
    
    SKTexture *_backgroundTexture;
}

-(void)didMoveToView:(SKView *)view {
  
//    Setup your scene here
    
    _cloud = NO;
    _hideIt = YES;
    
//    Background
    
    _backgroundTexture = [SKTexture textureWithImageNamed:@"Fundo-Level1@3x.png"];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:_backgroundTexture size:self.view.frame.size];
    background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
    background.zPosition = 1;
    [self addChild:background];
    
//    Cloud
    
    _cloudNode = [SKSpriteNode spriteNodeWithImageNamed:@"Nuvem-Level1"];
    _cloudNode.position = CGPointMake(0.3 * self.size.width, self.size.height - _cloudNode.size.height * 0.6);
    _cloudNode.zPosition = 2;
    _cloudNode.name = @"cloud";
    [self addChild:_cloudNode];
    
    [self rain];
    
    
//    Balao
    
    _balao = [SKSpriteNode spriteNodeWithImageNamed:@"Balao-Level1"];
    _balao.position = CGPointMake(0.52 * self.size.width, 0.52 * self.size.height);
    _balao.zPosition = 2;
    _balao.hidden = YES;
    [self addChild:_balao];
    
    SKAction *hide = [SKAction performSelector:@selector(hide) onTarget:self];
    SKAction *waitWhileShown = [SKAction waitForDuration:5];
    SKAction *waitWhileHidden = [SKAction waitForDuration:10];
    [_balao runAction:[SKAction repeatActionForever:
                       [SKAction sequence:@[waitWhileHidden,hide,waitWhileShown,hide]]] withKey:@"hideAction"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *test = [self nodeAtPoint:location];
        if ([test.name isEqualToString:@"cloud"]) {
            _cloud = YES;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (_cloud) {
            SKAction *move = [SKAction moveToX:location.x duration:0];
            [_cloudNode runAction:move];
            _explosionEmitter.position = _cloudNode.position;
        }
    }
    
    if ((_cloudNode.position.x > self.size.width - _cloudNode.size.width/2)) {
        _hideIt = NO;
        _balao.hidden = YES;
        
        [self nextLevel];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _cloud = NO;
    
}

-(CGSize)proportion {
    
    float proportion = _backgroundTexture.size.width / self.size.width;
    CGSize correctSize = self.size;
    correctSize.height = self.size.height * proportion;
    correctSize.width = self.size.width;
    return correctSize;

}

-(void)hide {
    if (_hideIt) {
        _balao.hidden = !_balao.hidden;
    }
}

-(void)explosion:(CGPoint)position withName:(NSString*)name
{
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
    _explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    
    _explosionEmitter.position = position;
    _explosionEmitter.zPosition = 1;
    [self addChild:_explosionEmitter];
}

-(void)rain {
    [self explosion:_cloudNode.position withName:@"rain"];
}

-(void)nextLevel {
    
    SKTransition *transition = [SKTransition fadeWithDuration:0.5];
    
    SKScene *scene = [[LevelTwo alloc] initWithSize:self.size];
    
    [self.view presentScene:scene transition:transition];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
}

@end

//
//  RWTMovie.h
//  CookieCrunch
//
//  Created by DJIBRIL KEITA on 10/8/14.
//  Copyright (c) 2014 DJIBRILKEITA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RWTMovie : NSObject

@property (nonatomic,strong) NSString *movieName;
@property (nonatomic,strong) NSArray *actorList;
@property (nonatomic,strong) NSDictionary *map;

-(NSArray *)getActorListforMovie:(NSString *)movieName;
-(int)match:(NSArray *)actors withMovie:(NSString *)name;


@end

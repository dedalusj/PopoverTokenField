//
//  JSMessageInterceptor.h
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 1/09/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSMessageInterceptor : NSObject 

@property (nonatomic, weak) id receiver;
@property (nonatomic, weak) id middleMan;

@end

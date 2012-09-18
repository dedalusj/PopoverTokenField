//
//  JSTokenFieldCell.m
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 18/09/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

#import "JSTokenFieldCell.h"
#import "JSTextView.h"

@implementation JSTokenFieldCell

- (JSTextView *)fieldEditorForView:(NSView *)aControlView
{
    return [[JSTextView alloc] init];
}

@end

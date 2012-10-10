//
//  JSTokenCloud.m
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 31/08/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

#import "JSTokenCloud.h"

@interface JSTokenCloud() {
    NSMutableArray *_tokenButtons;
    NSRect _prevRect;
    BOOL setup;
}

- (void)recalculateButtonLocations;
@property (nonatomic)  NSUInteger highlightedToken;

@end

@implementation JSTokenCloud

@synthesize preferredHeight = _preferredHeight;
@synthesize delegate;
@synthesize highlightedToken = _highlightedToken;

-(void)setHighlightedToken:(NSUInteger)newHighlightedToken
{
    if (newHighlightedToken!=_highlightedToken) {
        if (newHighlightedToken<[_tokenButtons count]) {
        
            //Switch off the old token if any
            if (_highlightedToken!=NSNotFound) [[_tokenButtons objectAtIndex:_highlightedToken] setState:NO];
        
            //Set the new value for the highlighted token and turn the button on
            _highlightedToken = newHighlightedToken;
            [[_tokenButtons objectAtIndex:_highlightedToken] setState:YES];
        
            //Now draw the change
            [self setNeedsDisplay:YES];
        } else if (newHighlightedToken==NSNotFound) {
        
            //If the hightligthed token is NSNotFound we have just been asked to switch off all tokens
            [[_tokenButtons objectAtIndex:_highlightedToken] setState:NO];
            _highlightedToken = NSNotFound;
        
            //Now draw the change
            [self setNeedsDisplay:YES];
        }
    }
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_tokenButtons = [[NSMutableArray alloc] init];
		_prevRect = NSZeroRect;
		_preferredHeight = -1;
        _highlightedToken = NSNotFound;
    }
    return self;
}

-(NSArray *)tokens {
    NSMutableArray *_tokens = [NSMutableArray arrayWithCapacity:0];
    for (NSButton *tokenTitle in _tokenButtons) [_tokens addObject:[tokenTitle title]];
    return [_tokens copy];
}

- (void)setTokens:(NSArray *)newArray {
    
	//Find the tokens that aren't in the new set and remove them from the view
    NSMutableArray *removedTokens = [[self tokens] mutableCopy];
    [removedTokens removeObjectsInArray:newArray];
	for (NSString *title in removedTokens) {
        NSUInteger index = [self indexOfTokenWithTitle:title];
		[[_tokenButtons objectAtIndex:index] removeFromSuperview];
		[_tokenButtons removeObjectAtIndex:index];
	}
	
    //Find the tokens that were added and create the new buttons for them
    NSMutableArray *addedTokens = [newArray mutableCopy];
    [addedTokens removeObjectsInArray:[self tokens]];
    for (NSString *title in addedTokens) {
        if ([title length]) {
            JSTokenButton *button = [[JSTokenButton alloc] initWithFrame:NSMakeRect(0, 0, 50, 20)];
			[button setTitle:title];
			[button setTarget:self];
			[button setAction:@selector(buttonClicked:)];
			[_tokenButtons addObject:button];
        }
    }
    
    //We always want to keep the tokens sorted alphabetically
	[_tokenButtons sortUsingComparator: ^(NSButton *button1, NSButton *button2) {
        return [button1.title localizedCaseInsensitiveCompare:button2.title];
    }];
	
    //Here we go and draw any change we made
    [self recalculateButtonLocations];
    
    //Recompute the index of the highlighted token
    NSUInteger index = 0;
    for (NSButton *tokenButton in _tokenButtons) {
        if ([tokenButton state]==YES) {
            _highlightedToken = index;
            break;
        }
        index++;
    }
}

-(void)removeToken:(NSString *)token
{
    NSUInteger index = 0;
    for (NSButton *tokenButton in _tokenButtons) {
        if ([token isEqualToString:tokenButton.title]) {
            [tokenButton removeFromSuperview];
            [_tokenButtons removeObject:tokenButton];
            if ((index<_highlightedToken) && (_highlightedToken!=NSNotFound)) _highlightedToken--;
            return;
        }
        index++;
    }
}

-(void)addToken:(NSString *)token
{
    NSUInteger index = 0;
    for (NSButton *tokenButton in _tokenButtons) {
        if ([token localizedCaseInsensitiveCompare:tokenButton.title]==NSOrderedAscending) {
            JSTokenButton *button = [[JSTokenButton alloc] initWithFrame:NSMakeRect(0, 0, 50, 20)];
			[button setTitle:token];
			[button setTarget:self];
			[button setAction:@selector(buttonClicked:)];
			[_tokenButtons insertObject:button atIndex:index];
            if ((index<_highlightedToken) && (_highlightedToken!=NSNotFound)) _highlightedToken++;
            return;
        }
        index++;
    }
}

-(NSUInteger)indexOfTokenWithTitle:(NSString *)title
{
    return [_tokenButtons indexOfObjectPassingTest:^(NSButton *obj, NSUInteger idx, BOOL *stop) { return ([obj.title isEqualToString:title]); }];
}

- (void)drawRect:(NSRect)rect {
	[self recalculateButtonLocations];
}

-(NSMutableArray *)rowsArrayForWidth:(float)width
{
    int index = 0;
    NSMutableArray *rowsArray = [NSMutableArray array];
	//Loop through buttons assigning them to rows
	while (index < [_tokenButtons count]) {
		float x = 0;
		float rowWidth = 0;
		NSMutableArray *row = [NSMutableArray array];
		while (x < width) {
			JSTokenButton *button = [_tokenButtons objectAtIndex:index];
			x += [button boundingRect].size.width + 4;
			rowWidth += [button boundingRect].size.width;
			//If this button puts us over the width of the view then break and move to the next line, if the button's bounding rect is greater than the size of the view then draw anyway and trim.
			if (x > width && [button boundingRect].size.width + 4 < width) {
				rowWidth -= [button boundingRect].size.width;
				break;
			}
			[row addObject:button];
			index++;
			if (index >= [_tokenButtons count])
				break;
		}
		[rowsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:row, @"row", [NSNumber numberWithFloat:rowWidth], @"rowWidth", nil]];
	}
    return rowsArray;
}

-(float)preferredHeightForWidth:(float)width
{
    return 24 * [[self rowsArrayForWidth:width] count];
}

- (void)recalculateButtonLocations
{
	NSMutableArray *rowsArray = [self rowsArrayForWidth:[self bounds].size.width];
	
	//Now position the bloody things
	float y = [self bounds].size.height - 20;
	for (NSDictionary *row in rowsArray) {
		float x = 0;
		
		float rowWidth = [[row objectForKey:@"rowWidth"] floatValue];
		NSArray *rowArray = [row objectForKey:@"row"];
		float spacing = ([self bounds].size.width - rowWidth) / ([rowArray count] - 1);
		
		for (JSTokenButton *button in rowArray) {
			[button setFrameOrigin:NSMakePoint(x, y)];
			if ([rowsArray count] > 1) {
				x += [button boundingRect].size.width + spacing;
			} else {
				x += [button boundingRect].size.width + 4;
			}
			if (![button superview])
				[self addSubview:button];
		}
		y -= 24;
	}
	//Send the new preferred height to the delegate
	float newPreferredHeight = 24 * [rowsArray count];
	if (newPreferredHeight != _preferredHeight) {
		if (([[self delegate] respondsToSelector:@selector(tokenCloud:didChangePreferredHeightTo:)])  && setup) {
			[[self delegate] tokenCloud:self didChangePreferredHeightTo:newPreferredHeight];
		}
		_preferredHeight = newPreferredHeight;
	}
    
    // We laid out again the buttons so we want to redraw
    [self setNeedsDisplay:YES];
    
	//Works around to make sure the delegate method isn't sent when the view is setup
	if (!setup)
		setup = YES;
}

-(void)highlightToken:(NSString *)token
{
    NSUInteger indexOfTokenToHighlight = [self indexOfTokenWithTitle:token];
    if ((indexOfTokenToHighlight!=NSNotFound) && (indexOfTokenToHighlight!=self.highlightedToken)) {
        self.highlightedToken = indexOfTokenToHighlight;
    }
}

-(void)deselectAllTokens
{
    self.highlightedToken = NSNotFound;
}

- (void)buttonClicked:(id)sender {
	if ([[self delegate] respondsToSelector:@selector(tokenCloud:didClickToken:enabled:)]) {
		[[self delegate] tokenCloud:self didClickToken:[sender title] enabled:[sender state]];
	}
}

-(NSString *)selectNextToken
{
    if ((self.highlightedToken<[_tokenButtons count]-1) || (self.highlightedToken==NSNotFound)) {
        //If the highlighted token is NSNotFound the single increment brings it to 0 and the setter method for highlightedToken takes care of all the rest
        self.highlightedToken++;
        return [[_tokenButtons objectAtIndex:self.highlightedToken] title];
    }
    return nil;
}

-(NSString *)selectPreviousToken
{
    if (self.highlightedToken!=0) {
        if (self.highlightedToken!=NSNotFound) { self.highlightedToken--; }
        else { self.highlightedToken = [_tokenButtons count]; }
        return [[_tokenButtons objectAtIndex:self.highlightedToken] title];
    }
    return nil;
}

@end

@implementation JSTokenButton

+ (Class)cellClass {
	return [JSTokenButtonCell class];
}

- (void)drawRect:(NSRect)rect {
	[self setFrame:[self boundingRect]]; //Can't remember why I need to do this, but I do
	[super drawRect:[self boundingRect]];
}

- (NSRect)boundingRect {
	NSRect boundingRect = [[self attributedTitle] boundingRectWithSize:NSMakeSize(1000, [self frame].size.height) options:0];
	boundingRect.size.width += 20;
	boundingRect.size.height = [self frame].size.height;
	boundingRect.origin = [self frame].origin;
	return boundingRect;
}

@end

static NSGradient *blueStrokeGradient;
static NSGradient *blueInsetGradient;
static NSGradient *blueGradient;
static NSGradient *highlightedBlueStrokeGradient;
static NSGradient *highlightedBlueInsetGradient;
static NSGradient *highlightedBlueGradient;
static NSGradient *hoverBlueGradient;
static NSGradient *hoverBlueInsetGradient;

@implementation JSTokenButtonCell

/*
 Change this to play with the colours of the tokens
 */
+ (void)initialize
{
	
	NSColor *blueTopColor = [NSColor colorWithCalibratedRed:217.0/255.0 green:228.0/255.0 blue:254.0/255.0 alpha:1];
	NSColor *blueBottomColor = [NSColor colorWithCalibratedRed:195.0/255.0 green:212.0/255.0 blue:250.0/255.0 alpha:1];
	blueGradient = [[NSGradient alloc] initWithStartingColor:blueTopColor endingColor:blueBottomColor];
	
	NSColor *blueStrokeTopColor = [NSColor colorWithCalibratedRed:164.0/255.0 green:184.0/255.0 blue:230.0/255.0 alpha:1];
	NSColor *blueStrokeBottomColor = [NSColor colorWithCalibratedRed:122.0/255.0 green:128.0/255.0 blue:199.0/255.0 alpha:1];
	blueStrokeGradient = [[NSGradient alloc] initWithStartingColor:blueStrokeTopColor endingColor:blueStrokeBottomColor];
	
	NSColor *blueInsetTopColor = [NSColor colorWithCalibratedRed:226.0/255.0 green:234.0/255.0 blue:254.0/255.0 alpha:1];
	NSColor *blueInsetBottomColor = [NSColor colorWithCalibratedRed:206.0/255.0 green:221.0/255.0 blue:250.0/255.0 alpha:1];
	blueInsetGradient = [[NSGradient alloc] initWithStartingColor:blueInsetTopColor endingColor:blueInsetBottomColor];
	
	NSColor *highlightedBlueTopColor = [NSColor colorWithCalibratedRed:80.0/255.0 green:127.0/255.0 blue:251.0/255.0 alpha:1];
	NSColor *highlightedBlueBottomColor = [NSColor colorWithCalibratedRed:65.0/255.0 green:107.0/255.0 blue:236.0/255.0 alpha:1];
	highlightedBlueGradient = [[NSGradient alloc] initWithStartingColor:highlightedBlueTopColor endingColor:highlightedBlueBottomColor];
	
	NSColor *highlightedBlueStrokeTopColor = [NSColor colorWithCalibratedRed:51.0/255.0 green:95.0/255.0 blue:248.0/255.0 alpha:1];
	NSColor *highlightedBlueStrokeBottomColor = [NSColor colorWithCalibratedRed:42.0/255.0 green:47.0/255.0 blue:233.0/255.0 alpha:1];
	highlightedBlueStrokeGradient = [[NSGradient alloc] initWithStartingColor:highlightedBlueStrokeTopColor endingColor:highlightedBlueStrokeBottomColor];
	
	NSColor *highlightedBlueInsetTopColor = [NSColor colorWithCalibratedRed:92.0/255.0 green:137.0/255.0 blue:251.0/255.0 alpha:1];
	NSColor *highlightedBlueInsetBottomColor = [NSColor colorWithCalibratedRed:76.0/255.0 green:116.0/255.0 blue:236.0/255.0 alpha:1];
	highlightedBlueInsetGradient = [[NSGradient alloc] initWithStartingColor:highlightedBlueInsetTopColor endingColor:highlightedBlueInsetBottomColor];
	
	NSColor *hoverBlueTopColor = [NSColor colorWithCalibratedRed:195.0/255.0 green:207.0/255.0 blue:243.0/255.0 alpha:1];
	NSColor *hoverBlueBottomColor = [NSColor colorWithCalibratedRed:176.0/255.0 green:193.0/255.0 blue:239.0/255.0 alpha:1];
	hoverBlueGradient = [[NSGradient alloc] initWithStartingColor:hoverBlueTopColor endingColor:hoverBlueBottomColor];
	
	NSColor *hoverBlueInsetTopColor = [NSColor colorWithCalibratedRed:204.0/255.0 green:2137.0/255.0 blue:243.0/255.0 alpha:1];
	NSColor *hoverBlueInsetBottomColor = [NSColor colorWithCalibratedRed:186.0/255.0 green:201.0/255.0 blue:239.0/255.0 alpha:1];
	hoverBlueInsetGradient = [[NSGradient alloc] initWithStartingColor:hoverBlueInsetTopColor endingColor:hoverBlueInsetBottomColor];
}


- (BOOL)allowsMixedState {
	return NO;
}


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	float scaleFactor = [[NSScreen mainScreen] userSpaceScaleFactor];
	
	NSRect drawingRect = [self drawingRectForBounds:cellFrame];
	NSRect insetRect = NSInsetRect(drawingRect, 1 / scaleFactor, 1 / scaleFactor);
	NSRect insetRect2 = NSInsetRect(insetRect, 1 / scaleFactor, 1 / scaleFactor);
	
	if (scaleFactor < 0.99 || scaleFactor > 1.01)
	{
		drawingRect = [controlView centerScanRect:drawingRect];
		insetRect = [controlView centerScanRect:insetRect];
		insetRect2 = [controlView centerScanRect:insetRect2];
	}
	
	NSBezierPath *drawingPath = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:0.5*drawingRect.size.height yRadius:0.5*drawingRect.size.height];
	NSBezierPath *insetPath = [NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:0.5*insetRect.size.height yRadius:0.5*insetRect.size.height];
	NSBezierPath *insetPath2 = [NSBezierPath bezierPathWithRoundedRect:insetRect2 xRadius:0.5*insetRect2.size.height yRadius:0.5*insetRect2.size.height];
	
	NSMutableAttributedString *str = [[self attributedTitle] mutableCopy];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setAlignment:NSCenterTextAlignment];
	[str setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:12], NSFontAttributeName, style, NSParagraphStyleAttributeName, nil] range:NSMakeRange(0, [str length])];
	if ([self isHighlighted]) {
		[blueStrokeGradient drawInBezierPath:drawingPath angle:90];
		[hoverBlueInsetGradient drawInBezierPath:insetPath angle:90];
		[hoverBlueGradient drawInBezierPath:insetPath2 angle:90];
	} else if ([self state] == NSOffState) {
		[blueStrokeGradient drawInBezierPath:drawingPath angle:90];
		[blueInsetGradient drawInBezierPath:insetPath angle:90];
		[blueGradient drawInBezierPath:insetPath2 angle:90];
	} else {
		[str setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:12], NSFontAttributeName, style, NSParagraphStyleAttributeName, nil] range:NSMakeRange(0, [str length])];
		
		[highlightedBlueStrokeGradient drawInBezierPath:drawingPath angle:90];
		[highlightedBlueInsetGradient drawInBezierPath:insetPath angle:90];
		[highlightedBlueGradient drawInBezierPath:insetPath2 angle:90];
	}
	
	NSRect textRect = drawingRect;
	
	textRect.size.height = 16;
	textRect.origin.y = (drawingRect.size.height - 14) / 2;
	
	[str drawInRect:textRect];
}

- (NSRect)drawingRectForBounds:(NSRect)bounds {
	return NSMakeRect(1, 1, bounds.size.width - 3, bounds.size.height - 3);
}

@end

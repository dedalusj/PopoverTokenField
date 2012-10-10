//
//  JSTokenField.m
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 31/08/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

#import "JSTokenField.h"
#import "JSMessageInterceptor.h"

@interface JSTokenField() {
    JSMessageInterceptor *delegateInterceptor;
    NSPopover *tokenCloudPopover;
    NSViewController *tokenCloudController;
    JSTokenCloud *tokenCloud;
    BOOL justAddedCompletionString;
    BOOL shouldEndEditing;
    NSString *currentlyInsertedSubstring;
}

@end

@implementation JSTokenField

- (void)setDelegate:(id)newDelegate {
    [super setDelegate:nil];
    [delegateInterceptor setReceiver:newDelegate];
    [super setDelegate:(id)delegateInterceptor];
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        delegateInterceptor = [[JSMessageInterceptor alloc] init];
        [delegateInterceptor setMiddleMan:self];
        [super setDelegate:(id)delegateInterceptor];
        tokenCloudPopover = [[NSPopover alloc] init];
        [tokenCloudPopover setAnimates:YES];
        [self setAllowsEditingTextAttributes:YES];
        tokenCloud = [[JSTokenCloud alloc] initWithFrame:NSMakeRect(0, 0, 100.0f, 100.0f)];
        tokenCloudController = [[NSViewController alloc] init];
        tokenCloudController.view = tokenCloud;
        [tokenCloud setDelegate:self];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        delegateInterceptor = [[JSMessageInterceptor alloc] init];
        [delegateInterceptor setMiddleMan:self];
        [super setDelegate:(id)delegateInterceptor];
        tokenCloudPopover = [[NSPopover alloc] init];
        [tokenCloudPopover setAnimates:YES];
        [self setAllowsEditingTextAttributes:YES];
        tokenCloud = [[JSTokenCloud alloc] initWithFrame:NSMakeRect(0, 0, 100.0f, 100.0f)];
        tokenCloudController = [[NSViewController alloc] init];
        tokenCloudController.view = tokenCloud;
        [tokenCloud setDelegate:self];
    }
    return self;
}

-(BOOL)becomeFirstResponder
{
    if ([((JSMessageInterceptor *)self.delegate).receiver respondsToSelector:@selector(tokenField:tokensGivenCurrentTokens:)]) {
        id<JSTokenFieldDelegate> receiver = ((JSMessageInterceptor *)self.delegate).receiver;
        NSArray *tokens = [[self stringValue] componentsSeparatedByCharactersInSet:[self tokenizingCharacterSet]];
        tokenCloud.tokens = [receiver tokenField:self tokensGivenCurrentTokens:tokens];
        if ([tokenCloud.tokens count]) {
            float height = [tokenCloud preferredHeightForWidth:[self bounds].size.width];
            [tokenCloudPopover setContentSize:NSMakeSize(self.frame.size.width, height)];
            [tokenCloudPopover setContentViewController:tokenCloudController];
            [tokenCloudPopover showRelativeToRect:[self bounds] ofView:self preferredEdge:NSMinYEdge];
        }
    }
    return [super becomeFirstResponder];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    [tokenCloudPopover close];
    if ([((JSMessageInterceptor *)self.delegate).receiver respondsToSelector:@selector(controlTextDidEndEditing:)]) {
        [((JSMessageInterceptor *)self.delegate).receiver performSelector:@selector(controlTextDidEndEditing:) withObject:aNotification];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    // dirty hack to prevent the view in the popover to steal the firstResponder from us. shouldEndEditing is set to NO every time the popover is shown internally after the first time
    if (!shouldEndEditing) {
        shouldEndEditing = YES;
        return NO;
    }
    if ([((JSMessageInterceptor *)self.delegate).receiver respondsToSelector:@selector(control:textShouldEndEditing:)]) {
        id<NSControlTextEditingDelegate> receiver = ((JSMessageInterceptor *)self.delegate).receiver;
        return [receiver control:control textShouldEndEditing:fieldEditor];
    }
    return YES;
}

- (void)tokenCloud:(JSTokenCloud *)cloud didClickToken:(NSString *)str enabled:(BOOL)flag
{
    NSMutableArray *tokens = [[self objectValue] mutableCopy];
    if ([self.delegate respondsToSelector:@selector(tokenField:representedObjectForEditingString:)]) {
        [tokens addObject:[self.delegate tokenField:self representedObjectForEditingString:str]];
    } else {
        [tokens addObject:str];
    }
    [self setObjectValue:[tokens copy]];
    [cloud removeToken:str];
}

- (void)tokenCloud:(JSTokenCloud *)cloud didChangePreferredHeightTo:(float)newHeight
{
    [tokenCloudPopover setContentSize:NSMakeSize(self.frame.size.width, newHeight)];
}

-(void)changeSuggestionStringTo:(NSString *)suggestionString
{
    NSTextView *editingText = (NSTextView *)[[self window] fieldEditor:NO forObject:self];
    NSString *stringToInsert = [suggestionString substringFromIndex:[currentlyInsertedSubstring length]];
    NSUInteger insertionPoint = [editingText selectedRange].location;
    [editingText insertText:stringToInsert];
    NSRange selection = NSMakeRange(insertionPoint, [suggestionString length]);
    [editingText setSelectedRange:selection];
}

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
{
    if (!justAddedCompletionString) {
        currentlyInsertedSubstring = substring;
        NSPredicate *filterPred = [NSPredicate predicateWithFormat:@"description BEGINSWITH[cd] %@", substring];
        NSMutableArray *filteredTokens = [[[tokenCloud tokens] filteredArrayUsingPredicate:filterPred] mutableCopy];
        justAddedCompletionString = YES;
        if (![filteredTokens count]) {
            [tokenCloudPopover close];
        } else {
            NSTextView *editingText = (NSTextView *)[[self window] fieldEditor:NO forObject:self];
            NSString *completeSuggestionString = [filteredTokens objectAtIndex:0];
            NSString *suggestionString = [(NSString *)completeSuggestionString substringFromIndex:[substring length]];
            NSUInteger insertionPoint = [editingText selectedRange].location;
            [editingText insertText:suggestionString];
            NSRange selection = NSMakeRange(insertionPoint, [suggestionString length]);
            [editingText setSelectedRange:selection];
            [tokenCloud highlightToken:completeSuggestionString];
            tokenCloud.tokens = [filteredTokens copy];
            [tokenCloud displayIfNeeded];
        }
    } else justAddedCompletionString = NO;
    return nil;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index
{
    if ([((JSMessageInterceptor *)self.delegate).receiver respondsToSelector:@selector(tokenField:tokensGivenCurrentTokens:)]) {
        id<JSTokenFieldDelegate> receiver = ((JSMessageInterceptor *)self.delegate).receiver;
        tokenCloud.tokens = [receiver tokenField:self tokensGivenCurrentTokens:[self objectValue]];
        if (![tokenCloudPopover isShown] && [tokenCloud.tokens count]) {
            float height = [tokenCloud preferredHeightForWidth:[self bounds].size.width];
            [tokenCloudPopover setContentSize:NSMakeSize(self.frame.size.width, height)];
            // dirty hack to avoid the view in the popover to steal the firstResponder from us
            shouldEndEditing = NO;
            [tokenCloudPopover showRelativeToRect:[self bounds] ofView:self preferredEdge:NSMinYEdge];
        }
    }
    [tokenCloud deselectAllTokens];
    [tokenCloud displayIfNeeded];
    
    NSArray *tokensToAdd = [NSArray array];
    if ([((JSMessageInterceptor *)self.delegate).receiver respondsToSelector:@selector(tokenField:shouldAddObjects:atIndex:)]) {
        id<NSTokenFieldDelegate> receiver = ((JSMessageInterceptor *)self.delegate).receiver;
        tokensToAdd = [receiver tokenField:self shouldAddObjects:tokens atIndex:index];
    } else tokensToAdd = tokens;
    if ([tokensToAdd count]) currentlyInsertedSubstring = nil;
    return tokensToAdd;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    if (([[tokenCloud tokens] count]>1) && (tokenCloudPopover.shown)) {
        if (!strcmp((char *)command, "moveUp:")) {
            [self changeSuggestionStringTo:[tokenCloud selectPreviousToken]];
            [tokenCloud displayIfNeeded];
            return YES;
        } else if (!strcmp((char *)command, "moveDown:")) {
            [self changeSuggestionStringTo:[tokenCloud selectNextToken]];
            [tokenCloud displayIfNeeded];
            return YES;
        }
    }
    return NO;
}


@end

@import <AppKit/CPView.j>
@import <AppKit/CPTextField.j>

@implementation ToolbarSearchView : CPView {
    CPTextField   searchField     @accessors;
}

-(id)initWithFrame: (CGRect)aFrame {
    self = [super initWithFrame: aFrame];
    if(self){
        searchField = [[CPTextField alloc] initWithFrame: aFrame];
        [searchField setBezeled: YES];
        [searchField setBezelStyle: CPTextFieldRoundedBezel];
        [searchField setBordered: YES];
        [searchField setEditable: YES];
        [searchField setAutoresizingMask: CPViewWidthSizable];
        [self addSubview: searchField];
    }
    return self;
}
@end
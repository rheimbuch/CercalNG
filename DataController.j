@import <Foundation/CPObject.j>
@import "DemoData.j"

@implementation DataController : CPObject {
    CPArray data @accessors;
    CPString urlPath;
}

-(id)initWithRestPath: (CPString)aUrlPath {
    self = [self init];
    if(self){
        urlPath = aUrlPath;
    }
    return self;
}

-(id)initWithSamapleData {
    self = [self init];
    if(self) {
        [self loadExampleData];
    }
    return self;
}


-(void)loadExampleData {
    [self setData: [DemoData exampleData]];
}


@end
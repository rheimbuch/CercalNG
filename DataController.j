@import <Foundation/CPObject.j>
@import "DemoData.j"

@implementation DataController : CPObject {
    CPArray data;
    CPString urlPath;
}

-(id)initWithRestPath: (CPString)aUrlPath {
    self = [self init];
    if(self){
        urlPath = aUrlPath;
    }
    return self;
}

-(void)setData: (CPArray)someData {
    data = someData;
}

-(CPArray)data {
    return data;
}

-(void)loadExampleData {
    [self setData: [DemoData exampleData]];
}


@end
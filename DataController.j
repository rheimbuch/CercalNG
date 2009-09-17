@import <Foundation/CPObject.j>
@import "DemoData.j"
@import "DataItem.j"

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



+(DataController)withExampleData {
    var ds = [[self alloc] init];
    var exampleData = [DemoData exampleData];
    var newData = []
    for(var i in exampleData){
        newData[i] = [[DataItem alloc] initWithJSObject: exampleData[i]];
    }
    [ds setData: [[CPArray alloc] initWithArray: newData]];
    console.debug(ds);
    return ds;
}


@end
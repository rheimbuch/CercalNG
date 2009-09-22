@import <Foundation/CPObject.j>
@import "DemoData.j"
@import "DataItem.j"

dojo.require('dojox.data.PersevereStore');

@implementation DataController : CPObject {
    CPArray data @accessors;
    CPString urlPath @accessors(readonly);
    id _delegate @accessors(property=delegate);
    id _dataStore @accessors(property=dataStore,readonly);
}

-(id)initWithRestPath: (CPString)aUrlPath {
    self = [super init];
    if(self){
        data = [[CPArray alloc] init];
        urlPath = aUrlPath;
        _dataStore = new dojox.data.PersevereStore({
            target: urlPath
        });
    }
    console.debug("DataController with path: " + urlPath);
    console.debug(self);
    return self;
}

-(void)fetchAll {
    [self fetchWithQuery: ""];
}

-(void)fetchWithQuery: (CPString)jsonQuery {
    _dataStore.fetch({
        query: jsonQuery,
        onComplete: function(results) {
            console.debug("Fetch Completed");
            console.debug(self);
            console.debug(results);
            [self setData: results];
           // [self _handleFetchedData: results];
           if([_delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
               ([_delegate dataStore:self didReceiveData:data]);
        }
    });
}

// -(void)_handleFetchedData: (id)data {
//     console.debug("in _handleFetchedData");
//     console.debug(data);
//     
//     if([_delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
//         ([_delegate dataStore:self didReceiveData:data]);
//     [self setData: fetched];
// }


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
@import <Foundation/CPObject.j>
@import "DemoData.j"
@import "DataItem.j"

dojo.require('dojox.data.PersevereStore');

@implementation DataController : CPObject {
    CPArray data @accessors;
    CPString urlPath @accessors;
    CPString query @accessors;
    id _delegate @accessors(property=delegate);
    id _dataStore @accessors(property=dataStore,readonly);
}

-(id)init {
    return [self initWithRestPath: "/CercalSystem/"];
}

-(id)initWithRestPath: (CPString)aUrlPath {
    self = [super init];
    if(self){
        data = [[CPArray alloc] init];
        urlPath = aUrlPath;
        query = "";
        [self _initializeDataStore];
        
        [self addObserver: self 
                forKeyPath: "urlPath" 
                options: CPKeyValueObservingOptionNew
                context: nil];
        [self addObserver: self
                forKeyPath: "query"
                options: CPKeyValueObservingOptionNew
                context: nil];
    }
    console.debug("DataController with path: " + urlPath);
    console.debug(self);
    return self;
}


-(void)_initializeDataStore {
    if(urlPath){
        _dataStore = new dojox.data.PersevereStore({
            target: urlPath
        });
    }
}

-(void)_fetch {
    _dataStore.fetch({
        query: query,
        onComplete: function(results) {
            console.debug("Fetch Completed");
            console.debug(self);
            console.debug(results);
            [self setData: results];
           if([_delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
               ([_delegate dataStore:self didReceiveData:data]);
        }
    });
}

// Observer handler
-(void)observeValueForKeyPath:(CPString)keyPath
        ofObject:(id)object
        change:(CPDictionary)change
        context:(id)context {

    if(keyPath == "urlPath"){
        [self _initializeDataStore];
        [self _fetch];
    }
    else if(keyPath == "query"){
        [self _fetch];
    }
}

// -(void)fetchAll {
//     [self fetchWithQuery: ""];
// }
// 
// -(void)fetchWithQuery: (CPString)jsonQuery {
//     _dataStore.fetch({
//         query: jsonQuery,
//         onComplete: function(results) {
//             console.debug("Fetch Completed");
//             console.debug(self);
//             console.debug(results);
//             [self setData: results];
//            // [self _handleFetchedData: results];
//            if([_delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
//                ([_delegate dataStore:self didReceiveData:data]);
//         }
//     });
// }

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
@import <Foundation/CPObject.j>
@import "DemoData.j"
@import "DataItem.j"

dojo.require('dojox.data.PersevereStore');
dojo.require("dojox.io.xhrScriptPlugin");

@implementation DataController : CPObject {
    CPArray data @accessors;
    CPString urlPath @accessors;
    CPString query @accessors;
    id delegate @accessors;
    id dataStore @accessors(readonly);
}

-(id)init {
    self = [super init];
    if(self){
        data = [[CPArray alloc] init];
        urlPath = "";
        query = "";
        
        [self addObserver: self 
                forKeyPath: "urlPath" 
                options: CPKeyValueObservingOptionNew
                context: nil];
        [self addObserver: self
                forKeyPath: "query"
                options: CPKeyValueObservingOptionNew
                context: nil];
    }
    return self;
}

-(id)initWithRestPath: (CPString)aUrlPath {
    self = [self init];
    if(self){
        [self setUrlPath: aUrlPath]; // will trigger observer and initialize datastore  
    }
    console.debug("DataController with path: " + urlPath);
    console.debug(self);
    return self;
}


-(void)_initializeDataStore {
    if(urlPath){
        dojox.io.xhrScriptPlugin(urlPath, "callback", dojox.io.xhrPlugins.fullHttpAdapter);
        dataStore = new dojox.data.PersevereStore({
            target: urlPath
        });
    }
    else {
        dataStore = nil;
    }
}

-(void)_fetch {
    if(dataStore) {
        dataStore.fetch({
            query: query,
            onComplete: function(results) {
                console.debug("Fetch Completed");
                console.debug(self);
                console.debug(results);
                [self setData: [CPArray arrayWithArray: results]];
               if([delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
                   ([delegate dataStore:self didReceiveData:data]);
            },
            onError: function(err) {
                console.debug(err);
                if([delegate respondsToSelector:@selector(dataStore:errorOccurredOnFetch:)])
                    [delegate dataStore:self errorOccurredOnFetch: err];
            }
        });
    }
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
//     dataStore.fetch({
//         query: jsonQuery,
//         onComplete: function(results) {
//             console.debug("Fetch Completed");
//             console.debug(self);
//             console.debug(results);
//             [self setData: results];
//            // [self _handleFetchedData: results];
//            if([delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
//                ([delegate dataStore:self didReceiveData:data]);
//         }
//     });
// }

// -(void)_handleFetchedData: (id)data {
//     console.debug("in _handleFetchedData");
//     console.debug(data);
//     
//     if([delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
//         ([delegate dataStore:self didReceiveData:data]);
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
@import <Foundation/CPObject.j>
@import <Foundation/CPException.j>
@import <Foundation/CPNotificationCenter.j>
@import "DemoData.j"
@import "DataItem.j"

dojo.require('dojox.data.PersevereStore');
dojo.require("dojox.io.xhrScriptPlugin");

// DataController Exceptions
DataControllerUrlException = "DataControllerUrlException";
DataControllerSourceNotInitializedException = "DataControllerSourceNotInitializedException";

// DataController Notifications
DataControllerDidRecieveDataNotification = "DataControllerDidRecieveDataNotification";
DataControllerDidRecieveErrorNotification = "DataControllerDidRecieveErrorNotification";
DataControllerWillChangeObject = "DataControllerWillChangeObject";
DataControllerDidChangeObject = "DataControllerDidChangeObject";
DataControllerDidRevertChanges = "DataControllerDidRevertChanges";

@implementation DataController : CPObject {
    CPArray data @accessors(readonly);
    CPString urlPath @accessors;
    CPString query @accessors;
    id delegate @accessors;
    id dataStore @accessors(readonly);
}

-(id)init {
    self = [super init];
    if(self){
        data = [[CPArray alloc] init];
        
        [self willChangeValueForKey: "urlPath"];
        urlPath = "";
        [self didChangeValueForKey: "urlPath"];
        
        [self willChangeValueForKey: "query"];
        query = "";
        [self didChangeValueForKey: "query"];
        
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
    !urlPath && [CPException raise: DataControllerUrlException 
                             reason: "Data source cannot be initialized without a valid source url."];
                             
    dojox.io.xhrScriptPlugin(urlPath, "callback", dojox.io.xhrPlugins.fullHttpAdapter);
    dataStore = new dojox.data.PersevereStore({
        target: urlPath
    });

}

-(void)_fetch {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source must be initialized before a fetch can be performed."];
                               
    dataStore.fetch({
        query: query,
        onComplete: function(results) {
            console.debug("Fetch Completed");
            console.debug(self);
            console.debug(results);
            [self setData: [CPArray arrayWithArray: results]];
            
            // Notifiy delegate that data was received
            if([delegate respondsToSelector:@selector(dataStore:didReceiveData:)])
               ([delegate dataController:self didReceiveData:data]);
            
            // Broadcast notifications that data was received
            [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidRecieveDataNotification
                                                  object: self];
        },
        onError: function(err) {
            console.debug(err);
            // Notify delegate that an error occurred while retrieving data
            if([delegate respondsToSelector:@selector(dataStore:errorOccurredOnFetch:)])
                [delegate dataController:self errorOccurredOnFetch: err];
            
            // Broadcast notifications that data was received
            [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidRecieveErrorNotification
                                                  object: self];
        }
    });

}

// Track changes to data items.
-(void)willChangeObject: (JSObject)anObject {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source is not initialized"];
    
    dataStore.changing(anObject);
    
    // Notify delegate that data item will change.
    if([delegate respondsToSelector: @selector(dataController:willChangeObject:)])
        [delegate dataController: self willChangeObject: anObject];
        
    // Broadcast notification that data item will change
    [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerWillChangeObject
                                          object: self
                                          userInfo: [CPDictionary dictionaryWithJSObject: {
                                              "object": anObject
                                          }]];
}

-(void)didChangeObject: (JSObject)anObject {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source is not initialized"];
                               
    // Notify delegate that data item was changed.
    if([delegate respondsToSelector: @selector(dataController:didChangeObject:)])
       [delegate dataController: self didChangeObject: anObject];

    // Broadcast notification that data item was changed
    [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidChangeObject
                                         object: self
                                         userInfo: [CPDictionary dictionaryWithJSObject: {
                                             "object": anObject
                                         }]];
}

-(BOOL)hasUnsavedChanges {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source is not initialized"];
                               
    return dataStore.isDirty();
}

// Revert any unsaved changes to data items.
-(void)revertChanges {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source is not initialized"];
                               
    dataStore.revert();
    
    // Notify delegate that changes will be reverted.
    if([delegate respondsToSelector: @selector(dataControllerDidRevertChanges:)])
       [delegate dataControllerDidRevertChanges: self];

    // Broadcast notification that changes will be reverted
    [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidRevertChanges
                                         object: self];
}

// Save all changed data items.
-(BOOL)save {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source is not initialized"];
    
    var saved = dataStore.save();
    
    // Notify delegate that dataController will save changes.
    if([delegate respondsToSelector: @selector(dataController:didSaveChangesSuccessfully:)])
       [delegate dataController: self didSaveChangesSuccessfully: saved];

    // Broadcast notification that dataController will save changes
    [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidSaveChanges
                                         object: self
                                         userInfo: [CPDictionary dictionaryWithJSObject: {
                                              "saved": saved
                                          }]];
    return saved;
}

// Observer handler
-(void)observeValueForKeyPath:(CPString)keyPath
        ofObject:(id)object
        change:(CPDictionary)change
        context:(id)context {

    if(keyPath == "urlPath"){
        try {
            [self _initializeDataStore];
            [self _fetch];
        }
        catch(err if err.name === DataControllerUrlException) {
            console.error(err);
        }
    }
    else if(keyPath == "query"){
        try {
            [self _fetch];
        }
        catch(err if err.name === DataControllerSourceNotInitializedException) {
            console.error(err);
        }
    }
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
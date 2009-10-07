@import <Foundation/CPObject.j>
@import <Foundation/CPException.j>
@import <Foundation/CPNotificationCenter.j>

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
DataControllerDidSaveChanges = "DataControllerDidSaveChanges";
DataControllerDidRevertChanges = "DataControllerDidRevertChanges";
DataControllerDidRecieveErrorOnSave = "DataControllerDidRecieveErrorOnSave";
DataControllerDidBeginFetch = "DataControllerDidBeginFetch";
DataControllerDidCompleteFetch = "DataControllerDidCompleteFetch";

@implementation DataController : CPObject {
    CPArray data @accessors(readonly);
    CPString url @accessors;
    CPString query @accessors;
    id delegate @accessors;
    id dataStore @accessors(readonly);
    id currentUser @accessors(readonly);
}

-(id)init {
    self = [super init];
    if(self){
        data = [[CPArray alloc] init];
        
        [self willChangeValueForKey: "url"];
        url = "";
        [self didChangeValueForKey: "url"];
        
        [self willChangeValueForKey: "query"];
        query = "";
        [self didChangeValueForKey: "query"];
        
        [self addObserver: self 
                forKeyPath: "url" 
                options: CPKeyValueObservingOptionNew
                context: nil];
        [self addObserver: self
                forKeyPath: "query"
                options: CPKeyValueObservingOptionNew
                context: nil];
        [self addObserver: self
                forKeyPath: "data"
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
    console.debug("DataController with path: " + url);
    console.debug(self);
    return self;
}

-(void)reset {
    console.debug("Resetting dataController");
    [self setUrl: ""];
    [self setQuery: ""];
    [self willChangeValueForKey: "data"];
    data = [[CPArray alloc] init];
    [self didChangeValueForKey: "data"];
}

-(void)reload {
    [self _fetch];
}


-(void)_initializeDataStore {
    // !url && [CPException raise: DataControllerUrlException 
    //                          reason: "Data source cannot be initialized without a valid source url."];
    if(url) {
        dojox.io.xhrScriptPlugin(url, "callback", dojox.io.xhrPlugins.fullHttpAdapter);
        dataStore = new dojox.data.PersevereStore({
            target: url
        });
    }
    else {
        dataStore = nil;
    }

}

-(void)_fetch {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source must be initialized before a fetch can be performed."];
    
    [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidBeginFetch
                                    object: self];
    
    dataStore.fetch({
        query: query,
        onComplete: function(results) {

            console.debug("Fetch Completed");
            console.debug(self);
            console.debug(results);
            [self willChangeValueForKey: "data"];
            data =  [CPArray arrayWithArray: results];
            [self didChangeValueForKey: "data"];
            [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidCompleteFetch
                                            object: self];

        },
        onError: function(err) {
            console.debug(err);
            // Notify delegate that an error occurred while retrieving data
            if([delegate respondsToSelector:@selector(dataStore:errorOccurredOnFetch:)])
                [delegate dataController:self errorOccurredOnFetch: err];
            
            // Broadcast notifications that data was received
            [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidRecieveErrorNotification
                                                  object: self
                                                  userInfo: [CPDictionary dictionaryFromJSObject: {
                                                      "error": err,
                                                      "occurredOn": "fetch"
                                                  }] ];
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
-(void)save {
    !dataStore && [CPException raise: DataControllerSourceNotInitializedException
                               reason: "Data source is not initialized"];

    dataStore.save({
        onComplete: function() {
            // Notify delegate that dataController will save changes.
            if([delegate respondsToSelector: @selector(dataController:didSaveChanges:)])
               [delegate dataController: self didSaveChanges: YES];

            // Broadcast notification that dataController will save changes
            [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidSaveChanges
                                                 object: self];
        },
        onError: function(error) {
            alert("An error occurred saving!");
            [self revert]; // Error occurred saving, so we'll revert the changed data.
            [self reload];
            // Notify delegate that dataController save failed
            if([delegate respondsToSelector: @selector(dataController:didSaveChanges:)])
               [delegate dataController: self didSaveChanges: NO];
            
            // Notify delegate that an error occurred on save.
            if([delegate respondsToSelector: @selector(dataController:errorOccurredOnSave:)])
               [delegate dataController: self errorOccurredOnSave: error];

            // Broadcast notification that dataController had an error saving
            [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidRecieveErrorNotification
                                                 object: self
                                                 userInfo: [CPDictionary dictionaryWithJSObject: {
                                                     "error":error,
                                                     "occurredOn": "save"
                                                 }]];
        }
    });
}

// Observer handler
-(void)observeValueForKeyPath:(CPString)keyPath
        ofObject:(id)object
        change:(CPDictionary)change
        context:(id)context {

    if(keyPath == "url") {
        try {
            [self _initializeDataStore];
            [self _fetch];
        }
        catch(err) {
            if(err.name === DataControllerUrlException)
                console.error(err);
        }
    }
    else if(keyPath == "query") {
        try {
            [self _fetch];
        }
        catch(err) {
            if(err.name === DataControllerSourceNotInitializedException)
                console.error(err);
        }
    }
    else if(keyPath == "data") {
        // Notifiy delegate that data was received
        if([delegate respondsToSelector:@selector(dataController:didReceiveData:)])
           ([delegate dataController:self didReceiveData:data]);
        
        // Broadcast notifications that data was received
        [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerDidRecieveDataNotification
                                              object: self];
    }
}

@end
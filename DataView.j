@import <Foundation/Foundation.j>
@import <AppKit/CPView.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPAlert.j>

@implementation DataView : CPView {
    id          dataItem @accessors;
    id          dataStore @accessors;
    CPTableView propertyEditor;
    CPArray     dataItemKeys;
}

-(id)init {
    self = [super init];
    if(self){
        [propertyEditor setDataSource: self];
        [propertyEditor setDelegate: self];
        dataItemKeys = [[CPArray alloc] init];
    }
    return self;
}

-(void)awakeFromCib {
    [propertyEditor setDataSource: self];
    [propertyEditor setDelegate: self];
    dataItemKeys = [[CPArray alloc] init];
}

-(void)setDataItem: (id)aDataItem {
    dataItem = aDataItem;
    [dataItemKeys removeAllObjects];
    for(var i in dataItem.metadata){
        if(!/^__/.test(i)){
            [dataItemKeys addObject: i];
        }
    }
    console.debug(self);
    [propertyEditor reloadData];
}

// datasource delegate methods for TableView
-(int)numberOfRowsInTableView: (CPTableView)aTableView {
    var num = [dataItemKeys count];
    console.debug("Number of properties in dataItem = " + num);
    return num;
}

-(id)tableView: (CPTableView)aTableView
     objectValueForTableColumn: (CPTableColumn)aTableColumn
     row: (int)rowIndex {
         var key = [dataItemKeys objectAtIndex: rowIndex];
         var value = dataItem.metadata[key];
         console.debug(key,value);
         if([aTableColumn identifier] == "key") {
             return key;
         }
         else if([aTableColumn identifier] == "value") {
             return value;
         }

}

// delegate methods for TableView
-(void)tableView:(CPTableView)aTableView 
       setObjectValue:(id)objectValue
       forTableColumn:(CPTableColumn)aTableColumn
       row:(int)rowIndex {
    
    var col = [aTableColumn identifier];
    if(col == "key"){
        var origKey = [dataItemKeys objectAtIndex: rowIndex];
        var newKey = objectValue;
        [dataItemKeys replaceObject: newKey atIndex: rowIndex];
        var value = dataStore.getValue(dataItem, "metadata."+origKey);
        dataStore.setValue(dataItem, "metadata."+newKey, value);
        dataStore.unsetAttribute(dataItem, "metadata."+origKey);
    }
    else if(col == "value"){
        var key = [dataItemKeys objectAtIndex: rowIndex];
        dataStore.setValue(dataItem, "metadata."+key, objectValue);
    }
    
}






@end
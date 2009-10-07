@import <Foundation/Foundation.j>
@import <AppKit/CPView.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPAlert.j>
@import "PropertyValueEditor.j"


@implementation DataView : CPView {
    id          dataItem @accessors;
    id          dataStore @accessors;
    CPTableView propertyEditor;
    CPArray     dataItemKeys;
    PropertyValueEditor valueEditor;
}

-(id)init {
    self = [super init];
    if(self){
        [self awakeFromCib];
    }
    return self;
}

-(void)awakeFromCib {
    [propertyEditor setDataSource: self];
    [propertyEditor setDelegate: self];
    dataItemKeys = [[CPArray alloc] init];
    valueEditor = [[PropertyValueEditor alloc] init];
    [valueEditor setDelegate: self];
}


-(void)setDataItem: (id)aDataItem {
    dataItem = aDataItem;
    [dataItemKeys removeAllObjects];
    for(var i in dataItem.metadata){
        if(!/^__/.test(i)){  // Ignore private keys that start with "__"
            [dataItemKeys addObject: i];
        }
    }
    console.debug(self);
    [propertyEditor reloadData];
}

-(void)editSelected: (id)sender {
    console.debug("Editing selected Property");
    [valueEditor show: sender];
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


-(void)tableViewSelectionDidChange: (CPNotification)notification {
    var row = [[propertyEditor selectedRowIndexes] firstIndex];
    var key = dataItemKeys[row];
    var metadata = dataItem.metadata;
    var value = metadata[key];
    console.debug("dataview selection changed");
    console.debug([row, key, value]);
    console.debug(metadata);
    [valueEditor setSelectedProperty: key];
    [valueEditor setRepresentedObject: metadata];
}

// PropertyValueEditor delegate method
-(void)savedProperty: (CPString)aProperty forObject: (JSObject)anObject {
    
    [propertyEditor reloadData];
    console.debug(dataStore);
    dataStore.changing(anObject);
}




@end
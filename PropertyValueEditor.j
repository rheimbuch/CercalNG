@import <Foundation/CPObject.j>

@implementation PropertyValueEditor : CPObject {
    IBOutlet    CPTextField     propertyField;
    IBOutlet    CPTextField     valueField;
    IBOutlet    CPPanel         panel;
    
                JSObject        representedObject   @accessors;
                CPString        selectedProperty    @accessors;
                id              delegate            @accessors;
}

-(id)init {
    self = [super init];
    if(self) {
        if(![CPBundle loadCibNamed: "PropertyValueEditor" owner: self]){
            CPLog("Error loading Cib for PropertyValueEditor");
        }
        console.debug("panel loaded");
        console.debug(panel);
        [self addObserver: self forKeyPath: "representedObject" options: CPKeyValueObservingOptionNew context: nil];
        [self addObserver: self forKeyPath: "selectedProperty" options: CPKeyValueObservingOptionNew context: nil];
    }
    return self;
}

// Handle observing
-(void)observeValueForKeyPath:(CPString)keyPath
        ofObject:(id)object
        change:(CPDictionary)change
        context:(id)context {
    
    console.debug("valueEditor observer fired");
    console.debug(keyPath);
    if(keyPath == "representedObject") {
        console.debug(representedObject);
        selectedProperty && [valueField setObjectValue: representedObject[selectedProperty]];
    }
    else if(keyPath == "selectedProperty") {
        console.debug(selectedProperty);
        [propertyField setObjectValue: selectedProperty];
        representedObject && [valueField setObjectValue: representedObject[selectedProperty]];
    }

}

-(void)show: (id)sender {
    console.debug("showing value editor panel");
    //[panel makeKeyAndOrderFront: nil];
    //[CPApp runModalForWindow: panel];
    [panel center];
    [panel makeKeyAndOrderFront:self];
}


-(void)save: (id)sender {
    if(selectedProperty && representedObject) {
        representedObject[selectedProperty] = [valueField objectValue];
        [panel close];
        
        if([delegate respondsToSelector: @selector(savedProperty:forObject:)])
            [delegate savedProperty: selectedProperty forObject: representedObject];
    }
    else {
        console.error("missing property or representedObject");
    }
}

-(void)cancel: (id)sender {
    [valueField setObjectValue: representedObject[selectedProperty]];
    [panel close];
}

@end
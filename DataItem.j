@import <Foundation/Foundation.j>
@import "CPString+UUID.j"

@implementation DataItem : CPObject {
    CPDictionary    properties;
}

-(id)init {
    self = [super init];
    if(self) {
        var jsObj = {
            id: "",
            __id: "",
            __clientId: [CPString uuid],
            description: "",
            metadata: {},
            source: [],
            datafile: {}
        };
        properties = [CPDictionary dictionaryWithJSObject: jsObj recursively: YES];
    }
    return self;
}

-(id)initWithJSObject: aJSObject {
    self = [super init];
    if(self) {
        properties = [CPDictionary dictionaryWithJSObject: aJSObject recursively: YES];
    }
    return self;
}

//Alias identifer to properties.identifier
-(CPString)identifier {
    return [self valueForKeyPath: "properties.id"];
}

-(void)setIdentifier: (CPString)anIdentifier {
    [self setValue: anIdentifier forKeyPath: "properties.id"];
}
@end
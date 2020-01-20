@isTest
public with sharing class TestVenueBuilder {

    private String name = 'TestVenue';
    private String streetAddress = '221B Baker Street';
    private String town = 'London';
    private String postcode = 'NW1 6XE';
    private String type = 'Commercial/Community';
    private String subtype = 'Primary';
    private Decimal latitude = 25.0;
    private Decimal longitude = 25.0;
    private Boolean insertRecord = false;

    public TestVenueBuilder withName(String name) {

        this.name = name;

        return this;
    }

    public TestVenueBuilder withStreetAddress(String streetAddress) {

        this.streetAddress = streetAddress;

        return this;
    }

    public TestVenueBuilder withTown(String town) {

        this.town = town;

        return this;
    }

    public TestVenueBuilder withPostcode(String postcode) {

        this.postcode = postcode;

        return this;
    }

    public TestVenueBuilder withType(String type) {

        this.type = type;

        return this;
    }

    public TestVenueBuilder withSubtype(String subtype) {

        this.subtype = subtype;

        return this;
    }

    public TestVenueBuilder withLatitude(Decimal latitude) {

        this.latitude = latitude;

        return this;
    }

    public TestVenueBuilder withlongitude(Decimal longitude) {

        this.longitude = longitude;

        return this;
    }

    public TestVenueBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }

    public Venue__c build(){

        Venue__c testVenue = new Venue__c(
            Name = this.name,
            Street_Address__c = this.streetAddress,
            Postcode__c = this.postcode,
            Type__c = this.type,
            Town__c = this.town,
            Subtype__c = this.subtype,
            Location__latitude__s = this.latitude,
            Location__longitude__s = this.longitude
        );

        if(this.insertRecord){
            insert testVenue;
        }

        return testVenue;
    }
}
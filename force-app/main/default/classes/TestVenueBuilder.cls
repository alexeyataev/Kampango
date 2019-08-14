@isTest
public with sharing class TestVenueBuilder {

    private String name = 'TestVenue';
    private String streetAddress = '221B Baker Street';
    private String town = 'London';
    private String postcode = 'NW1 6XE';
    private String type = 'Commercial';
    private String subtype = 'Primary';
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

    public TestVenueBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }

    public Venue__c build(){

        Venue__c testVenue = new Venue__c(
            Name = this.Name,
            Street_Address__c = this.StreetAddress,
            Postcode__c = this.Postcode,
            Type__c = this.Type,
            Town__c = this.Town,
            Subtype__c = this.Subtype
        );

        if(this.insertRecord){
            insert testVenue;
        }

        return testVenue;
    }
}
@isTest
public with sharing class TestVenueBuilder {

    private final String PHYSICAL_VENUE = 'Physical';
	private final String VIRTUAL_VENUE = 'Virtual';
    private Account branch;
    private String name = 'TestVenue';
    private String streetAddress = '221B Baker Street';
    private String town = 'London';
    private String postcode = 'NW1 6XE';
    private String type = 'Commercial/Community';
    private String subtype = 'Primary';
    private String clientLink;
    private String hostUsername;
    private String hostPassword;
    private Decimal latitude = 50.501;
    private Decimal longitude = -0.101;
    private Boolean isVirtualVenue = false;
    private Boolean insertRecord = false;

    public TestVenueBuilder withName(String name) {
        this.name = name;
        return this;
    }

    public TestVenueBuilder withBranch(Account branch){
        this.branch = branch;
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

    public TestVenueBuilder isVirtualVenue(Boolean isVirtualVenue) {
        this.isVirtualVenue = isVirtualVenue;
        if (isVirtualVenue) {
            clientLink = 'https://zoom.us/xxx';
            hostUsername = 'JohnDoe';
            hostPassword = '1234567';
        }
        return this;
    }

    public TestVenueBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }

    public Venue__c build(){

        Venue__c testVenue = new Venue__c(
            Name = this.name,
            Branch__c = this.branch.Id,
            Street_Address__c = this.streetAddress,
            Postcode__c = this.postcode,
            Client_Link__c = this.clientLink,
            Host_Username__c = this.hostUsername,
            Host_Password__c = this.hostPassword,
            Type__c = this.type,
            Town__c = this.town,
            Subtype__c = this.subtype,
            Location__latitude__s = this.latitude,
            Location__longitude__s = this.longitude,
            RecordTypeId = isVirtualVenue ? Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get(VIRTUAL_VENUE).getRecordTypeId()
                        : Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get(PHYSICAL_VENUE).getRecordTypeId()
        );

        if(this.insertRecord){
            insert testVenue;
        }

        return testVenue;
    }
}

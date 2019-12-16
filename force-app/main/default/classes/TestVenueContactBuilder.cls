@isTest
public with sharing class TestVenueContactBuilder {

    private String name = 'TestVenueComtact';
    private String type = 'Emergency';
    private Venue__c venue;
	private Contact contact;
    private Boolean insertRecord = false;

    public TestVenueContactBuilder withName(String name) {

        this.name = name;

        return this;
    }

    public TestVenueContactBuilder withType(String type) {

        this.type = type;

        return this;
    }

    public TestVenueContactBuilder withContact(Contact contact)
	{
		this.contact = contact;
		return this;
	}


    public TestVenueContactBuilder withVenue(Venue__c venue)
	{
		this.venue = venue;
		return this;
	}


    public TestVenueContactBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }

    public Venue_Contact__c build(){

        Venue_Contact__c testVenueContact = new Venue_Contact__c(
            Name = this.name,
            Type__c = this.type,
            Contact__c = this.contact.Id,
            Venue__c = this.venue.Id
        );

        if(this.insertRecord){
            insert testVenueContact;
        }

        return testVenueContact;
    }
}
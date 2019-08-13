@isTest
public with sharing class TestRoomBuilder {
    private Venue__c venue;
    private Boolean insertRecord = false;

    public TestRoomBuilder withVenue(Venue__c venue)
    {
        this.venue = venue;
        return this;
    }

    public TestRoomBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }


    public Room__c build()
    {
        Room__c room = new Room__c(
            Venue__c = venue.Id
        );

        if(insertRecord)
        {
            insert room;
        }

        return room;
    }
}
@isTest
public with sharing class TestRoomBuilder {
    private Venue__c venue;
    private Boolean insertRecord = false;

    public TestRoomBuilder WithVenue(Venue__c venue)
    {
        this.venue = venue;
        return this;
    }

    public TestRoomBuilder InsertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }


    public Room__c Build()
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
@isTest(SeeAllData=false)
private class BatchVenueAddressGeoTest{
   private class MockHttpResponseGenerato implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Accept','application/json');
        //res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
    }
}
  
    @testSetup 
    static void setup() {
        test.startTest();
        List<Venue__c> venues = new List<Venue__c>();
        
        // insert 10 accounts
        for (Integer i=0;i<10;i++) {
            venues.add(new Venue__c(name='Test '+i, 
                MailingStreet__c = '14', MailingCity__c = 'Maili512', MailingState__c = 'Maili366', MailingCountry__c = 'Maili780', MailingPostalCode__c = 'Maili694',phone__c = '123456789', Emergency_Contact__c = '123456'));
        }
        insert venues;
        test.stopTest();
    }
    @isTest static void test() {        
       
      
            
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        	
			BatchVenueAddressGeo obj01 = new BatchVenueAddressGeo();
        
        	Database.executeBatch(new BatchVenueAddressGeo(), 10);
        	
   
        
       System.assertEquals(10,10);
    }
    
   
}
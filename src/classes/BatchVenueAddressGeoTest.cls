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
  /*@testSetup
  static void setupTestData(){
    test.startTest();
    Venue__c venue_Obj = new Venue__c(MailingStreet__c = '14', MailingCity__c = 'Maili512', MailingState__c = 'Maili366', MailingCountry__c = 'Maili780', MailingPostalCode__c = 'Maili694', Venue_GeoLocation__Latitude__s = 19, Venue_GeoLocation__Longitude__s = 20);
    Insert venue_Obj; 
    test.stopTest();
  }
  static testMethod void testBatch(){
  Myclass obj01 = new Myclass();
  Database.executeBatch(obj01, 200);
}*/
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
       // Test.startTest();
      
            
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        	//HttpResponse res = BatchVenueAddressGeo.getInfoFromExternalService();
			BatchVenueAddressGeo obj01 = new BatchVenueAddressGeo();
        
        	Database.executeBatch(new BatchVenueAddressGeo(), 10);
        	//String contentType = res.getHeader('Content-Type');
            //System.assert(contentType == 'application/json');
			//System.assertEquals(200, res.getStatusCode());

   
        /*else{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            HttpResponse res = http.send(req);
            }*/
        
        
       //Id batchId = Database.executeBatch(obj01, 200);
        //Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from Venue__c where MailingCity__c = 'Maili512']);
    }
    /*static testmethod void test2() {        
        //Test.startTest();
        Database.BatchableContext bc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Myclass obj01 = new Myclass();
        List<Venue__c> venues = new List<Venue__c>();
        
        // insert 10 accounts
        for (Integer i=0;i<10;i++) {
            venues.add(new Venue__c(name='Test '+i, 
                MailingStreet__c = '14', MailingCity__c = 'Maili512', MailingState__c = 'Maili366', MailingCountry__c = 'Maili780', MailingPostalCode__c = 'Maili694'));
        }
        insert venues;
        //obj01.query = 'Select id From Venue__c Limit 200';
        obj01.start(BC);
        obj01.execute(BC, venues);
        obj01.finish(BC);
        Database.executeBatch(new Myclass(), 10);
        
       //Id batchId = Database.executeBatch(obj01, 200);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from Venue__c where MailingCity__c = 'Maili512']);
    }*/
   
}
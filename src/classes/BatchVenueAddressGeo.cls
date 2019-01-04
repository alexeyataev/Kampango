global class BatchVenueAddressGeo implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful 
{    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string query ='SELECT MailingStreet__c, MailingCity__c, MailingState__c, MailingCountry__c, MailingPostalCode__c, Venue_GeoLocation__Latitude__s, Venue_GeoLocation__Longitude__s FROM Venue__c where phone__c != null and Emergency_Contact__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Venue__c> scope)
    {
        
        // process each batch of records
       // List<Venue__c> venue = new List<Venue__c>();
        
        for (Venue__c geoVenue : scope) {
            if(geoVenue.Venue_GeoLocation__Latitude__s == null){
                      String geoAddress = '';
              if(geoVenue.MailingStreet__c != null)
                geoAddress+= geoVenue.MailingStreet__c + ', ';
              if(geoVenue.MailingCity__c != null)
                geoAddress+= geoVenue.MailingCity__c + ', ';
              if(geoVenue.MailingState__c != null)
                geoAddress+= geoVenue.MailingState__c + ', ';
              if(geoVenue.MailingCountry__c != null)
                geoAddress+= geoVenue.MailingCountry__c + ', ';
              if(geoVenue.MailingPostalCode__c != null)
                geoAddress+= geoVenue.MailingPostalCode__c;
              
              //encode the string so we can pass it as part of URL
              geoAddress= EncodingUtil.urlEncode(geoAddress, 'UTF-8');
              //build and make the callout to the Geocoding API
              Http http = new Http();
              HttpRequest request = new HttpRequest();
                //https://geocoder.api.here.com/6.2/geocode.xml?app_id={YOUR_APP_ID}&app_code={YOUR_APP_CODE}&searchtext=425+W+Randolph+Chicago
               // https://geocoder.api.here.com/6.2/geocode.json?searchtext='+geoAddress+'&app_id=7j1reaxRvR9EH3MyZbgs&app_code=_rUgjj_n8Z9v3yofciRVUg&gen=9
              request.setEndpoint('https://geocoder.api.here.com/6.2/geocode.json?app_id=7j1reaxRvR9EH3MyZbgs&app_code=_rUgjj_n8Z9v3yofciRVUg&searchtext='+geoAddress);
              request.setMethod('GET');
              request.setHeader('Content-Type', 'application/json');
              request.setHeader('Accept','application/json');
              request.setTimeout(60000);
              
                //make the http callout
                HttpResponse response = http.send(request);
                //parse JSON to extract co-ordinates
                JSONParser responseParser = JSON.createParser(response.getBody());
                //initialize co-ordinates
                decimal latitude = null;
                decimal longitude = null;
                while(responseParser.nextToken() != null) {
                  if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) &&(responseParser.getText()== 'location')) {
                    responseParser.nextToken();
                    while(responseParser.nextToken() != JSONToken.END_OBJECT) {
                     
                    String locationText = responseParser.getText();
                             
                    responseParser.nextToken();
                     
                    if (locationText == 'latitude')
                               
                    latitude = responseParser.getDecimalValue();
                             
                    else if (locationText == 'longitude')          
                    longitude = responseParser.getDecimalValue();
                        System.debug('long'+longitude);
                    }
                  }
                }
                //update co-ordinates on address if we get them back
                if(latitude != null) {
                  geoVenue.Venue_GeoLocation__Latitude__s= latitude;
                  geoVenue.Venue_GeoLocation__Longitude__s = longitude;
                  //venue.add(geoVenue);
                  System.debug('geovenue'+geoVenue);
                }  
            }
            
        }
        
        update scope;
        //update contacts;
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
       // EmailUtils.sendMessage(a, recordsProcessed);
    }    
}
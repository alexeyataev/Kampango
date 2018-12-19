trigger geocodeVenueAddress on Venue__c (after insert, after update) {
    //bulkify trigger in case of multiple accounts
  for(Venue__c venue : trigger.new) {
  
    //check if Billing Address has been updated
    Boolean addressChangedFlag = false;
    if(Trigger.isUpdate) {
      Venue__c oldVenue = Trigger.oldMap.get(venue.Id);
       
      //if((venue.MailingStreet__c != oldVenue.MailingStreet__c) ||(venue.MailingCity__c!= oldVenue.MailingCity__c) ||(venue.MailingState__c!= oldVenue.MailingState__c)||(venue.MailingCountry__c!= oldVenue.MailingCountry__c) ||(venue.MailingPostalCode__c!= oldVenue.MailingPostalCode__c)) {
         
      addressChangedFlag = true;
         
        System.debug(LoggingLevel.DEBUG, '***Address changed for - ' +oldVenue.Name);
      //}
    }
    // if address is null or has been changed, geocode it
    if((venue.Venue_GeoLocation__Latitude__s == null) || (addressChangedFlag == true)) {
      System.debug(LoggingLevel.DEBUG,'***Geocoding Account - ' + account.Name);
      VenueAddressGeo.DoAddressGeocode(venue.id);
    }
  }
}
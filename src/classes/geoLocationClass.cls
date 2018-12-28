public class Geolocationclass 
{
	@future (callout=true)  // future method needed to run callouts from Triggers
    static public void getLocation(set<string> postCodeSet)
	{
        list<Venue__c> updateVenueList = new list<Venue__c>();
      list<Venue__c> vnuList = [SELECT Id, Name, MailingCity__c,MailingCountry__c,MailingStreet__c,
                          		MailingState__c,MailingPostalCode__c,MailingLatitude__c,MailingLongtitude__c FROM Venue__c 
                                WHERE MailingPostalCode__c in: postCodeSet and MailingLatitude__c = null and MailingLongtitude__c = null limit 1];
        system.debug('*#*#*#* vnuList  =  ' + vnuList);
        if(vnuList != null && !vnuList.isEmpty())
        {
            for(Venue__c vnu : vnuList)
            {
                String address = '';
                if (vnu.MailingStreet__c != null)
                    address += vnu.MailingStreet__c +', ';
                if (vnu.MailingCity__c != null)
                    address += vnu.MailingCity__c +', ';
                if (vnu.MailingState__c != null)
                    address += vnu.MailingState__c +' ';
                if (vnu.MailingPostalCode__c != null)
                    address += vnu.MailingPostalCode__c +', ';
                if (vnu.MailingCountry__c != null)
                    address += vnu.MailingCountry__c;
                address = EncodingUtil.urlEncode(address, 'UTF-8');
                system.debug('*$*$*$* address   ' + address);
                Http htp = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false&key=AIzaSyAHlPCcF8AeydzXWgGd9aYC8CDo1ZR7pKY');
                req.setMethod('GET');
                req.setTimeout(60000);
        
                HttpResponse res = htp.send(req);
                JSONParser parser = JSON.createParser(res.getBody());
                double lat = null;
                double lon = null;
                system.debug(parser.getText() + '   *$*$*$* parser.nextToken() =   ' + parser.nextToken() + '   *$*$*$* parser.getCurrentToken() =   ' + parser.getCurrentToken());
                while (parser.nextToken() != null) 
                {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location'))
                    {
                        system.debug('*$*$*$*$  parser.nextToken()   ' + parser.nextToken());
                        parser.nextToken(); // object start
                        while (parser.nextToken() != JSONToken.END_OBJECT)
                        {
                            system.debug('*$*$*$*$  parser.getText()   ' + parser.getText());
                            String txt = parser.getText();
                            parser.nextToken();
                            if (txt == 'lat')
                            {
                                system.debug('*$*$*$*$  parser.getDoubleValue()   ' + parser.getDoubleValue());
                                lat = parser.getDoubleValue();
                            }
                            else if (txt == 'lng')
                            {
                                system.debug('*$*$*$*$  parser.getDoubleValue()   ' + parser.getDoubleValue());
                                lon = parser.getDoubleValue();
                            }
                        }
                    }
                }
                if (lat != null)
                {
                    vnu.Venue_GeoLocation__latitude__s = lat;
                    vnu.MailingLatitude__c = lat;
                    vnu.Venue_GeoLocation__longitude__s = lon;
                    vnu.MailingLongtitude__c = lon;
                    updateVenueList.add(vnu);
                } 
            }
             
        }
        system.debug('*$*$*$* updateVenueList   ' + updateVenueList);
        if(updateVenueList != null && !updateVenueList.isEmpty())
        {            
            update updateVenueList;
            system.debug('*$*$*$* upRecords got updated');
        }
       
        //try
        //{
		//} 
		//catch (Exception e) 
		//{
		//}   
    }
}

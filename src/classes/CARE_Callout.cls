@RestResource(urlMapping='/CARE/*')
global class CARE_Callout 
{
    @Httpget
    global static void CARE_Request()
    {
        try
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://careservices.nct.org.uk:1443/AuthStaging/SFChangeLogWS.pl?date=2018-08-31&authKey=PfgAPh5XMVDkLQBS3HMbnAJe-fh4rEaZ4HUJ&pageName=Testcallfromdocumentation');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(response.getBody());
        }
        Catch (Exception ex)
        {
            system.debug('Error Message is' + ex.getMessage());
        }
    }
}
public with sharing class FindNearbyController{
    public List<Account> contacts{ get; private set; }
    public String currentPosition { 
        get {
            if (String.isBlank(currentPosition)) {
                currentPosition = '37.77493,-122.419416'; // San Francisco
            }
            return currentPosition;
        }
        set; 
    }    
    public Boolean resultsAvailable {
        get {
            if(contacts == Null) {
                return false;
            }
            return true;
        }
    }
    
    public PageReference findNearby() {
        String lat, lon;
        
        // FRAGILE: You'll want a better lat/long parsing routine
        // Format: "<latitude>,<longitude>" (must have comma, but only one comma)
        List<String> latlon = currentPosition.split(',');
        lat = latlon[0].trim();
        lon = latlon[1].trim();
        
        // SOQL query to get the nearest Contacts
        String queryString =
        'SELECT Id, Name, Phone, Address_Latitude__c, Address_Longitude__c ' +
        'FROM Account ' +
        'WHERE DISTANCE(BillingAddress, GEOLOCATION('+lat+','+lon+'), \'mi\') < 20 ' +
        'ORDER BY DISTANCE(BillingAddress, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
        'LIMIT 10';
        System.Debug('>>>> the value of queryString is ' + queryString);
        // Run the query
        
        contacts = database.query(queryString);        
        return null;
    }
}
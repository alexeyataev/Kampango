public with sharing class CourseVenueController {
    public Decimal miles {get; set;}
    public boolean test {get; set;}
    public boolean test1 {get; set;}
    public boolean test2 {get; set;}
    public boolean test3 {get; set;}
    public String courseTypes {get; set;}
    private integer totalRecs = 0;
    private static Boolean geocodingCalled = false;
    public String currentPosition { get; set;}
        /*get {
            if (String.isBlank(currentPosition)) {
                currentPosition = ''; // San Francisco 51.4376,-0.0927
            }
            return currentPosition;
        }
        set; */
    //}  
    public Boolean resultsAvailable {
        get {
            if(Courses == Null) {
                return false;
            }
            return true;
        }
    }
    public Boolean lstresultsAvailable {
        get {
            if(Courses == Null) {
                return false;
            }
            return true;
        }
    }
    // public decimal miles=20;
    public list<String> postCode {get; set;}
    public Date BDate {get; set;}
    public Course__c cs{get; set;}
    public List<Course__c> Courses {get; private set;}
    //lat = 51.5032;
    
    //list<PostCode_Allocation__c> postcodes = [SELECT Branch__r.Name FROM PostCode_Allocation__c where Name = :postCode limit 1];                         
   // public final Decimal lat =[SELECT Branch__r.Address_Latitude__c FROM PostCode_Allocation__c where Name = :postCode];
    //lon = -0.1262;
    
    public boolean Match{get; set;}
    String units ='mi';
    //Date CBDate = BDate.format('YYYY-MM-DD');
    //Integer dist;
    //lt = [SELECT Branch__r.Address_Latitude__c,Branch__r.Address_Longitude__c, Id FROM PostCode_Allocation__c where Name =:postCode limit 1];
 	
 
	//Decimal lat = lt.Branch__r.Address_Latitude__c;
   // Decimal lon = lt.Branch__r.Address_Longitude__c;
    public CourseVenueController(){
       
        List<Course__c> Courses = new List<Course__c>();
        cs = new Course__c();
        miles = 0;
        //lat = 51.5032;
        //lon = -0.1262;
        
            //e1 = e;
        
       // Courses =[SELECT Id, Name,Course_Name__c ,Course_Type__c, Venue__c, Venue__r.BillingLatitude, Venue__r.BillingLongitude FROM Course__c WHERE DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')< 5 ORDER BY DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')];
    }
    public void CourseList(){
        Match=false;
        Decimal lat, lon;
        if(test == true){
            miles = 1;
        }
        else if(test1 == true){
            miles = 5;
        }
        else if(test2 == true){
            miles = 10;
        }
        else if(test3 == true){
            miles = 20;
        }
        else{
            miles = 0;
        }
        if(Courses!=Null){
            Courses.clear();
        }
        String geoAddress = currentPosition;
        
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
          lat = latitude;
          lon = longitude;
        }
        // FRAGILE: You'll want a better lat/long parsing routine
        // Format: "<latitude>,<longitude>" (must have comma, but only one comma)
        //List<PostCode_Allocation__c> latlon = [SELECT Id, PLatitude__c, PLongitude__c, Name FROM PostCode_Allocation__c where Name =:currentPosition];
        if(currentPosition == NULL || currentPosition == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a Postal Code'));
        }
        //else if(latlon.isEmpty()){
        //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a valid Postal Code'));
        //}
        //if(latlon.size()>0){
        //lat = latlon[0].PLatitude__c;
        //lon = latlon[0].PLongitude__c;
       
       /* Decimal lt = Decimal.valueOf(lat);
        Decimal ln = Decimal.valueOf(lon);
        //lat =51.5032;
        //lon =-0.1262;*/
        System.debug('lat: '+lat);
        System.debug('lon: '+lon);
		System.debug('Test:'+miles);
        System.debug('Test Date:'+BDate);
        
         String queryString =
        'SELECT Id, Name,Course_Name__c ,Course_Type__c,Status__c,Venue__r.Name, Venue__r.Venue_GeoLocation__Latitude__s, Venue__r.Venue_GeoLocation__Longitude__s ' +
        'FROM Course__c ' +
        'WHERE (DISTANCE(Venue__r.Venue_GeoLocation__c ,GEOLOCATION('+lat+','+lon+'), \'mi\')< :miles) and ((FEnd_Date__c  >= :BDate and FEnd_Date__c   <= :BDate)or(FStart_Date__c  >= :BDate and FStart_Date__c <= :BDate)or(FStart_Date__c  <= :BDate and FEnd_Date__c >= :BDate)) and (Course_Name__c = :courseTypes) ORDER BY DISTANCE(Venue__r.Venue_GeoLocation__c,GEOLOCATION('+lat+','+lon+'), \'mi\')';
        
        System.Debug('>>>> the value of queryString is ' + queryString);
        // Run the query
        
        Courses = database.query(queryString); 
       
    }
    
}
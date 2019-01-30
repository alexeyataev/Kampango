public with sharing class CourseSearchEnquireController {
    //public Decimal miles {get; set;}
    public Decimal lat{get; set;}
    public Decimal lon{get;set;}
    
    public integer pagesize {get;set;}
    public integer pagenumber {get;set;}
    public integer recordcount {get;set;}
	
    private static Boolean geocodingCalled = false;
    public String currentPosition { get; set;}
        
    public Boolean resultsAvailable {
        get {
            if(courses == Null) {
                return false;
            }
            return true;
        }
    }
    public Boolean lstresultsAvailable {
        get {
            if(courses == Null) {
               return false;
            }
            return true;
        }
    }
    public list<String> postCode {get; set;}
    public Date bDate {get; set;}
    public Course__c cs{get; set;}
    public List<Course__c> courses {get{
        try {
            
            return courses;
        }
        catch (QueryException e) {
            ApexPages.addMessages(e);   
            return null;
        }
    } private set;}
    
    public Decimal miles =5;
    public boolean match{get; set;}
    String units ='mi';
    
    public CourseSearchEnquireController(){
        pagesize = 5;
        pagenumber = 1; 
        
        recordcount = [select count() from Course__c]; 
        List<Course__c> courses = new List<Course__c>();
        cs = new Course__c();
        miles = 20;
        
        
       
    }
    public integer pageindex {
        get { return (pagenumber - 1); }
    }    
      
    public integer pagecount {
        get { return getpagecount(); }
    }
      
    public integer offset {
        get { return (pagesize * pageindex); }
    }
    
    public void courselist(){
        match=false;
        
        
        if(courses!=Null){
            courses.clear();
        }
        String geoAddress = currentPosition.trim();
        
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
        
        if(currentPosition == NULL || currentPosition == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a Postal Code'));
        }
       
        System.debug('lat: '+lat);
        System.debug('lon: '+lon);
		System.debug('Test:'+miles);
        System.debug('Test Date:'+bDate);
        if(lat != null){
        
        String queryString = 'SELECT Id, Name, Course_Name__c , Course_Type__c, Status__c, Start_Date__c, End_Date__c,Venue__r.Name, Venue__r.MailingCountry__c, Venue__r.MailingState__c, Venue__r.MailingCity__c, Venue__r.MailingStreet__c, Venue__r.MailingPostalCode__c, Venue__r.Venue_GeoLocation__Latitude__s, Venue__r.Venue_GeoLocation__Longitude__s ' +
        'FROM Course__c ' +
        'WHERE (DISTANCE(Venue__r.Venue_GeoLocation__c ,GEOLOCATION('+lat+','+lon+'), \'mi\')< :miles) and ((Start_Date__c >=:bDate AND Start_Date__c <=:bDate) OR (End_Date__c >=:bDate AND End_Date__c <=:bDate) OR (Start_Date__c <=:bDate AND End_Date__c >=:bDate)) ORDER BY DISTANCE(Venue__r.Venue_GeoLocation__c,GEOLOCATION('+lat+','+lon+'), \'mi\') LIMIT : pagesize OFFSET :offset ';
        
            
        System.Debug('>>>> the value of queryString is ' + queryString);
            courses = database.query(queryString); 
           
         }
         else
         {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a valid Postal Code'));
         }
            
    }
    
	public integer lNumber {
        get { return recordcount == 0 ? 0 : (offset + 1); }
    }
  
    public integer uNumber {
        get { 
            integer iUNum = ((lNumber + PageSize) - 1);
            return (iUnum > recordcount) ? recordcount : iUNum; 
        }
    }
      
    public boolean allowMoveNext {
        get{ return ((pageindex + 1) < pagecount); } } public boolean allowMovePrev { get{ return (pageindex > 0); }
    }
      
    public void prev() {
        pagenumber --;
  
        if (pagenumber <= 0) { 
            pagenumber = 1; 
        }
        courselist();
    } 
    public void next() { 
        pagenumber++; 
        if (pagenumber > pagecount) {
            pagenumber = pagecount;
            
        }
        courselist();
    }
      
    public void last() {
        pagenumber = pagecount; 
        courselist();
    }
  
    public void first() {
        pagenumber = 1;
        courselist();
    }
      
    private integer getpagecount() {
        integer iPageCount = 1;
  
        if (recordcount != 0 && pagesize != 0) {
            iPageCount = (recordcount/PageSize) + ((Math.mod(recordcount, PageSize)) > 0 ? 1 : 0);
        }
        return iPageCount;
    }
}

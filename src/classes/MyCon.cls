public with sharing class MyCon {
  public Decimal miles {get; set;}
    public String courseTypes {get; set;}
    private integer totalRecs = 0;
    
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
    public Date bdate {get; set;}
    public Course__c cs{get; set;}
    public List<Course__c> courses {get; private set;}
    
    
    public boolean match{get; set;}
    String units ='mi';
    
    public mycon(){
       
        List<Course__c> courses = new List<Course__c>();
        cs = new Course__c();
        miles = 0;
        
    }
    	
        Decimal lat;
        Decimal lon;
        
        
        // FRAGILE: You'll want a better lat/long parsing routine
        // Format: "<latitude>,<longitude>" (must have comma, but only one comma)
        List<PostCode_Allocation__c> latlon = [SELECT Id, PLatitude__c, PLongitude__c, Name FROM PostCode_Allocation__c where Name =:currentPosition];
        
        
       
       
        
     public pagereference courselists()
    {
        
        
        
        pagereference pr = new pagereference('/apex/Page2');
        return pr;
        
    }
    public void courselist(){
        
        if(courses!=Null){
            courses.clear();
        }
        if(currentPosition == NULL || currentPosition == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a Postal Code'));
        }
        else if(latlon.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a valid Postal Code'));
        }
        if(latlon.size()>0){
        lat = latlon[0].PLatitude__c;
        lon = latlon[0].PLongitude__c;
          System.debug('lat: '+lat);
        System.debug('lon: '+lon);
		System.debug('Test:'+miles);
        System.debug('Test Date:'+BDate);
         String queryString =
        'SELECT Id, Name,Course_Name__c ,Course_Type__c,Status__c, FAddress_Latitude__c, FAddress_Longitude__c ' +
        'FROM Course__c ' +
        'WHERE (DISTANCE(Branch__r.BillingAddress,GEOLOCATION('+lat+','+lon+'), \'mi\')< :miles) and ((FEnd_Date__c  >= :BDate and FEnd_Date__c   <= :BDate)or(FStart_Date__c  >= :BDate and FStart_Date__c <= :BDate)or(FStart_Date__c  <= :BDate and FEnd_Date__c >= :BDate)) and (Course_Name__c = :courseTypes) ORDER BY DISTANCE(Branch__r.BillingAddress,GEOLOCATION('+lat+','+lon+'), \'mi\')';
        
        System.Debug('>>>> the value of queryString is ' + queryString);
        // Run the query
        
        courses = database.query(queryString); 
        }
        else{
            
          
       
        }
        
      	
       
    }
    
    
}

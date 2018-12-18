public with sharing class mycon {
  public Decimal miles {get; set;}
    public String courseTypes {get; set;}
    private integer totalRecs = 0;
    
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
    public mycon(){
       
        List<Course__c> Courses = new List<Course__c>();
        cs = new Course__c();
        miles = 0;
        //lat = 51.5032;
        //lon = -0.1262;
        
            //e1 = e;
        
       // Courses =[SELECT Id, Name,Course_Name__c ,Course_Type__c, Venue__c, Venue__r.BillingLatitude, Venue__r.BillingLongitude FROM Course__c WHERE DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')< 5 ORDER BY DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')];
    }
    	//Match=false;
        Decimal lat, lon;
        
        
        // FRAGILE: You'll want a better lat/long parsing routine
        // Format: "<latitude>,<longitude>" (must have comma, but only one comma)
        List<PostCode_Allocation__c> latlon = [SELECT Id, PLatitude__c, PLongitude__c, Name FROM PostCode_Allocation__c where Name =:currentPosition];
        
        
       
       /* Decimal lt = Decimal.valueOf(lat);
        Decimal ln = Decimal.valueOf(lon);
        //lat =51.5032;
        //lon =-0.1262;*/
        
     public pagereference CourseLists()
    {
        //date3 = date1;
        //date4 = date2;
        
        
        pagereference pr = new pagereference('/apex/Page2');
        return pr;
        
    }
    public void CourseList(){
        
        if(Courses!=Null){
            Courses.clear();
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
        
        Courses = database.query(queryString); 
        }
        else{
            
          
        //return null;
        }
        
      	//return null;
        //return null;
        //if(distances==20){
        	//Courses =[SELECT Id, Name,Course_Name__c ,Course_Type__c,Status__c, Venue__c, Venue__r.BillingLatitude, Venue__r.BillingLongitude FROM Course__c WHERE (DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lt,:ln), 'mi')< :miles) and ((FEnd_Date__c  >= :BDate and FEnd_Date__c   <= :BDate)or(FStart_Date__c  >= :BDate and FStart_Date__c <= :BDate)or(FStart_Date__c  <= :BDate and FEnd_Date__c >= :BDate)) and (Course_Name__c = :courseTypes) ORDER BY DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')];
		//}
        /*if(Courses.size()>0){
            Match=true;
        }
        return null;*/
       
    }
    
    
}
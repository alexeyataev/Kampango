public with sharing class PostControl {
    //public Decimal miles {get; set;}
    //public String courseTypes {get; set;}
    //private integer totalRecs = 0;
    //private static Boolean geocodingCalled = false;
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
    public decimal miles=20;
    public list<String> postCode {get; set;}
    public Date bDate {get; set;}
    public Course__c cs{get; set;}
    public List<Course__c> Courses {get; private set;}
    //lat = 51.5032;
    
    //list<PostCode_Allocation__c> postcodes = [SELECT Branch__r.Name FROM PostCode_Allocation__c where Name = :postCode limit 1];                         
   // public final Decimal lat =[SELECT Branch__r.Address_Latitude__c FROM PostCode_Allocation__c where Name = :postCode];
    //lon = -0.1262;
    
    public boolean match{get; set;}
    String units ='mi';
    
    
	public Boolean showResult{get;set;}
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public ApexPages.StandardSetController setCon{get;set;}    
    public List<SelectOption> paginationSizeOptions{get;set;}
  //public String Name {get; set;}
  //public DateTime bDate {get; set;}
  //public list<Course__c> courses {get; set;}
    
    public PostControl(){
         size=10; //default page size

  //pagination size options
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('30','30'));
    }
    
    public pagereference Go(){
        pagereference pr = new pagereference('/apex/Post2');
        return pr;
        //listCourse();
    }
    public void listCourse(){
       //Courses =[SELECT Id, Name, Course_Type__c, Course_Name__c, Venue__c, Status__c FROM Course__c];
       //Courses=[SELECT Id, Name, Course_Type__c, Course_Name__c, Venue__c, Status__c FROM Course__c LIMIT:rec OFFSET:count];

              //build SOQL query string
             String query='SELECT Id, Name, Course_Type__c, Course_Name__c, Venue__c, Status__c FROM Course__c';
    
               //return querylocator to an instance of StandardSetController
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));            
                if(setCon.getResultSize() >0)
                {
                    showResult = true;
                }else{
                    showResult = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Records Found.'));
                }        
              
          
    	}
        public List<Course__c> getCourses() 
        {
            if(setCon.getResultSize() >0)
            {
              setCon.setPageSize(size);  
              noOfRecords = setCon.getResultSize();
              return (List<Course__c>)setCon.getRecords();
            }else
            {
              return null;
            }
            //return null;
        }
      
    /**
    * refreshPageSize
    * Changes the size of Pagination.
    * @param    
    * @return void
    */
    public void refreshPageSize() 
    {
        setCon.setPageSize(size);         
    }

}
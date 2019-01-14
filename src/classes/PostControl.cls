public with sharing class PostControl {
    
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
    public decimal miles=20;
    public list<String> postCode {get; set;}
    public Date bDate {get; set;}
    public Course__c cs{get; set;}
    public List<Course__c> courses {get; private set;}
    
    
    public boolean match{get; set;}
    String units ='mi';
    
    
	public Boolean showResult{get;set;}
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public ApexPages.StandardSetController setCon{get;set;}    
    public List<SelectOption> paginationSizeOptions{get;set;}
  
    
    public PostControl(){
         size=10; //default page size

  //pagination size options
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('30','30'));
    }
    
    public pagereference go(){
        pagereference pr = new pagereference('/apex/Post2');
        return pr;
        //listCourse();
    }
    public void listCourse(){
      

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
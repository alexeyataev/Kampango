public with sharing class Pagination1Controller  
{
    public String searchString{get;set;}
    public Boolean showResult{get;set;}
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public ApexPages.StandardSetController setCon{get;set;}    
    public List<SelectOption> paginationSizeOptions{get;set;}
 
    String errorStr = '';    
         
    /**
    * FilterSearch
    * Constructor to initiate the default values at the time of Loading
    */    
    public Pagination1Controller()
    {
        size=10; //default page size

  //pagination size options
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('30','30'));
              
    }
    
    public void showAll()
    {
        try
        {
            if(String.isNotBlank(searchString))
            {  
              //build SOQL query string
             String query='Select Id,Name, account.name, stagename, ForecastCategoryName FROM Opportunity WHERE Name LIKE \'%' + searchString + '%\' order by Name LIMIT 1000';
    
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
        }catch(Exception ex)
        {
            errorStr ='Error Occured while Searching.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'errorStr:' +ex.getMessage()));
        }   
    }

    public List<Opportunity> getOpps() 
    {
        if(setCon.getResultSize() >0)
        {
          setCon.setPageSize(size);  
          noOfRecords = setCon.getResultSize();
          return (List<Opportunity>)setCon.getRecords();
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
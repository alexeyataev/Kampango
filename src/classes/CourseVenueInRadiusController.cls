public with sharing class CourseVenueInRadiusController {
    public Decimal miles {get; set;}
    public Course__c cs{get; set;}
    public List<Course__c> Courses {get; set;}
    Decimal lat = 51.5032;
	Decimal lon = -0.1262;
    public boolean Match{get; set;}
    String units ='mi';
    //Integer dist;
    
    public CourseVenueInRadiusController(){
        cs = new Course__c();
        miles = 0;
       // Courses =[SELECT Id, Name,Course_Name__c , Venue__c, Venue__r.BillingLatitude, Venue__r.BillingLongitude FROM Course__c WHERE DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')< 5 ORDER BY DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')];
    }
    public void CourseList(){
        Match=false;
		System.debug('Teast:'+miles);
        //if(distances==20){
        	Courses =[SELECT Id, Name,Course_Name__c , Venue__c, Venue__r.BillingLatitude, Venue__r.BillingLongitude FROM Course__c WHERE DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')< 5 ORDER BY DISTANCE(Venue__r.BillingAddress,GEOLOCATION(:lat,:lon), 'mi')];
		//}
        if(Courses.size()>0){
            Match=true;
        }
        
    }
}
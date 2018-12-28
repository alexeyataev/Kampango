public with sharing class CourseExtension {
	Course__c cou;
    public string myText{get; set;}
    public Booking__c bo{get; set;}
    
    public CourseExtension(ApexPages.StandardController controller){
        this.cou = (Course__c)controller.getRecord();
        bo = new Booking__c();
    }
    public pageReference save(){
        bo.Course__c= cou.Id;
        bo.Status__c ='Enquiry';
    
        insert bo;
        return null;
    }
}

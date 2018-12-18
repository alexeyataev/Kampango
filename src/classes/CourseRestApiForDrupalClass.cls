@RestResource(urlMapping='/api/Course__c/*')
global with sharing class  CourseRestApiForDrupalClass 
{
	@HttpGet
    global static list<Course__c> doGet() 
    {
        list<Course__c> returnCourseInfoList;
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String CourseInfo = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String CourseId = CourseInfo.substring(CourseInfo.lastIndexOf('=')+1);
        system.debug(CourseInfo + '  *$*$**$*$* CourseId   ' + CourseId);
        if(CourseInfo.contains('course'))
        {
            returnCourseInfoList = CourseIdSearchMethod(CourseId);
            system.debug('*$*$*$* returnCourseInfoList from Method   ' + returnCourseInfoList);
        }
        else if(CourseId.contains('location'))
        {
            returnCourseInfoList = geoLocationSearchMethod(decimal.valueOf(CourseId),decimal.valueOf(CourseId));
        }
        system.debug('*$*$*$*$* returnCourseInfoList   ' + returnCourseInfoList);
          return returnCourseInfoList;     
    }
    
    private static list<Course__c> CourseIdSearchMethod(String corsId)
    {
        system.debug('*$*$*$* corsId   ' + corsId);
        list<Course__c> CourseVenueResultList = [SELECT Branch__c,Branch__r.Branch_Code__c,Course_Name__c,Course_Type__c,
                                                Course_Identifier__c,Description__c,Duration__c,End_Date__c,End_Time__c,
                                                Id,Practitioner__c, Private__c,Start_Date__c,Start_Time__c,Status__c, 
                                                Venue_Address__c,Venue__c,Venue__r.Private__c,Venue__r.Venue_GeoLocation__latitude__s, 
                                                Venue__r.Venue_GeoLocation__longitude__s FROM Course__c WHERE Course_Identifier__c = :corsId];
        system.debug('*$*$*$* CourseVenueResultList   ' + CourseVenueResultList);
        return CourseVenueResultList;
    }
    private static list<Course__c> geoLocationSearchMethod(decimal latitudeVal, decimal longitudeVal)
    {
        list<Course__c> CourseVenueGeoList = [SELECT Branch__c,Branch__r.Branch_Code__c,Course_Name__c,Course_Type__c,
                                                Course_Identifier__c,Description__c,Duration__c,End_Date__c,End_Time__c,
                                                Id,Practitioner__c, Private__c,Start_Date__c,Start_Time__c,Status__c, 
                                                Venue_Address__c,Venue__c,Venue__r.Private__c,Venue__r.Venue_GeoLocation__latitude__s, 
                                                Venue__r.Venue_GeoLocation__longitude__s FROM Course__c 
                                              WHERE Venue__r.Venue_GeoLocation__latitude__s =: latitudeVal and Venue__r.Venue_GeoLocation__longitude__s =: longitudeVal];
        return CourseVenueGeoList;
    }
}
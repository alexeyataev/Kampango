public with sharing class DisplayCourseSessionsController {

	public Id courseId { get; set; }

    public DisplayCourseSessionsController() {}

    public List<Session__c> getSessions() {

    	system.debug('Getting sessions for ' + courseId);
        return [SELECT Name, Day__c, Start__c, End__c, Notes__c, Duration_Formatted__c, Confirmed__c 
                FROM Session__c 
                WHERE Course__c = :courseId
                ORDER BY Start__c];

    }
}
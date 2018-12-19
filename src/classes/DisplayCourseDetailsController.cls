public with sharing class DisplayCourseDetailsController {

   /* public Id courseId { get; set; }

    public DisplayCourseDetailsController() {}

    public Course__c getCourse()
    {
        List<Course__c> courseQuery = [SELECT Id,
                                            Name,
                                            Course_Type__c,
                                            Start_Date__c,
                                            End_Date__c,
                                            Fee__c,
                                            Notes__c,
                                            Venue__r.Name
                                        FROM Course__c
                                        WHERE Id = :courseId
                                        LIMIT 1];

        if(courseQuery.size() == 1)
        {
            return courseQuery.get(0);
        }

        return new Course__c();
    }*/
}
String sessionsReportName = 'Schedule of Sessions';

List<Report> sessionsReport = [SELECT Id
    FROM Report
    WHERE Name = :sessionsReportName
    LIMIT 1
];

if (sessionsReport.size() != 1) {
    return;
}

List<Course_Settings__c> courseSettings = [SELECT Id, Schedule_of_Sessions__c
    FROM Course_Settings__c
    LIMIT 1];
    
if(courseSettings.size() == 0) {
    Course_Settings__c newCourseSettings = new Course_Settings__c(
        Schedule_of_Sessions__c = sessionsReport[0].id
    );
    insert newCourseSettings;
} else {
    courseSettings[0].Schedule_of_Sessions__c = sessionsReport[0].id;
	update courseSettings;
}
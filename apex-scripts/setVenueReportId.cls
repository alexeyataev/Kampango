String reportName = 'Venue Schedule';

List<Report> venueReport = [SELECT Id
    FROM Report
    WHERE Name = :reportName
    LIMIT 1
];

if (venueReport.size() != 1) {
    return;
}

List<Course_Settings__c> courseSettings = [SELECT Id, Venue_Schedule_Report_ID__c
    FROM Course_Settings__c
    LIMIT 1];
    
if(courseSettings.size() == 0) {
    Course_Settings__c newCourseSettings = new Course_Settings__c(
        Venue_Schedule_Report_ID__c = venueReport[0].id
    );
    insert newCourseSettings;
} else {
    courseSettings[0].Venue_Schedule_Report_ID__c = venueReport[0].id;
	update courseSettings;
}


String sessionsReportName = 'Schedule of Sessions';

List<Report> sessionsReport = [SELECT Id
    FROM Report
    WHERE Name = :sessionsReportName
    LIMIT 1
];

if (sessionsReport.size() != 1) {
    return;
}

Course_Settings__c courseSettings = [SELECT Id, Schedule_of_Sessions__c
    FROM Course_Settings__c
    LIMIT 1];
courseSettings.Schedule_of_Sessions__c = sessionsReport[0].id;

update courseSettings;
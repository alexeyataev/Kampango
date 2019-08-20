String reportName = 'Schedule of Sessions';

List<Report> venueReport = [SELECT Id
    FROM Report
    WHERE Name = :reportName
    LIMIT 1
];

if (venueReport.size() != 1) {
    return;
}

Course_Settings__c courseSettings = [SELECT Id, Schedule_of_Sessions__c
    FROM Course_Settings__c
    LIMIT 1];
courseSettings.Schedule_of_Sessions__c = venueReport[0].id;

update courseSettings;
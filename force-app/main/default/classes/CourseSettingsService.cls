public with sharing class CourseSettingsService {

	public static void setVenueScheduleReportId(String reportName) {

		List<Report> venueReport = [SELECT Id
			FROM Report
			WHERE Name = :reportName
			LIMIT 1
		];

		if (venueReport.size() == 0) {
			return;
		}

		Course_Settings__c courseSettings = [SELECT Id, Venue_Schedule_Report_ID__c
			FROM Course_Settings__c
			LIMIT 1];
		courseSettings.Venue_Schedule_Report_ID__c = venueReport[0].id;

		update courseSettings;

	}

}
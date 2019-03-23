@isTest
private class DisplayCourseSessionsControllerTest {

	@isTest static void displayCourseSessions() {
        
        account acct = new account();
        acct.name = 'account details';
        insert acct;
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Prefered_First_Name__c = 'NCT';
        con.AccountId = acct.Id;
        insert con;        
        
		Course__c course = new Course__c();
        course.Fee__c = 987987;
        course.Course_Name__c = 'Breastfeeding';
        course.Course_Type__c = 'Breastfeeding - Postnatal';
        course.Status__c = 'Confirmed';
        course.Practitioner__c = con.id;
        insert course;
	
        Session__c session = new Session__c();
        session.Course__c = course.id;
        session.Session_Type__c = 'Breastfeeding';
        insert session;
        
         //= [select name from session__c where ID =: session.Id];
        
		DisplayCourseSessionsController controller = new DisplayCourseSessionsController();
		controller.courseId = course.Id;
        list<session__c> sessionLists = controller.getSessions(); 
        system.assertEquals('Breastfeeding', session.Session_Type__c);
    }
	
}
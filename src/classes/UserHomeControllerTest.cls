@isTest
public class UserHomeControllerTest {
	
   @testSetup
  static void setupTestData(){
    test.startTest();
    Date d1 = system.today();
    Date d2 = system.today()+2;
    Course__c courseObj = new Course__c(Course_Name__c = 'MyTest',Course_Type__c='NCT Signature antenatal', Status__c = 'Confirmed', Start_Date__c=system.today(),End_Date__c= system.today()+2, Practitioner__c ='0030E00000Owx30QAB' , Fee__c =12);
    Insert courseObj; 
    Session__c sessionObj = new Session__c(Course__c = courseObj.id);
    Insert sessionObj; 
    test.stopTest();
  }
  static testMethod void test_getmainnodes_UseCase1(){
    List<Course__c> courseObj  =  [SELECT Id,Course_Name__c,Status__c,Start_Date__c,End_Date__c,Practitioner__c,Fee__c from Course__c];
    System.assertEquals(true,courseObj.size()>0);
    List<Session__c> sessionObj  =  [SELECT Id,Course__c,Name from Session__c];
    System.assertEquals(true,sessionObj.size()>0);
    UserHomeController obj01 = new UserHomeController();
    obj01.noOfRecords = 10;
    UserHomeController.cNodes obj21 = new UserHomeController.cNodes(new Course__c(),new List<Session__c>());
    obj21.parent = sessionObj;
    obj21.gparent = courseObj[0];
    //obj01.hierarchy = new List<cNodes>();
    obj01.getmainnodes();
  }
}

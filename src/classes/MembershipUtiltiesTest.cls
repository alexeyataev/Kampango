/**
*   @author: Mahanth Garlapati
*   @description: This is test class that covers code coverage to the 
*                 MembershipUtilties class.
**/
@isTest
private class MembershipUtiltiesTest {

  @testSetup static void setup(){
    List<Account> accountList = new List<Account>();
    List<Contact> contactList = new List<Contact>();
    List<Practitioner_Role__c> practitionerRole = new List<Practitioner_Role__c>();
    Date myDate = Date.today();

    for(Integer i = 0; i < 10; i++){
      Account acc = new Account();
      acc.Name = 'Woolwich Arsenal'+i;
      acc.BillingStreet = 'Erebus Drive';
      acc.BillingCity = 'London';
      acc.BillingCountry = 'UK';
      acc.BillingPostalCode = 'SE280GL';
      accountList.add(acc);
    }
    insert accountList;
    
    for(Integer i = 0 ; i < 10; i++){
      Contact cont = new Contact();
      cont.FirstName = 'Mike'+ i;
      cont.LastName = 'Jhon'+ i;
      cont.Email = 'mikejhon'+i+'@test.com';
      contactList.add(cont);
    }
    insert contactList;

    for(Integer i = 0; i < 10; i++){
      Practitioner_Role__c pr = new Practitioner_Role__c();
      if(i < 5){
        pr.Contact__c = contactList[i].Id;
        pr.Expiry_Date__c = myDate.addDays(i);
      }else{
        pr.Contact__c = contactList[i].Id;
        pr.Expiry_Date__c = myDate.addDays(-i);
      }
      practitionerRole.add(pr);
    }
    insert practitionerRole;      
          
  } 
  
  //This method test the contact has active Practitioner related record.
  @isTest private static void testIsPractitioner(){
    List<Contact> contact = [SELECT Id, FirstName, LastName, Email FROM Contact];
    Practitioner_Role__c pRole1 = [
                                    SELECT 
                                      Id, 
                                      Contact__c, 
                                      Is_Active__c, 
                                      Expiry_Date__c 
                                    FROM 
                                      Practitioner_Role__c 
                                    WHERE 
                                      Contact__c = :contact[3].Id 
                                    LIMIT 1
                                  ];
    
    Practitioner_Role__c pRole2 = [
                                    SELECT 
                                      Id, 
                                      Contact__c, 
                                      Is_Active__c, 
                                      Expiry_Date__c 
                                    FROM 
                                      Practitioner_Role__c 
                                    WHERE 
                                      Contact__c = :contact[8].Id 
                                    AND 
                                      Is_Active__c = false 
                                    LIMIT 1
                                  ];
    
    Test.startTest();
      Boolean b1 = MembershipUtilties.isPractitioner(contact[3].FirstName, contact[3].LastName, contact[3].Email);
      Boolean b2 = MembershipUtilties.isPractitioner(contact[8].FirstName, contact[8].LastName, contact[8].Email);
    Test.stopTest();
   
    System.assertEquals( b1, pRole1.Is_Active__c );       
    System.assertEquals( b2, pRole2.Is_Active__c );
    
  }

  //This testmethod tests next donation date if the lead time is above the date 3rd of next month.
  //And the date to populate is 3rd of next month.
  @isTest static void testNextDonationDateForMonthAfterMonth() {
    Date todaysDate = Date.newInstance(2019, 2, 25);
    Test.startTest();
    Date nextDonationDate = MembershipUtilties.getNextDonationDate(todaysDate);
    Test.stopTest();
    System.assertEquals(Date.newInstance(2019, 4, 3), nextDonationDate);
    System.assertNotEquals(Date.newInstance(2019, 3, 3), nextDonationDate);
    
  }
  
  //This testmethod tests next donation date if the lead time is below the date 3rd of next month.
  //And the date to populate is 3rd of next month.
  @isTest static void testNextDonationDateForNextMonth() {
    Date todaysDate = Date.newInstance(2019, 2, 10);
    Test.startTest();
    Date nextDonationDate = MembershipUtilties.getNextDonationDate(todaysDate);
    Test.stopTest();
    System.assertEquals(Date.newInstance(2019, 3, 3), nextDonationDate);
    System.assertNotEquals(Date.newInstance(2019, 4, 3), nextDonationDate);
  }

  //This method tests the positive condition of joint membership
  @isTest
  static void testIndividualParentTwoMemGetMembershipTypeMap(){
    Test.startTest();
    	Map<String, List<sObject>> membershipTypeMap = MembershipUtilties.getMembershipTypeMap(true, 'Parent',false);
    Test.stopTest();
    System.assertNotEquals(null, membershipTypeMap);
 	System.assertNotEquals(0, membershipTypeMap.size());
  }
  
  //This method tests the Individual membership
  @isTest
  static void testIndividualParentMemGetMembershipTypeMap(){
    Test.startTest();
    	Map<String, List<sObject>> membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual', 'Parent');
    Test.stopTest();
    System.assertNotEquals(null, membershipTypeMap);
 	System.assertNotEquals(0, membershipTypeMap.size());
  }   
  
  //This method test the negative condition of joint membership
  @isTest
  static void testIndividualParentNonTwoMemGetMembershipTypeMap(){
    Test.startTest();
    	Map<String, List<sObject>> membershipTypeMap = MembershipUtilties.getMembershipTypeMap(false, 'Parent',false);
    Test.stopTest();
    System.assertNotEquals(null, membershipTypeMap);
 	System.assertNotEquals(0, membershipTypeMap.size());
  }

  //This method test the targetcustomer is staff only membership type
  @isTest
  static void testStaffMemGetMembershipTypeMap(){
    Test.startTest();
    	Map<String, List<sObject>> membershipTypeMap = MembershipUtilties.getMembershipTypeMap(false, 'Staff Only',true);
    Test.stopTest();
    System.assertNotEquals(null, membershipTypeMap);
 	System.assertNotEquals(0, membershipTypeMap.size());
  }

  @isTest
  static void testOtherMemGetMembershipTypeMap(){
    Test.startTest();
    	Map<String, List<sObject>> membershipTypeMap = MembershipUtilties.getMembershipTypeMap(false, 'Other',true);
    Test.stopTest();
    System.assertNotEquals(null, membershipTypeMap);
 	System.assertNotEquals(0, membershipTypeMap.size());
  }
	
  //This method tests the targetcustomer is volunteer  
  @isTest
  static void testVolunteerMemGetMembershipTypeMap(){
    Test.startTest();
    	Map<String, List<sObject>> membershipTypeMap = MembershipUtilties.getMembershipTypeMap(false, 'Volunteer',false);
    Test.stopTest();
    System.assertNotEquals(null, membershipTypeMap);
 	System.assertNotEquals(0, membershipTypeMap.size());
  }

  //This method tests the tests the geocoder for latitude and longitude  
  @isTest
  static void testGetBranches(){
      
    StaticResourceCalloutMock geoCodeMock = new StaticResourceCalloutMock();
    geoCodeMock.setStaticResource('GeoMockResponse');
    geoCodeMock.setStatusCode(200);
    geoCodeMock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    Test.setMock(HttpCalloutMock.class, geoCodeMock);
	
    List<sObject> accountList = new List<sObject>();
    accountList.addAll(Test.loadData(Account.sobjectType, 'AccountBranches'));
      
    Test.startTest();
   	Map<String, List<sObject>> branchesMap = MembershipUtilties.getBranches('wd174bq');	
    Test.stopTest();
    System.Debug('branches '+branchesMap);
    System.assertNotEquals(null, branchesMap);
    System.assertNotEquals(0, branchesMap.size());
  }
}
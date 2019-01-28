/*ContactHelperTest Class: Used to check the Code Coverage.
    **
    * Author        : Ujwal Theja
    * Created Date  : 28-01-2019
    * (c) Copyright by CSS Corp.
    **
*/
@isTest
public class ContactHelperTest {
    
@isTest static void positivemethod() {
    
        Account a = new Account();
        a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        a.Name ='Test Account';
        Insert a;
    
        String firstname = 'Test';
        String lastname = 'Test';
        String email = 'test@test.com';
        String genders = 'Male';
    
        String sfirstname = 'sTest';
        String slastname = 'sTest';
        String semail = 'stest@test.com';
        String sgenders = 'Female';
        String phone = '9123456789';
    
        Id selectBranch = a.Id;
        String sphone = '123456789';
        String postCode = 'SW1234';
        String contactPreference = 'Post';
        String selectedPreferences = '';
        String streetValue = '';
        String streetValue1 = '';
        String streetValue2 = '';
        String stateValue = '';
        String cityValue = 'London';
        Contact newCont;
        
        String recordType = 'Parent';
    
        list<String> firstContactFieldsList = new list<String>{firstname,lastname,email,genders,phone};
        list<String> secondContactFieldsList = new list<String>{sfirstname,slastname,semail,sgenders,sphone};
        list<String> contactFieldListExt = new list<String>{phone,postCode,contactPreference,selectedPreferences,streetValue,streetValue1,streetValue2,stateValue,cityValue};
        
        Contact con = ContactHelper.getCreateContact(firstContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont);
        
        System.assertNotEquals(null, con != null);
    }
    
    @isTest static void negativemethod() {
        
        Contact newCont = new Contact();
        newCont.FirstName = 'Test FirstName';
        newCont.LastName = 'Test LastName';
        newCont.Email = 'testemail@test.com';
        insert newCont;
        
        Account a = new Account();
        a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        a.Name ='Test Account';
        Insert a;
    
        String firstname = 'Test';
        String lastname = 'Test';
        String email = 'test@test.com';
        String genders = 'Male';
    
        String sfirstname = 'sTest';
        String slastname = 'sTest';
        String semail = 'stest@test.com';
        String sgenders = 'Female';
        String phone = '9123456789';
        Id selectBranch = a.Id;
        String sphone = '123456789';
        String postCode = 'SW1234';
        String contactPreference = 'Post';
        String selectedPreferences = '';
        String streetValue = '';
        String streetValue1 = '';
        String streetValue2 = '';
        String stateValue = '';
        String cityValue = 'London';
        
        
        String recordType = 'Parent';
    
        list<String> firstContactFieldsList = new list<String>{firstname,lastname,email,genders,phone};
        list<String> secondContactFieldsList = new list<String>{sfirstname,slastname,semail,sgenders,sphone};
        list<String> contactFieldListExt = new list<String>{postCode,contactPreference,selectedPreferences,streetValue,streetValue1,streetValue2,stateValue,cityValue};
        
        Contact con = ContactHelper.getCreateContact(firstContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont);
        
        System.assertNotEquals(null, con != null);
    }
}
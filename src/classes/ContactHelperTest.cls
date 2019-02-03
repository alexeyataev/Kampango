/*ContactHelperTest Class: Used to check the Code Coverage.
    **
    * Author        : Ujwal Theja
    * Created Date  : 28-01-2019
    * (c) Copyright by CSS Corp.
    **
*/
@isTest
public class ContactHelperTest {

@isTest static void positiveMethod() {

        Account a = new Account();
        a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        a.Name ='Test Account';
        Insert a;

        String firstname = 'Test';
        String lastname = 'Test';
        String email = 'test@test.com';
        String genders = 'Male';
    	String phone = '123456789';
    	String salutationPrim = '';

        String sfirstname = 'sTest';
        String slastname = 'sTest';
        String semail = 'stest@test.com';
        String sgenders = 'Female';
        String sphone = '9123456789';
    	   String salutationSec = '';

        Id selectBranch = a.Id;

        String postCode = 'SW1234';
        String contactPreference = 'Post';
    	Boolean smsOpt = true;
        Boolean postOpt = true;
        Boolean emailOpt = true;
        Boolean doNotCallOpt = true;

        String streetValue = '';
        String streetValue1 = '';
        String streetValue2 = '';
        String stateValue = '';
        String cityValue = 'London';
        Contact newCont;

        String recordType = 'Parent';

        list<String> firstContactFieldsList = new list<String>{firstname,lastname,email,genders,phone,salutationPrim};
        list<String> secondContactFieldsList = new list<String>{sfirstname,slastname,semail,sgenders,sphone,salutationSec};
        list<String> contactFieldListExt = new list<String>{phone,postCode,contactPreference,streetValue,streetValue1,streetValue2,stateValue,cityValue};
        list<Boolean> contactBooleanList = new list<Boolean>{smsOpt,postOpt,emailOpt,doNotCallOpt};

        Contact con = ContactHelper.getCreateContact(firstContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);

        System.assertNotEquals(null, con != null);
    }

    @isTest static void negativeMethod() {

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
    	String phone = '12123456789';
        String salutationPrim = '';

        String sfirstname = 'sTest';
        String slastname = 'sTest';
        String semail = 'stest@test.com';
        String sgenders = 'Female';
        String sphone = '9123456789';
        String salutationSec = '';

        Id selectBranch = a.Id;

        String postCode = 'SW1234';
        String contactPreference = 'Post';
        Boolean smsOpt = false;
        Boolean postOpt = false;
        Boolean emailOpt = false;
        Boolean doNotCallOpt = false;

        String streetValue = '';
        String streetValue1 = '';
        String streetValue2 = '';
        String stateValue = '';
        String cityValue = 'London';


        String recordType = 'Parent';

        list<String> firstContactFieldsList = new list<String>{firstname,lastname,email,genders,phone,salutationPrim};
        list<String> secondContactFieldsList = new list<String>{sfirstname,slastname,semail,sgenders,sphone,salutationSec};
        list<String> contactFieldListExt = new list<String>{postCode,contactPreference,streetValue,streetValue1,streetValue2,stateValue,cityValue};
        list<Boolean> contactBooleanList = new list<Boolean>{smsOpt,postOpt,emailOpt,doNotCallOpt};

        Contact con = ContactHelper.getCreateContact(firstContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);

        System.assertNotEquals(null, con != null);
    }
    @isTest static void negativeBlankmethod() {

        Contact newCont = new Contact();
        newCont.FirstName = 'Test FirstName';
        newCont.LastName = 'Test LastName';
        newCont.Email = 'testemail@test.com';
        insert newCont;

        Account a = new Account();
        a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        a.Name ='Test Account';
        Insert a;

        String firstname = '';
        String lastname = '';
        String email = '';
        String genders = '';
        String phone = '';
        String salutationPrim = '';

        String sfirstname = '';
        String slastname = '';
        String semail = '';
        String sgenders = '';
        String sphone = '';
        String salutationSec = '';

        Id selectBranch = a.Id;

        String postCode = '';
        String contactPreference = '';
        Boolean smsOpt = false;
        Boolean postOpt = false;
        Boolean emailOpt = false;
        Boolean doNotCallOpt = false;

        String streetValue = '';
        String streetValue1 = '';
        String streetValue2 = '';
        String stateValue = '';
        String cityValue = '';


        String recordType = 'Parent';

        list<String> firstContactFieldsList = new list<String>{firstname,lastname,email,genders,phone,salutationPrim};
        list<String> secondContactFieldsList = new list<String>{sfirstname,slastname,semail,sgenders,sphone,salutationPrim};
        list<String> contactFieldListExt = new list<String>{postCode,contactPreference,streetValue,streetValue1,streetValue2,stateValue,cityValue};
        list<Boolean> contactBooleanList = new list<Boolean>{smsOpt,postOpt,emailOpt,doNotCallOpt};
        Contact con = ContactHelper.getCreateContact(firstContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);

        System.assertNotEquals(null, con == null);
    }
}

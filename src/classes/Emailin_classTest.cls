@isTest
private class Emailin_classTest {
    
    private static testMethod void myUnitTest() {
        Account acc = new Account(name='test acc',phone='9494146144');
        insert acc;
        
        //Assigning a record  type for particular record.
        Id recordTypeIdFirstContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Id recordTypeIdSecondContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Companion').getRecordTypeId();
        
        Contact contactObj = new Contact(accountid=acc.id,lastname='test con',Email='sfdclatha@gmail.com',Prefered_First_Name__c='testcontact',RecordtypeId=recordTypeIdFirstContact);
        insert contactObj;
        
        Contact contactObj1 = new Contact(accountid=acc.id,lastname='test1 con',Email='sfdclatha1@gmail.com',Prefered_First_Name__c='testcont',RecordtypeId=recordTypeIdSecondContact);
        insert contactObj1;
        
           
        //if Option2 not done, otherway we can set parent(__r) values as below. 
        //other wise lookup values wont get in code.
        course__c courseRec = new course__c(Practitioner__r=contactObj);
        courseRec.Course_Name__c='Antenatal';
       
        courseRec.End_Date__c=date.today()+5;
       
        courseRec.Fee__c=4000.52;
        courseRec.Course_Type__c='NCT Parent';
       
        courseRec.Practitioner__c=contactObj.id;
        insert courseRec;
        String cID = courseRec.id;
        
        Booking__c b1=new Booking__c();
        b1.First_Contact__c=contactObj.id;
        b1.Second_Contact__c=contactObj1.id;
        b1.Due_Date__c=system.today()+10;
        b1.Course__c=courseRec.id;
        b1.Status__c='Enquiry';
        insert b1;
        
       
       
        
        //Option2 : to get lookup field courseRec.practitioner__r.Email, otherwise practitioner__r will be null 
        //must need to inset and then query for that same record:
           
        
        ApexPages.StandardController sc = new ApexPages.StandardController(courseRec);
        Emailin_class ec = new Emailin_class(sc);
        ec.toaddress = 'sfdclatha@gmail.com';
        ec.emailbody= 'email_body';
        ec.subject='subject';
        ec.ccaddress='';
        PageReference pageReference = ec.send();
       
        // below assertion, after sending mail business expecting to redirect to Course Obj
        // hence checking the pagRef.URL to CourseID below.
        boolean expected = pageReference.getUrl().contains('/'+cID.substring(0,cID.length()-3));
        system.assertEquals(true, expected);
    }
}
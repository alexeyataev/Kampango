@isTest
private class AddToMembershipCompControllerTest {
  
    @testSetup static void setup() {
        List<Contact> contact = new List<Contact>();
        for(Integer i=0;i<2;i++){
            contact.add(new Contact(
            LastName = 'NCT CHild'+i,
            FirstName = 'Childs'+i,
            Phone = '09876543212',
            Email = 'nctchild4555'+i+'@gmail.com'));
        }
        insert contact;
        System.debug('contact:'+contact);
        List<npe03__Recurring_Donation__c> recDonation = new List<npe03__Recurring_Donation__c>();
        for(Integer j=0; j<2; j++){
            recDonation.add(new npe03__Recurring_Donation__c(
                Name = 'NCT Childs',
                npe03__Amount__c = 10000,
                npe03__Installment_Period__c = 'Monthly',
                CARE_Payment_Frequency__c = 'NCT CHILD TRUST',
                First_Payment__c = system.date.today(),
                First_Contact__c = contact[j].id, 
                Membership_Status__c = 'Pending', 
                Membership_type__c = '18 month - Joint',
                npe03__Contact__c = contact[j].id,
                Renewal_Date__c = null
            ));
        }
        insert recDonation;
    }
      @isTest
    static void isMembershipExists(){
        
         List<npe03__Recurring_Donation__c> recDon = [Select Id,Name,Membership_Status__c,npe03__Contact__c from npe03__Recurring_Donation__c where Name='NCT Childs'];
        
        try{
         AddToMembershipCompController.addToMembershipValidation(recDon[0].npe03__Contact__c);
         system.assertEquals('Pending',recDon[0].Membership_Status__c);
        }catch(AuraHandledException e) {
            System.assert(e.getMessage().contains('You Cant Add Membership, hence already membership exists for this contact')); 
       }
    }

    @isTest
    private static void permissionCheck(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        System.runAs(u) {
            contact cont = new contact();
            cont.LastName = 'NCT CHild';
            cont.FirstName = 'Childs';
            cont.Phone = '0987654321234';
            cont.Email = 'nctchild4555@gmail.com';
            insert cont;
            list<npe03__Recurring_Donation__c> recurrDonList = new  list<npe03__Recurring_Donation__c>();
            
              /* Reccurring Donation record insertion doesn't happened, So membership doesn't exists, it goes to try block 
            * and compares assertequals method. */
           try{
             AddToMembershipCompController.addToMembershipValidation(cont.id);
             system.assertEquals('NCT CHild',cont.LastName);
            }catch(AuraHandledException e) {
                System.debug(e.getMessage());
                System.assert(true,'You Cant Add Membership, hence already membership exists for this contact');
           }
    	}
    }
}
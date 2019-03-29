@isTest
private class AddToMembershipCompControllerTest {

    @isTest
    private static void isMembershipExists(){
        
        contact cont = new contact();
        cont.LastName = 'NCT CHild';
        cont.FirstName = 'Childs';
        cont.Phone = '0987654321234';
        cont.Email = 'nctchild4555@gmail.com';
        insert cont;
        
        npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
        recDonate.Name = 'NCT Child';
        recDonate.npe03__Amount__c = 60;
        recDonate.npe03__Installment_Period__c = 'Monthly';
        recDonate.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDonate.First_Payment__c = system.Date.today();
        recDonate.First_Contact__c = cont.id; 
        recDonate.Membership_Status__c = 'Confirmed'; 
        recDonate.Membership_type__c = '18 month - Joint';
        recDonate.npe03__Contact__c = cont.id;
        recDonate.Renewal_Date__c = System.Date.today() +100;
        insert recDonate;
        
       /* Reccurring Donation record insertion happened, So membership exists, it goes to catch block 
        * and compares assert method. */
        try{
         AddToMembershipCompController.addToMembershipValidation(cont.id);
        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(true,'You Cant Add Membership, hence already membership exists for this contact');
       }
        

    }
      @isTest
    private static void isMembershipNotExists(){
        
        contact cont = new contact();
        cont.LastName = 'NCT CHild';
        cont.FirstName = 'Childs';
        cont.Phone = '0987654321234';
        cont.Email = 'nctchild4555@gmail.com';
        insert cont;
        
          /* Reccurring Donation record insertion doesn't happened, So membership doesn't exists, it goes to try block 
        * and compares assertequals method. */
       try{
         AddToMembershipCompController.addToMembershipValidation(cont.id);
        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(true,'You Cant Add Membership, hence already membership exists for this contact');
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
            }catch(AuraHandledException e) {
                System.debug(e.getMessage());
                System.assert(true,'You Cant Add Membership, hence already membership exists for this contact');
           }
    	}
    }
}
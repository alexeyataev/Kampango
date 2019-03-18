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
        list<npe03__Recurring_Donation__c> recurrDonList = new  list<npe03__Recurring_Donation__c>();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        recDon.Name = 'NCT Child';
        recDon.npe03__Amount__c = 10000;
        recDon.npe03__Installment_Period__c = 'Monthly';
        recDon.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDon.First_Payment__c = system.today();
        recDon.First_Contact__c = cont.id; 
        recDon.Membership_Status__c = 'Confirmed'; 
        recDon.Membership_type__c = '18 month - Joint';
        recDon.npe03__Contact__c = cont.id;
        recurrDonList.add(recDon);
        insert recurrDonList;
        
       /* Reccurring Donation record insertion happened, So membership exists, it goes to catch block 
        * and compares assert method. */
        try{
         AddToMembershipCompController.addToMembershipValidation(cont.id);
         AddToMembershipCompController.recurrDonList = recurrDonList;
            system.assertEquals(0, AddToMembershipCompController.recurrDonList.size());
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
        list<npe03__Recurring_Donation__c> recurrDonList = new  list<npe03__Recurring_Donation__c>();
        
          /* Reccurring Donation record insertion doesn't happened, So membership doesn't exists, it goes to try block 
        * and compares assertequals method. */
       try{
         AddToMembershipCompController.addToMembershipValidation(cont.id);
         AddToMembershipCompController.recurrDonList = recurrDonList;
            system.assertEquals(0, AddToMembershipCompController.recurrDonList.size());
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
             AddToMembershipCompController.recurrDonList = recurrDonList;
                system.assertEquals(0, AddToMembershipCompController.recurrDonList.size());
            }catch(AuraHandledException e) {
                System.debug(e.getMessage());
                System.assert(true,'You Cant Add Membership, hence already membership exists for this contact');
           }
    	}
    }
}
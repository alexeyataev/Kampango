@isTest
private class AddToMembershipCompControllerTest {
    @isTest
    private static void addToMembership(){
        contact cont = new contact();
        cont.LastName = 'NCT CHild';
        cont.Phone = '0987654321234';
        cont.Email = 'nctchild4555@gmail.com';
        insert cont;
        
        list<npe03__Recurring_Donation__c> recurrDonList = new list<npe03__Recurring_Donation__c>();
        for(Integer i=0;i<6;i++){
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
        }
        insert recurrDonList;
        
        try{
        AddToMembershipCompController.addToMembershipValidation(cont.id);
        AddToMembershipCompController.recurrDonList = recurrDonList;
         system.assertEquals(1, recurrDonList.size());
        } catch (AuraHandledException e){
        }


    }

}
@isTest
private class MembershipCrudHelperTest {
    private npe03__Recurring_Donation__c recDonation;
    @isTest
    private static void membershipCrudTest(){
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt limit 1];
        
        npe03__Recurring_Donation__c recDonation = new npe03__Recurring_Donation__c();
        gaid__Gift_Aid_Declaration__c gftAid = new gaid__Gift_Aid_Declaration__c();
        String isGiftAid = 'true';
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
        
        Membership_Type__mdt  membershipInformation = new Membership_Type__mdt();
        
        
        cpm__Payment_Profile__c paymntProfl = new cpm__Payment_Profile__c();
        paymntProfl.cpm__Contact__c = con.id;
        paymntProfl.cpm__Bank_Account__c = 'NCT Bank';
        paymntProfl.cpm__Holder_Name__c  = 'NCT CHILD CUSTOMER';
        paymntProfl.paybacs__Sort_Code__c = 'CD-1234';
        insert paymntProfl;
        
        list<String> accountDetails = new list<String>{'145263777','Santhosh','CD-1234','Text','Enquiry by phone - main NCT'};
        MembershipCrudHelper memCrud = new MembershipCrudHelper();
 
        paymntProfl = memCrud.paymentProfile(accountDetails);
        system.assertEquals(accountDetails[2],paymntProfl.paybacs__Sort_Code__c);      
        
         gftAid = memCrud.giftAid(isGiftAid,membershipDetails,accountDetails);
         system.assertEquals(true,gftAid.gaid__Active__c);
        
        recDonation = memCrud.recDonation(membershipDetails,paymntProfl,accountDetails);
        system.assertEquals('confirmed',recDonation.Membership_Status__c);

    }  
}
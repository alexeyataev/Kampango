/**
*   @author:  Mahanth Garlapati
*   @description: This class holds the data required for membership journey
*
**/

public with sharing class MembershipVo {
  
    public Boolean isVolunteer{get; set;}
    public Boolean isPractitioner{get; set;}
    public Boolean isGiftAidSelected{get; set;}
    public Boolean isJointMembership{get; set;}
    public String membershipType{get;set;}
    public String paymentMethod{get;set;}
    public Boolean keepMeUpdated{get;set;} 
    public String membershipNumber{get; set;}
    public Membership_Type__mdt membershipInfo{get; set;}
    public DirectDebitVo directDebitDetails{get;set;}
    public ContactVo primaryContact{get;set;}
    public ContactVo secondaryContact{get;set;}
    public AddressVo address{get;set;}
    public MarketingPreferenceVo marketingPreference{get;set;}
   
      
      public MembershipVo(){  
             primaryContact = new ContactVo();
            secondaryContact = new ContactVo();
            address = new AddressVo();
            directDebitDetails = new DirectDebitVo();
            marketingPreference = new MarketingPreferenceVo();
      }
    
    public class ContactVo{
        public String salutation{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String gender{get; set;}
        public String email{get;set;}
        public String phone{get;set;}
        public String mobile{get;set;}
        public String dob{get;set;}
        public String nctBranch{get;set;}
    }

    public class AddressVo{
        public String building{get;set;}
        public String addressLine1{get;set;}
        public String addressLine2{get;set;}
        public String addressLine3{get;set;}
        public String state{get;set;}
        public String city{get;set;}
        public String postCode{get;set;}
    }

    public class DirectDebitVo{
        public String accountName{get;set;}
        public String sortCode{get;set;}
        public String accountNumber{get;set;}
        public String paymentDate{get;set;}
        public String colletionDate{get;set;}
    }

    public class MarketingPreferenceVo{
        public Boolean phone{get;set;}
        public String email{get;set;}
        public String sms{get;set;}
        public String post{get;set;}
    }
}
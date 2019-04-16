/**
*   @author:  Mahanth Garlapati
*   @description: This class holds the data required for membership journey
*
**/

public with sharing class MembershipVo {
    
       
     public SecondContactVo secondContact{get;set;}
    public AccountInfo accountInformation{get; set;}
    public BooleanCheck booleanChecking{get;set;}
    //public MemberCrudHelper memberCrud{get;set;}
    public MembershipInformation membershipDetails{get;set;}

    public class SecondContactVo{
       public String secondContactFirstName{get; set;}
       public String secondContactLastName{get; set;}
       public String secondContactEmail{get; set;}
       public String secondContactPhone{get; set;} 
       public String salutationSecondary {get;set;}
       public String secondContactGenders {get;set;}
       public string eDate{get;set;}
       public String streetValue1 {get; set;}
       public String streetValue2 {get; set;}
    }



    public class MembershipInformation{
        public String membershipSource{get;set;}
        public list<SelectOption> membershipSourceOptions{get; set;}
        public Membership_Type__mdt membershipInfo {get;set;}
        public Map<String, List<Membership_Type__mdt>> membershipTypeMap{get;set;}    
        public Map<String, list<sObject>> nearestBranchs {get; set;}           
        public string membershipNumber {get;set;}
        public String staffMember {get; set;}
        public String acquistion {get;set;}
        public list<SelectOption> acquistionOptions{get; set;} 
       
    }    
    
    public class AccountInfo{
       public String accountName {get; set;}
       public String sortCode {get; set;}
       public String accountNumber {get; set;}  
       public Id feeAmount {get;set;}
       public String isGiftAid{get; set;}
       public String contactType{get; set;}
       public String recordType{get; set;}
       public string targetCustomer{get; set;}
       public string redirectURL{get; set;}
       public String sessionProfile{get; set;}
    }    
   

    public class BooleanCheck{
      public boolean displaySuccessMessage {get;set;}
      public boolean displayMbrNoMessage {get;set;} 
      public boolean isMembershipExists {get; set;}    
      public Boolean twomems{get; set;}
      public list<SelectOption> salutationOptions{get; set;}         
      public list<SelectOption> genderOptions{get; set;} 
      public boolean isContactExisting{get; set;}
      public boolean isVolunteer{get; set;}
      public boolean isStaff{get; set;}
        public Boolean isCompanionContactExisting {get; set;}
    }
  
    public class MemberCrudHelper{
        public String accountName {get; set;}
        public String sortCode {get; set;}
        public String accountNumber {get; set;}
        public String acquistion {get;set;}
        public String membershipSource{get;set;}
        public boolean isVolunteer {get; set;}
        public Contact pcont{set; get;}
        public Contact scont{set; get;}
    }
}
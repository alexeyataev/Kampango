public with sharing class MembershipBooleanCheckVo {
      public boolean displaySuccessMessage {get;set;}
      public boolean displayMbrNoMessage {get;set;} 
      public boolean isMembershipExists {get; set;}    
      public Boolean twomems{get; set;}               
      public boolean isContactExisting{get; set;}
      public boolean isVolunteer{get; set;}
      public boolean isStaff{get; set;}      
      public String isGiftAid{get; set;}
      public Boolean isCompanionContactExisting{get; set;}
    
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
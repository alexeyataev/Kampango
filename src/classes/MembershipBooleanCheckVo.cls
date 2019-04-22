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
      
    public class AccountDetails{
       public string targetCustomer{get; set;}
       public string redirectURL{get; set;}
       public String sessionProfile{get; set;} 
    }           
      
}
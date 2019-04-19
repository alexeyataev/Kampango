public with sharing class MembershipContactVo {
    public class SecondContactVo{
      public String secondContactFirstName{get; set;}
      public String secondContactLastName{get; set;}
      public String secondContactEmail{get; set;}
      public String secondContactPhone{get; set;} 
      //public String salutationSecondary {get;set;}
      //public String secondContactGenders {get;set;} 
    }
      
    public class ContactVo{
      public string eDate{get;set;}
      public String streetValue1 {get; set;}
      public String streetValue2 {get; set;}
      public String contactType{get; set;}
      public String recordType{get; set;}
      public String acquistion {get;set;}
      public list<SelectOption> acquistionOptions{get; set;} 
      //public list<SelectOption> salutationOptions{get; set;}
      //public list<SelectOption> genderOptions{get; set;}
    }   
       
}
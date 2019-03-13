/**
*   @author:  Mahanth Garlapati
*   @description: This class holds the data required for membership journey
*
**/

public with sharing class MembershipVo {
  
    public Boolean twomems{get; set;}
    public boolean twomem{get; set;}
    public Date expDate {get; set;}
    public String isGiftAid{get; set;}
    public String firstname{get; set;}
    public String lastname{get; set;}
    public String email{get; set;}
    public String phone{get; set;}
    public String secondContactFirstName{get; set;}
    public String secondContactLastName{get; set;}
    public String secondContactEmail{get; set;}
    public String secondContactPhone{get; set;}
    public String postCode{get; set;}
    public String membershipSource{get;set;}
    public list<SelectOption> membershipSourceOptions{get; set;}
    public String genderValue {get; set;}
    public String streetValue {get; set;}
    public String streetValue1 {get; set;}
    public String streetValue2 {get; set;}
    public String stateValue {get; set;}
    public String cityValue {get; set;}
    public Contact primaryContact {get;set;} 
    public Contact secondaryContact {get;set;} 
    public String salutation{get; set;}
    public String salutationPrimary {get;set;}
    public String salutationSecondary {get;set;}
    public list<SelectOption> salutationOptions{get; set;}
    public String acquistion {get;set;}
    public list<SelectOption> acquistionOptions{get; set;}
    public String genders {get;set;}
    public String secondContactGenders {get;set;}
    public list<SelectOption> genderOptions{get; set;}
    public boolean smsOpt{get; set;}
    public boolean postOpt{get; set;}
    public boolean emailOpt{get; set;}
    public boolean doNotCallOpt{get; set;}

    
    public Id feeAmount {get;set;}
    public Id selectBranch {get; set;}
    public string membershipNumber {get;set;}
    public string redirectURL {get;set;} 
    public Id contId {get;set;}
    public boolean etSpecific;
    
    public String accountName {get; set;}
    public String sortCode {get; set;}
    public String accountNumber {get; set;}
    public string displayValue {get;set;}
    public string counter  {get;set;}
    public Membership_Type__mdt membershipInfo {get;set;}
    public Map<String, List<Membership_Type__mdt>> membershipTypeMap{get;set;}
    
    public Map<String, list<sObject>> nearestBranchs {get; set;}
    public String eDate {get; set;}
    public boolean displaySuccessMessage {get;set;}
    public boolean displayMbrNoMessage {get;set;}
    public boolean isPractitioner {get; set;}
    public boolean isContactExisting {get; set;}
    public boolean isVolunteer {get; set;}
    public boolean isStaff {get; set;}
    public string targetCustomer{get; set;}
    public boolean isMembershipExists {get; set;}
    public String staffMember {get; set;}
    public String recordType;
    public String sessionProfile;
    public Boolean lifeMembership{get; set;}
    public String contactType;
}
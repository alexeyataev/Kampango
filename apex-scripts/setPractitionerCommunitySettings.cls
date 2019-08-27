Network myNetwork  = [SELECT id  FROM Network WHERE Name ='Practitioners'];
String url = Network.getSelfRegUrl(myNetwork.id);
List<Practitioner_Community_Settings__c> settings = [SELECT Id from Practitioner_Community_Settings__c];
Practitioner_Community_Settings__c practitionerCommunitySettings = new Practitioner_Community_Settings__c();
System.debug(settings.size());
if(settings.size()> 0){
    settings[0].Base_Url__c = url.substringBefore('/s/');
    practitionerCommunitySettings.SetupOwnerId = UserInfo.getOrganizationId();
    update settings;
}else{
    practitionerCommunitySettings.Base_Url__c = url.substringBefore('/s/');
    practitionerCommunitySettings.SetupOwnerId = UserInfo.getOrganizationId();
    insert practitionerCommunitySettings;
}
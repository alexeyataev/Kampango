Network myNetwork  = [SELECT id
FROM Network
WHERE Name ='Practitioners'
LIMIT 1
];
String url = Network.getSelfRegUrl(myNetwork.id);

List<Practitioner_Community_Settings__c> settings = [SELECT Id
FROM Practitioner_Community_Settings__c
LIMIT 1
];


if(settings.size()== 0){
    Practitioner_Community_Settings__c newPractitionerCommunitySettings = new Practitioner_Community_Settings__c(
        Base_Url__c = url.substringBefore('/s/'),
        SetupOwnerId = UserInfo.getOrganizationId()
    );

    insert newPractitionerCommunitySettings;
}else{
    settings[0].Base_Url__c = url.substringBefore('/s/');
    settings[0].SetupOwnerId = UserInfo.getOrganizationId();
    update settings;
}
@isTest
public with sharing class TestUserBuilder {
    private String alias = 'sysAdmin';
    private String email = 'sysAdmin.email@fakemail.com';
    private String emailEncodingKey = 'UTF-8';
    private String lastName = 'NCTtest';
    private String languageLocaleKey = UserInfo.getLanguage();
    private String localeSidKey = UserInfo.getLocale();
    private Id profileId;
    private Id contactId;
    private Id userRoleId;
    private String timeZonesIdKey = UserInfo.getTimeZone().getID();
    private String username = 'NCTtest.sysAdmin.username@nct.com';
    private String communityNickName;
    private Boolean insertRecord = false;

    public static final String TITLE = 'TEST_USER';

    public TestUserBuilder withProfile(Id profileId){
        this.profileId = profileId;
        return this;
    }

    public TestUserBuilder withAlias(String alias) {
        this.alias = alias;
        return this;
    }

    public TestUserBuilder withUserRoleId(Id userRoleId) {
        this.userRoleId = userRoleId;
        return this;
    }

    public TestUserBuilder withContactId(Id contactId) {
        this.contactId = contactId;
        return this;
    }

    public TestUserBuilder withEmail(String email) {
        this.email = email + Utils.generateSuffix();
        return this;
    }

    public TestUserBuilder withCommunityNickName(String communityNickName) {
        this.communityNickName = communityNickName;
        return this;
    }

    public TestUserBuilder withUsername(String username) {
        this.username = username + Utils.generateSuffix();
        return this;
    }

    public TestUserBuilder insertRecord(Boolean insertRecord) {
        this.insertRecord = insertRecord;
        return this;
    }

    public User build() {
        User user = new User (
            alias = this.alias,
            email = this.email,
            emailEncodingKey = this.emailEncodingKey,
            lastName = this.lastName,
            languageLocaleKey = this.languageLocaleKey,
            localeSidKey = this.localeSidKey,
            profileId = this.profileId,
            timeZonesIdKey = this.timeZonesIdKey,
            title = TITLE,
            username = this.username,
            contactId = this.contactId,
            communityNickName = this.communityNickName,
            UserRoleId = this.userRoleId
        );

        if (insertRecord) {
            insert user;
        }

        return user;
    }

}
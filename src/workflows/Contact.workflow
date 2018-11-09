<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Volunteer_de_registration_alert</fullName>
        <description>Volunteer de-registration alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>anjineyulu.valasa@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>swathi.kota@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GW_Volunteers__Volunteers_Email_Templates/Volunteer_de_register</template>
    </alerts>
    <alerts>
        <fullName>Volunteer_de_registration_alert_with</fullName>
        <description>Volunteer de-registration Alert with Proper Reason</description>
        <protected>false</protected>
        <recipients>
            <recipient>anjineyulu.valasa@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rupambika.nayak@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GW_Volunteers__Volunteers_Email_Templates/Volunteer_de_register</template>
    </alerts>
</Workflow>

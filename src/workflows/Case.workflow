<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Request_to_be_a_volunteer</fullName>
        <description>Request to be a volunteer</description>
        <protected>false</protected>
        <recipients>
            <recipient>swathi.kota@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/Request_to_be_Volunteer</template>
    </alerts>
    <alerts>
        <fullName>Volunteer_De_Registration</fullName>
        <description>Volunteer De-Registration</description>
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
    <fieldUpdates>
        <fullName>case_owner_field_update</fullName>
        <field>OwnerId</field>
        <lookupValue>Branch_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>case owner field update</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Volunteer De-Registration</fullName>
        <actions>
            <name>Volunteer_De_Registration</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Reason</field>
            <operation>equals</operation>
            <value>Volunteer De-Registration</value>
        </criteriaItems>
        <description>Branch Volunteering Profile going to de-register from volunteer click the case reason  of Volunteer De-Registration Value</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>update owner for case branch queue</fullName>
        <actions>
            <name>Request_to_be_a_volunteer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>case_owner_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

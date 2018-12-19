<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_course_updated</fullName>
        <description>New course updated</description>
        <protected>false</protected>
        <recipients>
            <recipient>anjineyulu.valasa@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/Course_Created</template>
    </alerts>
    <alerts>
        <fullName>Practitioner_changed</fullName>
        <description>Practitioner changed</description>
        <protected>false</protected>
        <recipients>
            <field>Practitioner__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>harjinder.kaur@nct.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/Practitioner_Changes_Course</template>
    </alerts>
    <rules>
        <fullName>Test Rule</fullName>
        <actions>
            <name>Practitioner_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Course__c.Course_Type__c</field>
            <operation>equals</operation>
            <value>Early Days (postnatal)</value>
        </criteriaItems>
        <description>This Rule is used to fix error on Practitioner Changes on Process Builder for Deployment purposes</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

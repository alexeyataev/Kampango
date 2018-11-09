<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Membership_Confirmation_alert</fullName>
        <description>Membership Confirmation alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>sreelatha.kenchappa@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>swathi.kota@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vemula.ashalatha@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/MembershipPlanConf</template>
    </alerts>
    <fieldUpdates>
        <fullName>Due_Amount_Calculation</fullName>
        <field>Subscription_Due_Total__c</field>
        <formula>If (ISPICKVAL(subscription_plan__c,&apos;6 Month Plan&apos;),2000/6,
    If(ISPICKVAL(subscription_plan__c,&apos;3 Month Plan&apos;),2000/3,
    If(ISPICKVAL(subscription_plan__c,&apos;12 Month Plan&apos;),2000/12,0)))</formula>
        <name>Due Amount Calculation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Term_update</fullName>
        <field>Term__c</field>
        <formula>IF( ISPICKVAL( subscription_plan__c , &apos;6 Month Plan&apos;) , 6, 
( 

IF( ISPICKVAL( subscription_plan__c , &apos;12 Month Plan&apos;) , 12, 
( 

IF( ISPICKVAL( subscription_plan__c , &apos;3 Month Plan&apos;)  ,3, NULL) )) ))</formula>
        <name>Term update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Due amount calculation</fullName>
        <actions>
            <name>Term_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MailTriggerToCustomer</fullName>
        <actions>
            <name>Membership_Confirmation_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Membership__c.Type__c</field>
            <operation>contains</operation>
            <value>18 Month Membership,12 Month Membership,Four year Membership,Reduced 12 Month Membership</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

trigger JiraRelationshipTrigger on JiraRelationship__c (before insert,after insert, after delete) {
     List<Sinergify_Trigger__c> Metdata =new List<Sinergify_Trigger__c>([SELECT Id, Name, IsActive__c FROM Sinergify_Trigger__c where Name='JiraRelationshipTrigger']);
    if(!Metdata.isEmpty() && Metdata[0].IsActive__c){ 
    TriggerFactory.createHandler(JiraRelationship__c.sObjectType);
    }
}
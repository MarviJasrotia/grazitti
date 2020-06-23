trigger UpdateFieldWithData on Jira_ProjectFieldsMapping__c (after insert,after update) {
    if(!System.isFuture() && !System.isBatch()){
        List<Sinergify_Trigger__c> Metdata =new List<Sinergify_Trigger__c>([SELECT Id, Name, IsActive__c FROM Sinergify_Trigger__c where Name='UpdateFieldWithData']);
        if(!Metdata.isEmpty() && Metdata[0].IsActive__c){ 
            TriggerFactory.createHandler(Jira_ProjectFieldsMapping__c.sObjectType);
        }
    }
}
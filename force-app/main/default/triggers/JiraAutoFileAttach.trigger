trigger JiraAutoFileAttach on ContentVersion (after insert) {
    if(!System.isFuture() && !System.isBatch()){
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() && JiraSalesforceDetail__c.getValues('Sync_SF_Attachment').value__c != null){
            if(JiraSalesforceDetail__c.getValues('Sync_SF_Attachment').value__c.toLowerCase()=='yes'){
                List<Sinergify_Trigger__c> Metdata =new List<Sinergify_Trigger__c>([SELECT Id, Name, IsActive__c FROM Sinergify_Trigger__c where Name='JiraAutoFileAttach']);
                if(!Metdata.isEmpty() && Metdata[0].IsActive__c){ 
                    TriggerFactory.createHandler(ContentVersion.sObjectType);
                }
            }
        }
    }
}
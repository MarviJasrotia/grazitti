trigger FeedItemTrigger on FeedItem (after  insert) {
     List<Sinergify_Trigger__c> Metdata =new List<Sinergify_Trigger__c>([SELECT Id, Name, IsActive__c FROM Sinergify_Trigger__c where Name='FeedItemTrigger']);
    if(!Metdata.isEmpty() && Metdata[0].IsActive__c){ 
    TriggerFactory.CreateHandler(FeedItem.SobjectType);
    }
}
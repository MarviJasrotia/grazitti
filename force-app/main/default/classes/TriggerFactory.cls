public with sharing class TriggerFactory
{
    public static void createHandler(Schema.sObjectType soType)
    {
        // Get a handler appropriate to the object being processed
        ITrigger handler = getHandler(soType);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null)
        {
            //throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }
        
        // Execute the handler to fulfil the trigger
        execute(handler);
    }
    
    private static void execute(ITrigger handler)
    {
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            // Iterate through the records inserted passing them to the handler.
            if (Trigger.isInsert)
            {
                for (SObject so : Trigger.new)
                {
                    
                    handler.afterInsert(so);
                }
            }else if(Trigger.isUpdate) {for (SObject so : Trigger.new){handler.afterUpdate(so, Trigger.oldMap.get(so.Id));}}
            else if (Trigger.isDelete)
            {
                for (SObject so : Trigger.old)
                {    
                    handler.afterdelete(so);
                }
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    private static ITrigger getHandler(Schema.sObjectType soType)
    {
        if (soType == Attachment.sObjectType){
            return new AttachmentHandler();
        }
        else if(soType == FeedItem.sObjectType){
            return new FeedItemHandler();
        }
        else if(soType == CaseComment.sObjectType){
            return new CaseCommentHandler();
        } 
        
        else if(soType == JiraRelationship__c.sObjectType){
            return new JiraIssueRelationshipHandler();
        }
        else if(soType == ContentVersion.sObjectType){
            return new ContentVersionHandler();
        }
        else if(soType == Jira_ProjectFieldsMapping__c.sObjectType){
            return new Jira_ProjectFieldMappingHandler();
        }  
        else if(soType == JiraIssueComments__c.sObjectType){
            return new JiraCommentHandler();
            
        }else if(soType == idea.sObjectType){
            return new JiraIdeaCommentHandler();
        }
        else if(soType == JiraIssue__c.sObjectType){
            return new JiraIssueHandler();
        }
        return null;
    }
    
    
}
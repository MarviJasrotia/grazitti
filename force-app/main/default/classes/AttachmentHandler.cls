public with sharing class AttachmentHandler implements ITrigger{
    public set<Id> parentattch = new set<Id>();
    Schema.sObjectType caseObj = Schema.Case.getSObjectType();
    public AttachmentHandler(){}
    
    public void bulkBefore(){}
    public void bulkAfter(){}
    public void beforeInsert(SObject so){}
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterDelete(SObject so){}
    public void afterUpdate(SObject newso, Sobject oldSo){}
    public void afterInsert(SObject so)
    {
        Attachment attach = (Attachment)so;
       
        if(attach.parentId.getSObjectType() == caseObj) {
            parentattch.add(attach.Id);
        }
      
    }
    public void andFinally()
    {
       
        if (!parentattch.isEmpty())
        {
            JiraAutoSyncHelper.SendAttachment(parentattch);
        }
    }
    
}
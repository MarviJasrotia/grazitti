public with sharing  class ContentVersionHandler implements ITrigger{
    Map<id,id> mapofContentDocumentandContentVersion =new Map<id,id>();
    Set<id> FinalContentVersion =new Set<id>();
    Set<id>contentDocumentIdSet= new Set<id>();
    Set<id>linkedCaseid = new Set<id>();
    
    public void bulkBefore(){}
    public void bulkAfter(){
        
        if(ContentVersion.sObjectType.getDescribe().isAccessible()){
            for(ContentVersion Cv:[SELECT Id, ContentDocumentId  FROM ContentVersion WHERE Id in:Trigger.new ]){
                if(Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() && Schema.sObjectType.ContentVersion.fields.id.isAccessible()){
                    mapofContentDocumentandContentVersion.put(Cv.ContentDocumentId,Cv.id);
                }
                if(Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible()){
                    contentDocumentIdSet.add(Cv.ContentDocumentId);
                }
            }
        }
        if(!System.isFuture()){
            
            JiraAutoSyncAttachment.CheckIdList( contentDocumentIdSet,mapofContentDocumentandContentVersion);
        }
        
    }
    public void beforeInsert(SObject so){}
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterDelete(SObject so){}
    public void afterUpdate(SObject newso, Sobject oldSo){}
    public void afterInsert(SObject so){}
    public void andFinally(){ }
}
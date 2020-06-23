public with sharing class FeedItemHandler implements ITrigger{
    Map<String,Set<String>> CaseNumbyIssueKeyMap = New Map<String,Set<String>>();
    Set<String> AlljiraKeys = new  Set<String>();
    Set<Id> SetIds = new Set<Id>(); 
    String JsonCase = '';
    Map<String,String> CaseNumberByCaseId = New Map<String, String>();
    public FeedItemHandler(){
    }
    
    public void bulkBefore(){}
    
    public void bulkAfter(){
        If(Trigger.IsInsert){
            
            for(SObject So: Trigger.new){            	
                FeedItem FI = (FeedItem)So;
                string objectName = FI.ParentId.getSObjectType().getDescribe().getName();
                if(objectName.equalsIgnoreCase('case')){
                    SetIds.add(FI.ParentId);
                }
            }
            if(!SetIds.isEmpty() && case.sObjectType.getDescribe().isAccessible()){
                Map<Id,Case> CaseIdByNumber = New Map<Id,Case>([Select Id,CaseNumber from Case Where Id in: SetIds]);
                For(Id cassId : CaseIdByNumber.KeySet()){
                    CaseNumberByCaseId.put(CaseIdByNumber.get(cassId).CaseNumber , cassId);
                }
                JsonCase = JSON.serialize(CaseNumberByCaseId) != null ? JSON.serialize(CaseNumberByCaseId) : '';
                For(SObject So: Trigger.new){
                    FeedItem feed = (FeedItem)So;
                    if(CaseIdByNumber.containsKey(feed.parentId) && feed.body!= '' && feed.body!= null && 
                       (feed.body.containsIgnoreCase('#[linktojira]') || feed.body.containsIgnoreCase('#linktojira'))){
                           try{
                               String body= Feed.Body.toLowerCase();
                               Pattern p = Pattern.compile('(#\\w*.?\\w*-\\d*)'); 
                               Matcher mo = p.matcher(body); 
                               Set<String> jiraKeys= new Set<String>();
                               while (mo.find()){
                                   String match=mo.group();
                                   match= match.replaceAll('#linktojira.','');                         
                                   jiraKeys.add(match.trim());  
                                   
                               }
                               if(CaseIdByNumber.get(feed.ParentId)!= null){
                                   CaseNumbyIssueKeyMap.put(CaseIdByNumber.get(feed.ParentId).CaseNumber, jiraKeys);
                                   AlljiraKeys.addAll(jiraKeys);
                               }
                           }catch(Exception ex){
                               String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                               GenerateJiraLogs.CreateLogRealTime('FeedItemHandler',null, null, null,null,null, null , null, null, 'bulkafter', Error);
                               
                           }
                       }
                }
            }
        }
        
        If(!CaseNumbyIssueKeyMap.IsEmpty() && !AlljiraKeys.isEmpty() && JsonCase!= ''){
            String JsonMap = JSON.serialize(FeedItemGateway.reverseMap(CaseNumbyIssueKeyMap)) != null ?
                JSON.serialize(FeedItemGateway.reverseMap(CaseNumbyIssueKeyMap)) : '';
            
            if(JsonMap!= ''){
                FeedItemGateway.FinalizeData(JsonMap,JsonCase);
            }
        }
    }
    
    public void beforeInsert(SObject so){}
    
    public void beforeUpdate(SObject oldSo, SObject so){}
    
    public void beforeDelete(SObject so){}
    
    public void afterDelete(SObject so){}
    
    public void afterUpdate(SObject newso, Sobject oldSo){}
    
    public void afterInsert(SObject so){        
    }
    
    public void andFinally(){        
    }
    
}
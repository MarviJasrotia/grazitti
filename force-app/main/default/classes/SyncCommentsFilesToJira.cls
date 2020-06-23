/* controller to send Comments/Files from JiraIssue__c to Jira Manually */

public with Sharing class SyncCommentsFilesToJira {
    public String lang{get;set;}
    public Set<id> commentattach;
    Public List<JiraIssueComments__c> jiracomm=new List<JiraIssueComments__c>();
    public List<JiraErrorLogs__c> jiralog;
    public List<wrapperclass> commentWrapperList{get;set;}
    public List<wrapperclass> attachementWrapperList{get;set;}
    WrapperClass1 wrap1;
    public Map<String,CaseJiraHelper__c > CjHelper;
    map<String,JiraIssueComments__c> response;
    JiraIssue__c jiraIssue = new  JiraIssue__c();
    public integer JiraContentCapacity=0;
    public Set<Id> ContentDocumentIdset=new Set<Id>();
    public List<id> CommentDoc=new List<id>();
    public id parentId;
    JiraSalesforceDetail__c Loginsettings=new JiraSalesforceDetail__c();
    Integer syncItemsNo;
    public Set<String> validAttachmentIdSet;
    public String Responsee='';
    public Set<String> CommentIdSet;
    public list<SelectOption> Languages {get;set;}

    public SyncCommentsFilesToJira(ApexPages.StandardController controller){ 
        lang=userinfo.getLanguage();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
        Languages = JiraService.LanguageOptions();
        commentattach=new Set<id>();
        jiralog=new List<JiraErrorLogs__c>();
        commentWrapperList = new List<wrapperclass>();
        attachementWrapperList = new List<wrapperclass>();
        wrap1=new WrapperClass1();
        CjHelper=new  Map<String,CaseJiraHelper__c> ();
        response=new  Map<String,JiraIssueComments__c> ();
        parentid=controller.getId();
        if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
            jiraIssue = [SELECT Id, IssueId__c,IssueKey__c FROM JiraIssue__c WHERE Id =:  parentid];
        }
        decimal sizeOfFile=0;
        decimal sizeOfFile1=0;
        String FileSize;
      
        JiraSalesforceDetail__c settingss1=JiraSalesforceDetail__c.getInstance('File_Size');
        if(settingss1!=null){
             FileSize=settingss1.value__c;
        }
        if(FileSize != null){
            if(FileSize.contains('MB')){
                FileSize=FileSize.remove('MB');
                sizeOfFile=decimal.valueOf(FileSize.trim());
                decimal d=(1024*1024)* sizeOfFile;
                //string temp=string.valueOf(d);
                //sizeOfFile1=long.valueOf(temp);
                sizeOfFile1=d;
            }
            else{
                FileSize=FileSize.remove('KB');  
                sizeOfFile=decimal.valueOf(FileSize.trim());
                Decimal d=1024* sizeOfFile;
                //string temp=string.valueOf(d);
                //sizeOfFile1=long.valueOf(temp);
                sizeOfFile1=d;
            }
            //String size=string.valueOf(sizeOfFile1);
            JiraContentCapacity = integer.valueOf(sizeOfFile1);
        }else{
            return;
        }
        if(!ContentDocumentLink.sObjectType.getDescribe().isAccessible() || !CaseJiraHelper__c.sObjectType.getDescribe().isAccessible()
           || !ContentVersion.sObjectType.getDescribe().isAccessible() || !JiraIssueComments__c.sObjectType.getDescribe().isAccessible()){
               return;
           }
        
        for(ContentDocumentLink contentdoclink: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentid]){
            if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()){
                ContentDocumentIdset.add(contentdoclink.ContentDocumentId);
            }
        }
        for(CaseJiraHelper__c cjHelper:[select id,name,type__c,jiraissueid__c from CaseJiraHelper__c where jiraissueid__c=:jiraIssue.IssueKey__c ]){
            if(Schema.sObjectType.CaseJiraHelper__c.fields.name.isAccessible()){
                CommentDoc.add(cjHelper.name);
            }
        }
        for(ContentVersion ContentVersionObj : [SELECT Id, Title, CreatedDate,CreatedBy.Name,Jira_Attachment_Id__c, ContentSize,LastModifiedDate FROM ContentVersion WHERE ContentDocumentId in:ContentDocumentIdset ORDER BY CreatedDate DESC]){
        String JiraAttId=String.valueof(ContentVersionObj.JIRA_Attachment_Id__c);
            
            If(!CommentDoc.contains(ContentVersionObj.id) && String.isEmpty(JiraAttId)){
                boolean SizeExceed =false;
                if(ContentVersionObj.contentSize> JiraContentCapacity || ContentVersionObj.contentSize>10000000){
                    SizeExceed=true;
                }
                if(Schema.sObjectType.ContentVersion.fields.Id.isAccessible() && Schema.sObjectType.ContentVersion.fields.Title.isAccessible() &&
                   Schema.sObjectType.ContentVersion.fields.LastModifiedDate.isAccessible() && Schema.sObjectType.ContentVersion.fields.CreatedDate.isAccessible() &&
                   Schema.sObjectType.ContentVersion.fields.ContentSize.isAccessible()){
                       wrapperclass wrapForAttach = new wrapperclass(ContentVersionObj.Id, ContentVersionObj.Title, 'Jira Attachment', ContentVersionObj.CreatedDate.format('MM/dd/yyyy hh:mm a'),ContentVersionObj.ContentSize, ContentVersionObj.LastModifiedDate.format('MM/dd/yyyy hh:mm a'), ConvertAttachmentSize(ContentVersionObj.ContentSize),SizeExceed);
                       attachementWrapperList.add(wrapForAttach);
                   }
                
                if(Schema.sObjectType.ContentVersion.fields.Id.isAccessible()){
                    commentattach.add(ContentVersionObj.Id);
                }
            }
        }
        
        for(JiraIssueComments__c commentObj:[SELECT Id, OwnerId, Name, CreatedById, CommentBody__c,LastModifiedDate ,Comment_Added__c,CreatedDate , CommentId__c, JiraId__c FROM JiraIssueComments__c where JiraIssue__c =:parentid order by lastmodifieddate desc]){
            String inputCommentBody='';
            if(Schema.sObjectType.JiraIssueComments__c.fields.Id.isAccessible()){
                inputCommentBody = commentObj.CommentBody__c;
            }
            inputCommentBody  =  inputCommentBody .replace('<br>',' ');
            
            inputCommentBody = inputCommentBody .replaceAll('<[="#&/a-zA-Z0-9]*>','');
            inputCommentBody = inputCommentBody .replace('<li style="text-align: right;">','');
            inputCommentBody = inputCommentBody .replace('<li style="text-align: center;">','');
            inputCommentBody = inputCommentBody .replace('<p style="text-align: right;">','');
            inputCommentBody = inputCommentBody .replace('<p style="text-align: center;">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#f79232">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#333333">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#707070">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#cccccc">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#205081">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#d04437">',''); 
            inputCommentBody = inputCommentBody .replaceAll('<font color="#f6c342">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#59afe1">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#14892c">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#8eb021">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#654982">','');
            inputCommentBody = inputCommentBody .replaceAll('<font color="#f691b2">','');
            if(Schema.sObjectType.JiraIssueComments__c.fields.Id.isAccessible() && Schema.sObjectType.JiraIssueComments__c.fields.CommentId__c.isAccessible() &&
               Schema.sObjectType.JiraIssueComments__c.fields.JiraId__c.isAccessible() && Schema.sObjectType.JiraIssueComments__c.fields.Comment_Added__c.isAccessible() &&
               Schema.sObjectType.JiraIssueComments__c.fields.CreatedDate.isAccessible() && Schema.sObjectType.JiraIssueComments__c.fields.LastModifiedDate.isAccessible()){
                   wrapperclass wrapForComment = new wrapperclass(commentObj.Id,commentObj.CommentId__c,commentObj.JiraId__c,commentObj.Comment_Added__c, inputCommentBody , 'Jira Comment', commentObj.CreatedDate.format('MM/dd/yyyy hh:mm a'),commentObj.LastModifiedDate.format('MM/dd/yyyy hh:mm a'));
                   commentWrapperList.add(wrapForComment);
               }
            Loginsettings=JiraFileSizeCheck.SizeCheck(); 
        }
    }
    
    public PageReference SendReqToJIRA(){
        
        syncItemsNo =0 ;
        syncItemsNo= syncComments(syncItemsNo);
        syncItemsNo= syncAttachment(syncItemsNo);
        try{
            
            if(!jiracomm.isEmpty() &&   schema.sObjectType.JiraIssueComments__c.isUpdateable() 
               && schema.sObjectType.JiraIssueComments__c.isCreateable()){
                   upsert jiracomm;  
               } 
            
            if(!jiralog.isEmpty() && schema.sObjectType.JiraErrorLogs__c.isUpdateable()
               && schema.sObjectType.JiraErrorLogs__c.isCreateable()){
                   upsert jiralog;
               }
            
            IF(!Test.isRunningTest() && schema.sObjectType.Jira_login__c.isUpdateable()){
                update Loginsettings;
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SyncCommentsFilesToJira',null, null, null,null,null, null , null, null, 'RequestToJira', Error);
        }
        Id id1=ApexPages.currentPage().getParameters().get('id');
        String jirakey = ApexPages.currentPage().getParameters().get('jirakey');
        string genericObjectID = ApexPages.currentPage().getParameters().get('genericObjectID');
        
        Pagereference pageref=new pagereference('/apex/viewjira?id='+id1+'&genericObjectID='+genericObjectID+'&jirakey='+jirakey);
        
        return pageRef;
    }
    public PageReference cancel(){
        Id id1=ApexPages.currentPage().getParameters().get('id');
        String jirakey = ApexPages.currentPage().getParameters().get('jirakey');
        string genericObjectID = ApexPages.currentPage().getParameters().get('genericObjectID');
        Pagereference pageref=new pagereference('/apex/viewjira?id='+id1+'&genericObjectID='+genericObjectID+'&jirakey='+jirakey);
        return pageRef;
    }
    
    public integer syncAttachment(Integer syncItemsNo){
        validAttachmentIdSet = new Set<String>();
        Integer SyncItems=syncItemsNo;
        for(wrapperclass wrapper : attachementWrapperList){ 
            if(wrapper.isSelected == true && wrapper.recordType == 'jira Attachment'){
                if(wrapper.recordSize <= 10000000 && wrapper.recordSize<=JiraContentCapacity){
                    validAttachmentIdSet.add(wrapper.recordId);
                    syncItemsNo = syncItemsNo + 1;
                }     
            }
        }
        if(!validAttachmentIdSet.isEmpty()){
            SendAttachment(validAttachmentIdSet);
            return syncItemsNo;
        }
        return SyncItems;
    }
    
    public integer syncComments(Integer syncItemsNo){
        CommentIdSet = new Set<String>();
        integer SyncItems=syncItemsNo;
        for(wrapperclass wrapper : commentWrapperList){    
            if(wrapper.isSelected == true && wrapper.recordType == 'Jira Comment'){
                CommentIdSet.add(wrapper.RecordId);
                syncItemsNo = syncItemsNo + 1;
            }
        }
        if(!CommentIdSet.isEmpty()){
            SendComment(CommentIdSet);
            return syncItemsNo;
        }  
        return SyncItems;
    }
    
    
    /*** Sends attachment to jira with help of JiraCommentAttechmentService class ***/
    
    public void SendAttachment(Set<String> attachmntIdSet){
        try{
            
            if(!ContentVersion.sObjectType.getDescribe().isAccessible()){
                return;
            }
            
            wrap1=new wrapperclass1();
            List<ContentVersion > ContentList = [SELECT Id, VersionNumber, ContentBodyId, VersionData, FileExtension, FileType, Title, Description, FirstPublishLocationId FROM ContentVersion WHERE Id = :attachmntIdSet];
            List<ContentVersion> contantVersionList=new List<ContentVersion>();
            Map<String,SyncCommentsFilesToJira.WrapperClass1> SendAttachmentSuccessMap=new Map<String,SyncCommentsFilesToJira.WrapperClass1>();
            List<String> contentVersionId=new List<String>();
            for(ContentVersion  attch:ContentList){
                contantVersionList.add(attch);
                contentVersionId.add(attch.id);
                
            }
            SendAttachmentSuccessMap=JiraCommentAttachmentService.SendAttachment(null,contantVersionList,contentVersionId,jiraissue,commentattach);
            
            for(String str: SendAttachmentSuccessMap.keySet()){
                if(wrap1.str=='success'){
                }else{
                    if(wrap1.str=='LIMIT'){
                    }else{
                        wrap1=SendAttachmentSuccessMap.get(str);
                        if(!wrap1.log1.isEmpty()){
                            jiralog.addall(wrap1.log1);
                        }
                    }
                }
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SyncCommentsFilesToJira',null, null, null,null,null, null , null, null, 'SendAttachment', Error);
        }
    }
    public void SendComment(Set<String> cmmntIdSet){
        try{
            Wrap1=new Wrapperclass1();
            
            if(!JiraIssueComments__c.sObjectType.getDescribe().isAccessible()){
                return;
            }
            List<JiraIssueComments__c> comntObj=[SELECT Id, OwnerId, Name,Createdby.name, CreatedById,Source__c, CommentBody__c,LastModifiedDate ,Comment_Added__c,CreatedDate , CommentId__c, JiraId__c FROM JiraIssueComments__c where id =:cmmntIdSet];
            
            
            for(JiraIssueComments__c  com:comntObj){
                Wrap1= JiraCommentAttachmentService.SendComments(jiraIssue,com.id,com.CommentBody__c,com.commentid__c,com.CreatedBy.name,com.source__c);
                if(wrap1.isuuecom.containsKey(com.id)){
                    jiracomm.addall(wrap1.isuuecom.values());
                }else{
                    if(!wrap1.log1.isEmpty()){
                        jiralog.addAll(wrap1.log1);
                    }
                }   
            }
        }Catch(Exception ex)
        {
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            jiralog.add(GenerateJiraLogs.CreateJiraLog('SyncCommentsFilesToJira',null, null, null,null,null, null , null, null, 'SendComment', Error));
        }
    }
    public String ConvertAttachmentSize(Integer aSize){
        String convertedSize = '';
        Decimal fileSize = (Decimal)aSize;
        if(fileSize < 1024){
            convertedSize = fileSize + ' Bytes';
        }else if(fileSize >= 1024 && fileSize < (1024*1024)){
            fileSize = fileSize.divide(1024,2);
            convertedSize = fileSize + ' KB';
        }else if(fileSize >= (1024*1024) && fileSize < (1024*1024*1024)){
            fileSize = fileSize.divide((1024*1024),2);
            convertedSize = fileSize + ' MB';
        }        
        return convertedSize;
    }
    
    /***   A wrapper class to hold case comment and attachment details    ***/
    
    public class Wrapperclass{
        public String recordId{get;set;}
        public boolean recordStatus{get;set;}
        public String recordBody{get;set;}
        public Boolean isSelected{get;set;}
        public String recordType{get;set;}
        public String recordDate{get;set;}
        public Integer recordSize{get;set;}
        public String recordSizeInString{get;set;}
        public String recordLastModifiedDate{get;set;}
        public String recordComId{get;set;}
        public String recordJiraId{get;set;}
        public Boolean recordSizeExceed{get;set;}
        
        public wrapperclass(String recId,String recComId,String recJiraId, boolean recStatus,String recBody, String recType, String recDate,String recLastDate){        
            recordId = recId;
            recordBody = recBody;
            recordType = recType;
            recordDate = recDate;
            recordLastModifiedDate = recLastDate;
            recordStatus=recStatus;
            recordComId=recComId;
            recordJiraId=recJiraId;
        }
        
        public wrapperclass(String recId, String recBody, String recType, String recDate, Integer recSize, String recLastDate ,String recSizeInString ,Boolean SizeExceed){        
            recordId = recId;
            recordBody = recBody;
            recordType = recType;
            recordDate = recDate;
            recordSize = recSize;
            recordSizeInString = recSizeInString;
            recordLastModifiedDate = recLastDate;
            recordSizeExceed =SizeExceed;
        }
    }
    
    public class WrapperClass1{
        public Map<String,JiraIssueComments__c> isuuecom=new Map<String,JiraIssueComments__c>();  
        public List<JiraErrorLogs__c> log1=new List<JiraErrorLogs__c>();
        public String str='';
    }
    Public PageReference LangaugeReset(){
        String parameter='?';
        Boolean HasLang=false;
        String recordid=ApexPages.currentPage().getParameters().get('id')!=null?ApexPages.currentPage().getParameters().get('id'):'';
        String Objectrecordid=ApexPages.currentPage().getParameters().get('genericObjectID')!=null?ApexPages.currentPage().getParameters().get('genericObjectID'):'';
        String jiraKey=ApexPages.currentPage().getParameters().get('jirakey')!=null?ApexPages.currentPage().getParameters().get('jirakey'):'';
        String urllink=Apexpages.currentPage().getUrl();
        if(urllink.contains('?')){
            urllink=urllink.substring(0,urllink.lastIndexOf('?'));
        }
        
        if(recordid!=''){
            parameter+='id='+recordid+'&';
        }
        if(Objectrecordid!=''){
            parameter+='genericObjectID='+Objectrecordid+'&';
        }
        if(jiraKey!=''){
            parameter+='jirakey='+jiraKey+'&';
        }
        parameter+='lg='+lang;
        
        urllink=urllink+parameter;
        return new pageReference(urllink);
    }
}
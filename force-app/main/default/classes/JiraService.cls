/**
* This Class used as a utility class to sync the data of a Jira and Salesforce. 
* Latest modification done to this class on 28/01/2020 By Ashish Thakur 
**/

public with sharing class JiraService {
    /*Salesforce To Jira data mapping map*/
    public static final Map<String,String> sfJiraDataTypeMapping;
    
    /*Jira To Salesforce data mapping map*/
    public static final Map<String,String> jiraSfDataTypeMapping;
    public static String EndPoint;
    
    static {
        sfJiraDataTypeMapping = new Map<String,String>();
        sfJiraDataTypeMapping.put('DATE', 'date');
        sfJiraDataTypeMapping.put('Formula ', 'Text');
        sfJiraDataTypeMapping.put('DATETIME', 'datetime');
        sfJiraDataTypeMapping.put('REFERENCE', 'string');
        sfJiraDataTypeMapping.put('PICKLIST', 'string');
        sfJiraDataTypeMapping.put('DOUBLE', 'string');
        sfJiraDataTypeMapping.put('ID', 'string');
        sfJiraDataTypeMapping.put('STRING', 'string');
        sfJiraDataTypeMapping.put('EMAIL', 'string');
        sfJiraDataTypeMapping.put('TEXTAREA', 'string');
        sfJiraDataTypeMapping.put('Number', 'number');
        sfJiraDataTypeMapping.put('MULTIPICKLIST', 'string');
        sfJiraDataTypeMapping.put('URL', 'string');
        
        jiraSfDataTypeMapping = new Map<String,String>();
        jiraSfDataTypeMapping.put('datetime', 'DATETIME');
        jiraSfDataTypeMapping.put('date', 'DATE');
        jiraSfDataTypeMapping.put('string', 'REFERENCE;PICKLIST;DOUBLE;ID;STRING;EMAIL;TEXTAREA');
        jiraSfDataTypeMapping.put('number', 'Number');
        jiraSfDataTypeMapping.put('option', 'string');
        EndPoint = Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA').End_Point__c!= null ? Jira_login__c.getValues('JIRA').End_Point__c: '' : '';
    } 
    
    public static list<SelectOption> LanguageOptions(){
        List<SelectOption> Langauges= new List<SelectOption>();
        Langauges.add(new SelectOption('en_US','English'));
        Langauges.add(new SelectOption('de','German'));
        Langauges.add(new SelectOption('es','Spanish'));
        Langauges.add(new SelectOption('fr','French'));
        Langauges.add(new SelectOption('it','Italian'));
        Langauges.add(new SelectOption('ja','Japanese'));
        Langauges.add(new SelectOption('sv','Swedish'));
        Langauges.add(new SelectOption('ko','Korean'));
        Langauges.add(new SelectOption('zh_TW','Chinese(Traditional)'));
        Langauges.add(new SelectOption('zh_CN','Chinese(Simplified)'));
        Langauges.add(new SelectOption('pt_BR','Portuguese'));
        Langauges.add(new SelectOption('nl_NL','Dutch'));
        Langauges.add(new SelectOption('da','Danish'));
        Langauges.add(new SelectOption('th','Thai'));
        Langauges.add(new SelectOption('fi','Finnish'));
        Langauges.add(new SelectOption('ru','Russian'));
        Langauges.add(new SelectOption('es_MX','Spanish(Mexico)'));
        Langauges.add(new SelectOption('no','Norwegian'));
        return Langauges;
    }
    /**
* Sends files or attachment from salesforce to jira
**/
    public static Map<String,String> SendAttachment(List<Attachment> attachList,List<ContentVersion>cont, Map<id,set<String>> issueKeyMap){
        Map<String,String> attachmentSuccess=new Map<String,String>();
        Boolean displayError;
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        for(Attachment attach: attachList){
            HttpResponse res;
            Http http;
            Httprequest req;
            try{
                Blob file_body;
                String file_name;
                String boundary = '----------------------------741e90d31eff'; 
                String footer = '--' + boundary + '--';
                String headerEncoded;
                String header;
                String bodyEncoded;
                Blob bodyBlob;
                String last4Bytes;
                
                
                if(Attachment.sObjectType.getDescribe().isAccessible() ){
                    http = new Http();
                    res = new HttpResponse();
                    req = new HttpRequest();
                    file_body = null;
                    file_name = '';
                    boundary = '----------------------------741e90d31eff'; 
                    footer = '--' + boundary + '--';
                    headerEncoded = '';
                    header = '';
                    bodyEncoded = '';
                    bodyBlob = null;
                    last4Bytes = '';
                    if(attach!=null){
                        file_body = attach.Body;
                        file_name = attach.Name;
                        
                    }
                    bodyBlob = null;
                    header = '--' + boundary + '\n' +
                        'Content-Disposition: form-data; name="file"; filename="' + file_name + '";\n' +
                        'Content-Type: application/octet-stream'; 
                    headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
                    
                    while (headerEncoded.endsWith('=')) {
                        header += ' ';
                        headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                    }
                    bodyEncoded = EncodingUtil.base64Encode(file_body);
                    last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
                    if (last4Bytes.endsWith('==')) {
                        last4Bytes = last4Bytes.substring(0, 2) + '0K';
                        bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                        
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    } else if (last4Bytes.endsWith('=')) {
                        last4Bytes = last4Bytes.substring(0, 3) + 'N';
                        bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                        footer = '\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    } else {
                        footer = '\r\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    }
                    if(issueKeyMap.containsKey(attach.id)){
                        Set<String> jiraIssueKeys=issueKeyMap.get(attach.id);
                        
                        for(String issueKey: jiraIssueKeys){
                            
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + issueKey + '/attachments', 'POST', 'multipart/form-data; boundary=' + boundary);
                            req.setHeader('X-Atlassian-Token', 'nocheck');
                            req.setBodyAsBlob(bodyBlob);
                            req.setTimeout(120000);
                            res = http.send(req);
                            
                            if(res.getstatuscode()==200){
                                attachmentSuccess.put(attach.id+'_'+issueKey,'Succcess');
                            }else{
                                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), attach.id, 'Line number 127 inside Attachment loop', res.getBody()));
                                return null;
                            }
                        }
                    }
                } 
                return attachmentSuccess;
            }catch(Exception ex){
                
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), attach.id, 'Line number 127 inside Attachment loop', Error));
                displayError = true; ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, System.label.JiraService_Label1); 
                ApexPages.addMessage(msg);
            }           
        }
        for(ContentVersion attach: cont){
            HttpResponse res;
            Http http;
            Httprequest req;
            try{   
                Blob file_body;
                String file_name;
                String boundary = '----------------------------741e90d31eff'; 
                String footer = '--' + boundary + '--';
                String headerEncoded;
                String header;
                String bodyEncoded;
                Blob bodyBlob;
                String last4Bytes;
                
                
                if(ContentVersion.sObjectType.getDescribe().isAccessible()){
                    http = new Http();
                    res = new HttpResponse();
                    req = new HttpRequest();
                    file_body = null;
                    file_name = '';
                    boundary = '----------------------------741e90d31eff'; 
                    footer = '--' + boundary + '--';
                    headerEncoded = '';
                    header = '';
                    bodyEncoded = '';
                    bodyBlob = null;
                    last4Bytes = '';
                    if(attach!=null){
                        file_body = attach.VersionData;
                        file_name = attach.Title+'.'+attach.FileExtension ;
                        
                    }
                    bodyBlob = null;
                    header = '--' + boundary + '\n' +
                        'Content-Disposition: form-data; name="file"; filename="' + file_name + '";\n' +
                        'Content-Type: application/octet-stream'; 
                    headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
                    
                    while (headerEncoded.endsWith('=')) {
                        header += ' ';
                        headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                    }
                    bodyEncoded = EncodingUtil.base64Encode(file_body);
                    last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
                    if (last4Bytes.endsWith('==')) {
                        last4Bytes = last4Bytes.substring(0, 2) + '0K';
                        bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                        
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    } else if (last4Bytes.endsWith('=')) {
                        last4Bytes = last4Bytes.substring(0, 3) + 'N';
                        bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                        footer = '\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    } else {
                        footer = '\r\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    }
                    if(issueKeyMap.containsKey(attach.id)){
                        Set<String> jiraIssueKeys=issueKeyMap.get(attach.id);
                        for(String issueKey: jiraIssueKeys){
                            
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + issueKey + '/attachments', 'POST', 'multipart/form-data; boundary=' + boundary);
                            req.setHeader('X-Atlassian-Token', 'nocheck');
                            req.setBodyAsBlob(bodyBlob);
                            req.setTimeout(120000);
                            res = http.send(req);
                            if(res.getstatuscode()==200){
                                attachmentSuccess.put(attach.id+'_'+issueKey,'Succcess');
                            }else{
                                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), attach.id, 'Line number 212 inside ContentVersion loop', res.getBody()));
                                return null;
                            }
                        }
                    }
                } 
                return attachmentSuccess;
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), attach.id, 'Line number 212 inside ContentVersion loop', Error));
                displayError = true; ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, System.label.JiraService_Label1); 
                ApexPages.addMessage(msg);
            }   
        }
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
        
        return null;
    }
    
    
    public static  SyncCommentAttachmentsToJira.WrapperClass1 SendComments(List<CaseComment> comlist,Map<ID,Set<String>> commap,Map<string,string> KeyJiraIdmap){
        Map<String,String> CommentSuccess=new Map<String,String>();
        Map<String,String> JiraKeyIssueIdmap=new Map<String,String>();
        set<string> jirakeys=new set<string>();
        SyncCommentAttachmentsToJira.WrapperClass1 wrap=new SyncCommentAttachmentsToJira.WrapperClass1();
        //Boolean displayError;
        List<JiraCommentController__c> controllerlist=new List<JiraCommentController__c>();
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        
        for(CaseComment com:comlist){
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            if(Test.isRunningTest() || !(com.LastModifiedBy.Name).contains('Guest')){
                if(commap.containskey(com.id)){
                    Set<String> jiraIssueKeys=commap.get(com.id);
                    String commentbody=com.CommentBody+'\n (Created by Salesforce :'+Userinfo.getName()+')';
                    for(String issueKey: jiraIssueKeys){
                        try{
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + issueKey + '/comment', 'POST', 'application/json');
                            
                            req.setBody('{"body": "' + commentBody.escapeJava() + '"}');
                            req.setTimeout(120000);
                            res = http.send(req);
                            if(res.getStatusCode()==201 && res.getstatus()=='Created'){
                                CommentSuccess.put(com.id+'_'+issueKey,'Success');
                                JiraCommentController__c jicom=new JiraCommentController__c();
                                
                                String ResBody=res.getbody();
                                ResBody = ResBody.replace('\n', '\\n');
                                
                                Map<String,Object> myobjDeserialized = (Map<String,Object>) JSON.deserializeuntyped(ResBody);
                                
                                if(schema.sObjectType.JiraCommentController__c.fields.CommentId__c.isCreateable()){
                                    jicom.CommentId__c = (String)myobjDeserialized.get('id');
                                }
                                if(schema.sObjectType.JiraCommentController__c.fields.CaseCommentId__c.isCreateable() ){
                                    jicom.CaseCommentId__c=com.id ;
                                }
                                if(schema.sObjectType.JiraCommentController__c.fields.JiraIssueId__c.isCreateable()){
                                    jicom.JiraIssueId__c=KeyJiraIdmap.get(issueKey);
                                }
                                if(schema.sObjectType.JiraCommentController__c.fields.CommentType__c.isCreateable()){
                                    jicom.CommentType__c='CaseComment';
                                }
                                wrap.controllerlist.add(jicom);
                                wrap.IsuueCom.put(com.id+'_'+issuekey,'Success');
                            }else{
                                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(),null , 'Send Comments', res.getBody()));
                                return null;
                            }   
                            
                            
                        }catch(Exception ex){
                            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(),null , 'Send Comments', Error));
                            return null;
                        }
                    } 
                }
            }
            
        }
        
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
        return wrap;
    }
    
    /*public boolean isCommentAttachmentSync(Id caseId, Id commentIdOrattachmentId, Id jiraIssueId){
boolean isExists = false;
return isExists;
}*/
    
    public static String fetchDomain(String jiraUrl){
        Url urlInstance = new Url(jiraUrl);
        return 'https://'+urlInstance.getHost();
    }
    
    
    /**
* Fetch Only Projects from jira 
**/
    /*   public static Map<String,String> fetchProjects(){

Map<String,String> alphabetToProjectsKey=new  Map<String,String>();

HttpRequest req = new HttpRequest(); 
Http http = new Http();
HTTPResponse res;
try {

String jsonInput;
req = CreateJIRAWrapper.CreateRequest('/rest/api/2/project', 'GET', 'application/json');

res =getResponse(req);
jsonInput = res.getBody();

if(res.getStatusCode()==200){
List<Object> Main = (List<Object>) JSON.deserializeUntyped(jsonInput);

for(Object pro: Main){
Map<String, Object> projectDataMap = (Map<String, Object>)pro;

if(!alphabetToProjectsKey.containsKey(String.valueof(projectDataMap.get('name')))){
alphabetToProjectsKey.put(String.valueof(projectDataMap.get('name')),String.valueof(projectDataMap.get('key')));
}
}
return alphabetToProjectsKey;
}else{        
GenerateJiraLogs.CreateLogRealTime('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(),null , 'FetchProjects', res.getBody());

ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, String.valueof(res.getbody())); 
ApexPages.addMessage(msg);
}
}catch(Exception ex){
String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
GenerateJiraLogs.CreateLogRealTime('JiraService',req.getEndpoint(), 'POST',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(),null , 'FetchProjects', Error);

ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, System.label.JiraService_Label1); 
ApexPages.addMessage(msg);
}

return null;
}
*/ 
    /**
*fetches all jira Status from org
**//*
public static Map<String, String> fetchJiraStatus(){
Map<String, String> statusMap = new Map<String, String>();
HttpRequest req = new HttpRequest(); 
req = CreateJIRAWrapper.CreateRequest('/rest/api/2/status', 'GET', 'application/json');

Http http = new Http();
try {
HTTPResponse res;
String jsonInput;
res = http.send(req);
jsonInput = res.getBody();
if( res.getStatusCode()==200){
List<Object> statusList = (List<Object>)JSON.deserializeUntyped(jsonInput);
for(Object status : statusList){
Map<String, Object> statusDataMap = (Map<String, Object>)status;
statusMap.put((String)statusDataMap.get('id'), (String)statusDataMap.get('name'));
}
return statusMap;
}else{
GenerateJiraLogs.CreateLogRealTime('JiraService','/rest/api/2/status', 'GET', String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), null, '', 'Fetch status', Null);
}
}catch(Exception ex){
String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
GenerateJiraLogs.CreateLogRealTime('JiraService','/rest/api/2/status', 'GET', null,null,null, null, null, '', 'Fetch status Exception', Error);
ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getMessage());ApexPages.addMessage(msg);return null;
}
return null;
} 
*/
    /**
*fetch Project details from JIRA instance
**/
    public static list<ProjectWrapper> fetchProjectData(){
        
        list<ProjectWrapper> ProjectWrapperList = new list<ProjectWrapper>();
        HttpRequest req = new HttpRequest(); 
        Http http = new Http();
        HTTPResponse res;
        try {
            
            String jsonInput;
            
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/createmeta', 'GET', 'application/json');
            
            if(req!=NULL && req.getEndpoint()!=NULl && req.getEndpoint()!='')
                res =getResponse(req);
            
            if(res!=NULL && res.getStatusCode()==200){
                jsonInput = res.getBody();
                Map<String, Object> Main = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
                list<Object> projectResponseMap = ( list<Object>)Main.get('projects');
                if(!projectResponseMap.isEmpty()){
                    for(Object project : projectResponseMap){ 
                        if(!(project instanceof String)){
                            Map<String, Object> projectDataMap = (Map<String, Object>)project;
                            ProjectWrapper Projectwarp= new ProjectWrapper();
                            Map<String, String> projectData = new Map<String, String>();
                            if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isCreateable()&&
                               Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isUpdateable()){  
                                   Projectwarp.project.ProjectKey__c=(String)projectDataMap.get('key');
                               }
                            if(Schema.sObjectType.Jira_Project__c.fields.ProjectId__c.isCreateable()&&
                               Schema.sObjectType.Jira_Project__c.fields.ProjectId__c.isUpdateable()){  
                                Projectwarp.project.ProjectId__c=(String)projectDataMap.get('id');
                            }
                            if(Schema.sObjectType.Jira_Project__c.fields.Name.isCreateable()&&
                               Schema.sObjectType.Jira_Project__c.fields.Name.isUpdateable()){  
                                Projectwarp.project.Name=(String)projectDataMap.get('name');
                            }
                            List< Object> IssuetesList=(List< Object>)projectDataMap.get('issuetypes');
                            List<SelectOption> IssueSelect =new  List<SelectOption>(); 
                            List<String> IssueList =new  List<String>(); 
                            List<String> IssueSubList =new  List<String>();
                            List<String> IssueStdList =new  List<String>();
                            
                            
                            for(Integer j=0;j<IssuetesList.size();j++){
                                
                                Map<String, Object> issuemap = (Map<String, Object>)IssuetesList[j];
                                if(Boolean.valueOf(issuemap.get('subtask'))){
                                    IssuesubList.add(String.valueof(issuemap.get('name')));
                                    //continue;
                                }
                                else
                                {
                                    
                                    IssueList.add(String.valueof(issuemap.get('name')));
                                    IssueSelect.add(new SelectOption(String.valueof(issuemap.get('name')),String.valueof(issuemap.get('name'))));
                                    
                                }
                                IssueStdList.add(String.valueof(issuemap.get('name')));
                            }
                            
                            
                            
                            Projectwarp.IssueList= IssueList;
                            Projectwarp.IssueSelectList= IssueSelect;
                            
                            Projectwarp.IssueSubList= IssueSubList;
                            Projectwarp.IssueStdList= IssueStdList;
                            ProjectWrapperList.add(Projectwarp);
                        }
                    }
                }                
                
                return ProjectWrapperList;
            }else{
                GenerateJiraLogs.CreateLogRealTime('jiraservice',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'fetchProjectData', res.getbody());   
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('jiraservice',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'fetchProjectData',Error);   
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }
    
    /**
*fetch all fields from jira under which belongs to an issue type
**/
    public static String fetchIssueDetailsFromJira(String issueKey){
        
        String CurrentJiraProject ='';
        
        if(issueKey!=NULL && issueKey!='')
            CurrentJiraProject=issueKey.substring(0,issueKey.indexof('-'));
        
        if(issueKey!=null){
            String key= issueKey.substring(0,issueKey.indexOf('-'));
        }
        integer count=0;
        String apiName ='';//id,issuetype,status,summary,description,priority,project,reporter,assignee,components,fixVersions,created,creator';
        for(Jira_ProjectFieldsMapping__c field:[SELECT Id,IsStatic__c,Jira_Project__r.Subtask__c, Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c,
                                                ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Projectkey__c,  Jira_Field_Name__c , section__c,Jira_Project__r.IssueType__c,Jira_Project__r.DefaultIssueType__c, section__r.column__c, section__r.name FROM  Jira_ProjectFieldsMapping__c
                                                where Jira_Project__r.Projectkey__c=:CurrentJiraProject order by section__r.order__c,order__c Asc nulls last  limit 1000]){
                                                    
                                                    if(apiName == ''){
                                                        apiName = field.JIRA_Field_Api_Name__c;
                                                    }else{ 
                                                        apiName+= ',' + field.JIRA_Field_Api_Name__c ;
                                                    }                
                                                }
        apiName+=',project';
        
        apiName=EncodingUtil.urlEncode(apiName, 'UTF-8');
        HttpRequest req = new HttpRequest(); 
        Http http = new Http();
        HTTPResponse res;
        try {
            
            String jsonInput;
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+issueKey+'?fields='+apiName ,'GET' ,'application/json');
            
            res= http.send(req);
            
            jsonInput= res.getBody();
            if(res.getStatusCode()==200 ){
                
                return jsonInput;
            }else{
                
                GenerateJiraLogs.CreateLogRealTime('JiraService','/rest/api/latest/issue/', 'GET',String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), null, '', 'Fetch Latest Issue', Null);
            }
        }catch(Exception ex){
            
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JiraService','/rest/api/latest/issue/', 'GET', String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), null, '', 'Fetch Latest Issue', Error);
            
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getMessage());ApexPages.addMessage(msg);return null;
        }
        return null;
    }
    
    public static JiraIssue__c fetchJiraIssueByKey(String issueKey, boolean fetchDetails, Id genericObjID){
        try{
            String jsonInput;
            jsonInput= fetchIssueDetailsFromJira(issueKey);
            
            if(jsonInput==null){
                return null;
            }
            JiraIssue__c jira = new JiraIssue__c();
            Map<String, Object> projectResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            Map<String, Object> issueTypesMap = new Map<String, Object>();                                 
            Object FieldObj=projectResponseMap.get('fields');
            String FieldJson = JSON.serialize(FieldObj);              
            Map<String, Object> FieldSet = (Map<String, Object>)JSON.deserializeUntyped(FieldJson);                
            if(projectResponseMap.get('key')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Name.isCreateable()){
                jira.Name= String.valueOf(projectResponseMap.get('key'));
            }
            
            if(FieldSet.get('description')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Description__c.isCreateable()){
                jira.Description__c= String.valueOf(FieldSet.get('description'));
            }
            
            if(projectResponseMap.get('id')!=NULL && Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isCreateable()){
                jira.IssueId__c=Decimal.valueOf(String.valueOf(projectResponseMap.get('id')));
            }
            
            if(projectResponseMap.get('key')!=NULL && Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isCreateable()){
                jira.IssueKey__c=String.valueOf(projectResponseMap.get('key'));
            }
            
            if(FieldSet.get('issuetype')!=NULL)
                String issuetypedata= JSON.serialize(FieldSet.get('issuetype'));
            
            Map<String, Object> Issuetype =new Map<String, Object>();
            if(FieldSet.get('issuetype')!=NULL)
                Issuetype = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('issuetype')));
            
            if(Issuetype.get('name')!=NULL && Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isCreateable()){
                jira.IssueType__c=String.valueof(Issuetype.get('name'));
            }
            if(Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isCreateable()){
                jira.Jira_Link__c = EndPoint != '' ? EndPoint+ '/browse/' + jira.issueKey__c : '';
            }
            
            if(FieldSet.get('priority')!=NULL){
                Map<String, Object> PriorityMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('priority')));
                
                if(PriorityMap.containskey('name')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Priority__c.isCreateable()){
                    jira.Priority__c=String.valueOf(PriorityMap.get('name'));
                }
            }
            
            Map<String, Object> ProjectMap =new Map<String, Object>();
            if(FieldSet.get('project')!=NULL)
                ProjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('project')));
            
            if(ProjectMap.get('id')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isCreateable()){
                jira.Project_Id__c=Decimal.valueOf(String.valueOf(ProjectMap.get('id')));
            }
            
            if(ProjectMap.get('key')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable()){
                jira.Project__c=String.valueOf(ProjectMap.get('key'));
            }
            
            Map<String, Object> ReporterMap=new Map<String, Object> ();
            if(FieldSet.get('reporter')!=NULL)
                ReporterMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('reporter')));
            
            if(ReporterMap.get('displayName')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Reporter__c.isCreateable()){
                jira.Reporter__c=String.valueOf(ReporterMap.get('displayName'));
            }
            
            Map<String, Object> StatusMap=new Map<String, Object>();
            if(FieldSet.get('status')!=NULL)
                StatusMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('status')));
            
            if(StatusMap.get('name')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Status__c.isCreateable()){
                jira.Status__c=String.valueOf(StatusMap.get('name'));
            }
            
            if(FieldSet.get('summary')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Summary__c.isCreateable()){
                jira.Summary__c=String.valueof(FieldSet.get('summary'));
            }
            
            string resolutionDate = FieldJsonHelper.getFieldData('resolutiondate',projectResponseMap)!='' ? 
                EditAddJiraIssueController.ConvertDate(FieldJsonHelper.getFieldData('resolutiondate',projectResponseMap)) : '';
            if(resolutionDate!='' && Schema.sObjectType.JiraIssue__c.fields.ResolutionDate__c.isCreateable()){
                jira.ResolutionDate__c= DateTime.Parse(resolutionDate);
            }
            if(Schema.sObjectType.JiraIssue__c.fields.Resolution__c.isCreateable()){
                jira.Resolution__c = FieldJsonHelper.getFieldDataForReporting('resolution',projectResponseMap);
            }
            if(Schema.sObjectType.JiraIssue__c.fields.Creator__c.isCreateable()){
                jira.Creator__c = FieldJsonHelper.getFieldDataForReporting('creator',projectResponseMap);
            }
            string created = FieldJsonHelper.getFieldData('created',projectResponseMap)!='' ? 
                EditAddJiraIssueController.ConvertDate(FieldJsonHelper.getFieldData('created',projectResponseMap)) : '';
            if(created!='' && Schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable()){
                jira.Created__c = DateTime.Parse(created);
            }
            
            if(FieldSet.get('assignee')!=null){
                Map<String, Object> assigneeMap =new   Map<String, Object>();
                
                assigneeMap= (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('assignee')));
                
                if(assigneeMap.get('displayName')!=NULL && Schema.sObjectType.JiraIssue__c.fields.Assignee__c.isCreateable()){
                    jira.Assignee__c=assigneeMap.containsKey('displayName')?String.valueof(assigneeMap.get('displayName')):'';
                }
            }
            
            map<String,Jira_Project__c> ProjectkeyToObjectmap = new  map<String,Jira_Project__c>();
            if(Jira_Project__c.sObjectType.getDescribe().isAccessible()){
                for(Jira_Project__c project:[select id,Name,ProjectKey__c,ProjectId__c from Jira_Project__c Limit 1000]){
                    ProjectkeyToObjectmap.put(project.ProjectKey__c,project);
                }
            }
            
            Map<String,String> ReportingFieldsMap=new Map<String,String>() ;
            if(ProjectkeyToObjectmap.containsKey(jira.Project__c)) 
                ReportingFieldsMap=ReportingData.getReportingFieldsMap(String.ValueOf(ProjectkeyToObjectmap.get(jira.Project__c).Id));
            
            String NameSpace='';
            List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization Limit 1];
            if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null)
                NameSpace = ThisOrg[0].NameSpacePrefix.toLowerCase();
            Map<String,String> FieldNameByDataType = New Map<String,String>();
            for(Jira_ProjectFieldsMapping__c s:JiraSFService.fetchJiraCustomFields().values()){
                FieldNameByDataType.put(s.JIRA_Field_Api_Name__c , s.DataType__c);                            
            }
            
            if(!ReportingFieldsMap.isEmpty()){
                Set<String> IssueFields = New Set<String>();
                //NameSpace removed Grz_Sf__jiraIssue__c to jiraIssue__c
                Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('jiraIssue__c').getDescribe().fields.getMap();
                
                for(String sfield: fieldMap.Keyset()) {
                    if(NameSpace!=''){
                        sfield= sfield.toLowerCase().replace(NameSpace.toLowerCase()+'__','');
                    }else{
                        sfield=  sfield.toLowerCase().replace('Grz_Sf__',''); 
                    }
                    IssueFields.add(sfield.toLowerCase());
                }
                
                
                For(String fieldApi : ReportingFieldsMap.keySet()){
                    
                    String val = fieldApi.toLowerCase() + '__c';
                    if(!IssueFields.isEmpty() && IssueFields.contains(val)){
                        
                        String field_val = FieldJsonHelper.getFieldDataForReporting(fieldApi , projectResponseMap);
                        
                        if(field_val!= null && field_val!= ''){
                            if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'float'){
                                jira.put(val , Decimal.ValueOf(field_val));
                            }else if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'datetime'){
                                jira.put(val , DateTime.ValueOf(field_val));
                            }else if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'date' ||
                                     FieldNameByDataType.get(fieldApi).toLowerCase() == 'datepicker'){
                                         jira.put(val , Date.valueOf(field_val));
                                     }
                            else{
                                jira.put(val , field_val);
                                
                            }
                        }
                    }
                }
            }
            
            if(Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isCreateable()){
                jira.JsonData__c=jsonInput; 
            }
            if(schema.sObjectType.JiraIssue__c.isCreateable() ){
                insert jira;
            }
            return jira;
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JiraService',null, null, null,null,null, null , null, '', 'fetchJiraIssueByKey', Error);
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
            ApexPages.addMessage(msg);
            return null;
        }
    } 
    
    /* public static JiraIssue__c fetchJiraIssueByKey(String issueKey, boolean fetchDetails, Id genericObjID){


String jsonInput;
jsonInput= fetchIssueDetailsFromJira(issueKey);


if(jsonInput==null){
return null;
}




Map<String, Object> issueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
String self = '';
String key = '';
String genericObjectName;
Schema.SobjectType ConvertType;

JiraIssue__c jiraIssue = new JiraIssue__c();

if(Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isCreateable() ){
jiraIssue.IssueId__c = Decimal.valueOf(String.valueOf(issueMap.get('id')));
}
if(Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isCreateable() ){
jiraIssue.IssueKey__c = String.valueOf(issueMap.get('key'));
}
if(Schema.sObjectType.JiraIssue__c.fields.name.isCreateable() ){
jiraIssue.name = String.valueOf(issueMap.get('key'));
}
//jiraIssue.Jira_Link__c = fetchDomain(String.valueOf(issueMap.get('self')))+'/browse/'+jiraIssue.IssueKey__c;
if(Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isCreateable() ){
jiraIssue.Jira_Link__c = EndPoint!= '' ? EndPoint + String.valueOf(issueMap.get('key')) : '';
}
Map<String, Object> fieldsMap = (Map<String, Object>)issueMap.get('fields');
if(Schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable() ){
jiraIssue.Created__c = (DateTime)JSON.deserialize('"'+(String)fieldsMap.get('created')+'"', DateTime.class);
}
if(Schema.sObjectType.JiraIssue__c.fields.Summary__c.isCreateable() ){
jiraIssue.Summary__c = (String)fieldsMap.get('summary');
}
if(Schema.sObjectType.JiraIssue__c.fields.Updated__c.isCreateable() ){
jiraIssue.Updated__c = (DateTime)JSON.deserialize('"'+(String)fieldsMap.get('updated')+'"', DateTime.class);

}
Map<String, Object> issueTypeMap = (Map<String, Object>)fieldsMap.get('issuetype');
Map<String, Object> project = (Map<String, Object>)fieldsMap.get('project');
Map<String, Object> priority = (Map<String, Object>)fieldsMap.get('priority');
Map<String, Object> reporter = (Map<String, Object>)fieldsMap.get('reporter');
Map<String, Object> status = (Map<String, Object>)fieldsMap.get('status');
Map<String, Object> assignee = (Map<String, Object>)fieldsMap.get('assignee');

if(Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isCreateable() ){
jiraIssue.IssueType__c = issueTypeMap!=null?String.valueOf(issueTypeMap.get('name')):null;
}
if(Schema.sObjectType.JiraIssue__c.fields.Status__c.isCreateable() ){
jiraIssue.Status__c = status!=null?String.valueOf(status.get('name')):null;
}
if(Schema.sObjectType.JiraIssue__c.fields.Description__c.isCreateable() ){
jiraIssue.Description__c = fieldsMap!=null?String.valueOf(fieldsMap.get('description')):null;
}
map<string,object> mapobj= (map<string,object>)JSON.deserializeUntyped(jsonInput);

if(Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isCreateable() ){
jiraIssue.JsonData__c ='{"fields":'+JSON.serialize(mapobj.get('fields'))+'}';
}
if(Schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable() ){
jiraIssue.Project__c = project!=null?String.valueOf(project.get('key')):null;
}
if(Schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isCreateable() ){
jiraIssue.Project_Id__c = project!=null?Decimal.valueOf(String.valueOf(project.get('id'))):null;

}
if(Schema.sObjectType.JiraIssue__c.fields.Priority__c.isCreateable() ){
jiraIssue.Priority__c = priority!=null?String.valueOf(priority.get('id')):null;
}
if(Schema.sObjectType.JiraIssue__c.fields.Reporter__c.isCreateable() ){
jiraIssue.Reporter__c = reporter!=null?String.valueOf(reporter.get('displayName')):null;
}
if(Schema.sObjectType.JiraIssue__c.fields.Assignee__c.isCreateable() ){
jiraIssue.Assignee__c = assignee!=null?String.valueOf(assignee.get('displayName')):null;
}

if(schema.sObjectType.JiraIssue__c.isCreateable() ){
insert jiraIssue;
}
return jiraIssue;
}*/
    
    /*    
public static String fetchJiraMetadataJson(String projectKeys){

String jiraMetadataJson= null;
HttpRequest req = new HttpRequest();
Http http = new Http();
HTTPResponse res;
try{
req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/createmeta?projectKeys='+projectKeys+'&expand=projects.issuetypes.fields' ,'GET' ,'application/json');
res = getResponse(req);
if(res.getStatusCode()==200){
jiraMetadataJson = res.getBody();
res=null;
return jiraMetadataJson; 
}else{
GenerateJiraLogs.CreateLogRealTime('JiraService','/rest/api/2/issue/createmeta?projectKeys='+projectKeys+'&expand=projects.issuetypes.fields', 'GET', String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), null, '', 'Fetch MetaData', Null);
}
}catch(Exception ex){
String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
GenerateJiraLogs.CreateLogRealTime('JiraService','/rest/api/2/issue/createmeta?projectKeys='+projectKeys+'&expand=projects.issuetypes.fields', 'GET', null, null,null,null, null, '', 'Fetch MetaData', Error);
ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getMessage());ApexPages.addMessage(msg);return null;
}
return null;   
}
*/
    public Static  HttpResponse getResponse(HttpRequest req){
        
        Http http = new Http();
        HTTPResponse res=new HTTPResponse();
        try{
            res = http.send(req);
            return res;
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('jiraservice',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'getResponse', Error);   
            
        }
        return null;
    }
    public static map<String,map<String,Projects.Fieldmeta>> fetchJIRACustomFields(String jiraMetadataJson){
        
        map<String,map<String,Projects.Fieldmeta>> ProjectFieldMap = new map<String,map<String,Projects.Fieldmeta>>();
        
        Map<String, Object> Main = (Map<String, Object>) JSON.deserializeUntyped(jiraMetadataJson);
        
        List< Object> ProjectList=(List< Object>)Main.get('projects');
        Main.clear();
        jiraMetadataJson=null;
        
        //iterate on projects list
        for(Integer i=0;i<ProjectList.size();i++){
            map<String,Projects.Fieldmeta> Fieldmap = new map<String,Projects.Fieldmeta>();
            Map<String, Object> Index = (Map<String, Object>) ProjectList[i];
            List< Object> IssuetesList=(List< Object>)Index.get('issuetypes');
            // iterates on issue lists   
            for(Integer j=0;j<IssuetesList.size();j++){
                Map<String, Object> Fieldlist = (Map<String, Object>)IssuetesList[j];
                
                if(Boolean.valueOf(Fieldlist.get('subtask'))){
                    // continue;
                }
                
                Map<String, Object> finalfieldmap=(Map<String, Object>)Fieldlist.get('fields');
                
                for(String key: finalfieldmap.keySet()){
                    
                    Object JsonObj=finalfieldmap.get(key);
                    String JsonString = JSON.serialize(JsonObj);
                    // clear some heap;
                    JsonObj= null;
                    JSONParser parser = JSON.createParser(JsonString);
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentToken()==JSONToken.START_OBJECT ){ 
                            Projects.Fieldmeta FMeta= new Projects.Fieldmeta();
                            Projects.FieldJson jsondata=( Projects.FieldJson)parser.readValueAs( Projects.FieldJson.class);
                            FMeta.Fieldname=key;
                            String issuelist='';
                            Fmeta.Issuetype=String.valueof(Fieldlist.get('name'));
                            FMeta.Fieldjsondata=jsondata;
                            if(FMeta.Fieldjsondata.required){
                                FMeta.ReqInIssuetype=String.valueof(Fieldlist.get('name'));
                            }else{
                                FMeta.ReqInIssuetype='';
                            }
                            if(Fieldmap.containsKey(FMeta.Fieldname)){
                                if(FMeta.Fieldjsondata.required){
                                    Fmeta.Issuetype+=','+Fieldmap.get(FMeta.Fieldname).Issuetype;
                                    FMeta.ReqInIssuetype+=','+Fieldmap.get(FMeta.Fieldname).ReqInIssuetype;
                                    FMeta.ReqInIssuetype=FMeta.ReqInIssuetype.removeend(',');
                                    Fieldmap.put(FMeta.Fieldname,FMeta);
                                }else{
                                    Fieldmap.get(FMeta.Fieldname).Issuetype+=','+Fieldlist.get('name');
                                }
                            }else{
                                Fieldmap.put(FMeta.Fieldname,FMeta);
                            }
                            
                            
                        }
                    }
                    
                }
                
                
            }
            ProjectFieldMap.put(String.valueof(Index.get('id')) ,Fieldmap);
        }
        
        
        
        return ProjectFieldMap;
    }
    
    public static Map<String,String> checkconnectionstatus(){
        Map<String,String> userNameMap=new Map<String,String>();
        boolean IsSuccess= true;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res=new HTTPResponse();
        try{
            req = CreateJIRAWrapper.CreateRequest('/rest/auth/1/session' ,'GET' ,'application/json');
            
            if(req!=NULL && req.getEndpoint()!=NULL && req.getEndpoint()!=''){
                
                res = getResponse(req);
            }
            
            
            if(res.getstatuscode()== 401 && res.getstatus()=='Unauthorized'){
                IsSuccess=false;
                GenerateJiraLogs.CreateLogRealTime('AdminSettingController-jiraservice','/rest/auth/1/session', 'GET', String.valueOf(res.getStatuscode()), res.getBody(),res.getStatus(), req.getbody(), null, '', 'checkconnectionstatus', '');
                
            }else if(res.getstatuscode()== 200 && res.getstatus()=='OK'){
                IsSuccess=true;
                Map<String,Object> getuserName=(Map<String,Object>)JSON.deserializeUntyped(res.getbody());
                userNameMap.put('true',(String)getuserName.get('name'));
                return userNameMap;
            }
            
            
        } catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('AdminSettingController-jiraservice','/rest/auth/1/session', 'GET',String.valueOf(res.getStatusCode()), res.getBody(),res.getStatus(), req.getbody(), null, '', 'checkconnectionstatus', Error);
            
            
        }
        return null;
    }
    
    
    /*Jira Fields Wrapper starts here*/
    public class JiraFieldsWrapper{
        
        public String name {get; set;}
        public String value {get; set;}
        public String dataType {get; set;}
        public Boolean isArray {get; set;}
        public Boolean isRequired{get;set;}
        public Map<String, Set<String>> projectIssueTypeMap {get; set;}
        
        public JiraFieldsWrapper(){}
    }
    /*Jira Fields Wrapper ends here*/
    
    //JiraWrapper
    public class JiraWrapper{
        
        public List<JiraIssue__c> subTasksList{get; set;}
        public List<String> attachmentsList {get; set;}
        public List<Map<String,String>> attachmentData {get; set;}
        
        public JiraWrapper(){
        }
        
    }
    
}
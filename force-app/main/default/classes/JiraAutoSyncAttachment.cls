public class JiraAutoSyncAttachment {
    
    @future (callout=true)
    public static void CheckIdList(Set<id>contentDocumentIdSet,Map<id,id> mapofContentDocumentandContentVersion){ 
        Set<id>linkedCaseid = new Set<id>(); 
        Set<id>linkedJiraid = new Set<id>();
        if(!ContentDocumentLink.sObjectType.getDescribe().isAccessible()){
            return;
        }
        
        Set<id> FinalContentVersion =new Set<id>();
        if(!contentDocumentIdSet.isEmpty() ){
            List<ContentDocumentLink> contdocmnt=[SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId in :contentDocumentIdSet];
            
            for(ContentDocumentLink CDL:contdocmnt){
                String sobjectType = Id.valueOf(CDL.LinkedEntityId).getSObjectType().getDescribe().getName();
                if(sobjectType.toLowerCase()=='case'){
                    if(Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible()){
                        linkedCaseid.add(CDL.LinkedEntityId);
                    }
                    if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()){
                        FinalContentVersion.add(mapofContentDocumentandContentVersion.get(CDL.ContentDocumentId));
                    }
                }
                
                if(sobjectType.toLowerCase()=='jiraissue__c'){
                    if(Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible()){
                        linkedJiraid.add(CDL.LinkedEntityId);
                    }
                    if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()){
                        FinalContentVersion.add(mapofContentDocumentandContentVersion.get(CDL.ContentDocumentId));
                    }
                }
            }
            
            Jira_login__c settings;
            if(!linkedCaseid.isEmpty()){
                List<Sinergify_Trigger__c> Metdata =new List<Sinergify_Trigger__c>([SELECT Id, Name, IsActive__c FROM Sinergify_Trigger__c where Name='SyncCaseFiles']);
                if(!Metdata.isEmpty() && Metdata[0].IsActive__c){
                    SendFilesToJira(linkedCaseid,linkedJiraid, FinalContentVersion);
                }
            } 
            
            if(!linkedJiraid.isEmpty()){
                SendFilesToJira(linkedCaseid,linkedJiraid, FinalContentVersion);
            }
        }
        
    }
    
    
    @future (callout=true)
    public static void SizeCheck(){
        JiraSalesforceDetail__c settingss=new JiraSalesforceDetail__c();
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() &&
           Schema.sObjectType.JiraSalesforceDetail__c.isCreateable() && 
           Schema.sObjectType.JiraSalesforceDetail__c.isUpdateable() &&
           Schema.sObjectType.JiraSalesforceDetail__c.fields.name.isCreateable() &&
           Schema.sObjectType.JiraSalesforceDetail__c.fields.name.isUpdateable()){
               settingss=JiraSalesforceDetail__c.getInstance('File_Size');
               if(settingss==null){
                   settingss= new JiraSalesforceDetail__c();
                   settingss.name='File_Size';
                   
               }
           }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req=CreateJIRAWrapper.CreateRequest('/rest/api/2/attachment/meta', 'GET', 'application/json');
        try{
            res=http.send(req);
            if(res.getstatuscode()==200){
                String ResponseBody=res.getbody();
                map<string,object> deserialize=(map<string,object>)JSON.deserializeUntyped(ResponseBody);
                
                Object obj1=deserialize.get('uploadLimit');
                String body=JSON.serialize(obj1);
                Long bodyy=long.valueOf( body);
                String JiraStorageCapacity=JiraFileSizeCheck.FileSize(bodyy);
                if(Schema.sObjectType.JiraSalesforceDetail__c.isCreateable() && 
                   Schema.sObjectType.JiraSalesforceDetail__c.isUpdateable() &&
                   Schema.sObjectType.JiraSalesforceDetail__c.fields.value__c.isCreateable() &&
                   Schema.sObjectType.JiraSalesforceDetail__c.fields.value__c.isUpdateable()){  
                       settingss.value__c=JiraStorageCapacity;
                   }                
                if(schema.sObjectType.JiraSalesforceDetail__c.isupdateable() && Schema.sObjectType.Jira_Project__c.isCreateable()){
                    upsert settingss;
                }
            }else{
                GenerateJiraLogs.CreateLogRealTime('JiraAutoSyncAttachment',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'SizeChek', res.getbody());   
                
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JiraAutoSyncAttachment',null, null, null,null,null, null , null, null, 'SizeCheck', Error);
            
        }
    }
    
    public static void SendFilesToJira(Set<id> linkedCaseid,Set<id> linkedJiraid, Set<id> FinalVersion){
        Integer count=0;
        List<ContentVersion> ConttoUpdate= new List<ContentVersion>();
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        Map<Id,List<String>> caseToJira =new Map<id,List<String>>();
        List<ContentVersion> Content=new  List<ContentVersion>();
        if(!JiraRelationship__c.sObjectType.getDescribe().isAccessible() || !CaseJiraHelper__c.sObjectType.getDescribe().isAccessible() || !ContentVersion.sObjectType.getDescribe().isAccessible()){
            return; 
        }    
        Map<Id,String> JiraToJira =new Map<id,String>();
        if(!linkedJiraid.isEmpty()){
            System.debug('jira');
            for(JiraIssue__c jiraKey: [SELECT Id, Name, IssueId__c,IssueKey__c, Jira_Link__c FROM JiraIssue__c WHERE Id IN:linkedJiraid]){
                if(!JiraToJira.containsKey(jiraKey.id)){
                    if(Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isAccessible() && Schema.sObjectType.JiraIssue__c.fields.id.isAccessible()){
                        JiraToJira.put(jiraKey.id,jiraKey.IssueKey__c);
                    }
                }
                
            }
        }
        if(!linkedCaseid.isEmpty()){
            System.debug('case');
            for(JiraRelationship__c jiraKey: [SELECT Id, Name, CaseRelation__c,JiraIssue__c,JiraIssue__r.IssueKey__c, JiraIssueId__c, Jira_Issue_Link__c FROM JiraRelationship__c WHERE CaseRelation__c IN:linkedCaseid]){
                if(caseToJira.containsKey(jiraKey.CaseRelation__c)){
                    caseToJira.get(jiraKey.CaseRelation__c).add(jiraKey.JiraIssue__r.IssueKey__c);
                }else{
                    caseToJira.put(jiraKey.CaseRelation__c,new List<String>{jiraKey.JiraIssue__r.IssueKey__c});
                }
            }
        }
        if(!FinalVersion.isEmpty()){
            
            Content=[SELECT Id, Title, FileExtension, VersionData,ContentSize FROM ContentVersion where id in:FinalVersion];
            
        }
        Map<Id,CaseJiraHelper__c> cjhelperMap = new Map<Id,CaseJiraHelper__c>();
        List<CaseJiraHelper__c> cj = new List<CaseJiraHelper__c>([SELECT id, Name, Type__c, jiraissueid__c FROM CaseJiraHelper__c WHERE Name IN:FinalVersion]);
        for(CaseJiraHelper__c cjh:cj){
            if(Schema.sObjectType.CaseJiraHelper__c.fields.Name.isAccessible()){
                cjhelperMap.put(cjh.Name,cjh);
            }
        }
        
        decimal sizeOfFile=size();
        
        if((!caseToJira.isEmpty() && !Content.isEmpty())||(!JiraToJira.isEmpty() && !Content.isEmpty())){
            for(ContentVersion cont :Content){
                System.debug('---size--'+cont.contentsize);
                if(cont.contentsize<= integer.valueof(sizeOfFile) && cont.contentsize<=10000000){
                    try{
                        Blob file_body; 
                        String file_name;
                        String boundary; 
                        String footer;
                        String headerEncoded;
                        String header;
                        String bodyEncoded;
                        Blob bodyBlob;
                        String last4Bytes;
                        HttpResponse res;
                        Http http;
                        Httprequest req;
                        
                        if(ContentVersion.sObjectType.getDescribe().isAccessible() ){
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
                            file_body = cont.VersionData;
                            file_name = cont.Title+'.'+cont.FileExtension ;
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
                            if(!caseToJira.isEmpty()){
                                System.debug('case');
                                for(String caseno:caseToJira.keySet()){
                                    for(String issueKey:caseToJira.get(caseno)){
                                        count++;
                                        req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + issueKey + '/attachments', 'POST', 'multipart/form-data; boundary=' + boundary);
                                        req.setHeader('X-Atlassian-Token', 'nocheck');
                                        req.setBodyAsBlob(bodyBlob);
                                        req.setTimeout(120000);
                                        
                                        res = http.send(req);
                                        String issueskey='';
                                        
                                        if(res.getStatusCode() == 200){   
                                            if(cjhelperMap.containsKey(cont.id)){
                                                if(cjhelperMap.get(cont.id).jiraissueid__c!=Null){
                                                    issueskey+=issueKey +';';
                                                    cjhelperMap.get(cont.id).jiraissueid__c=cjhelperMap.get(cont.id).jiraissueid__c+issueskey;
                                                }
                                            }
                                            else{
                                                issueskey+=issueKey +';';
                                                CaseJiraHelper__c cjhelp = new CaseJiraHelper__c ();
                                                cjhelp.Name = cont.id;
                                                cjhelp.Type__c='Attachment';
                                                cjhelp.jiraissueid__c = issueskey;
                                                cjhelperMap.put(cont.id,cjhelp);
                                            }
                                            
                                        }else{
                                            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncAttachment',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, issueKey, 'CaseSendFilesToJira', res.getbody()));   
                                        }     
                                        
                                    }
                                    
                                }
                            }
                            if(!JiraToJira.isEmpty()){
                                System.debug('Jira');
                                for(String jiraId:JiraToJira.keySet()){
                                    // for(String issueKey:caseToJira.get(caseno)){
                                    count++;
                                    req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + JiraToJira.get(jiraId) + '/attachments', 'POST', 'multipart/form-data; boundary=' + boundary);
                                    req.setHeader('X-Atlassian-Token', 'nocheck');
                                    req.setBodyAsBlob(bodyBlob);
                                    req.setTimeout(120000);
                                    
                                    res = http.send(req);
                                    String issueskey='';
                                    
                                    if(res.getStatusCode() == 200){   
                                        List<Object> contentResList = (list<Object>)JSON.deserializeUntyped(res.getbody());
                                        for(Object Ob:contentResList){
                                            Map<String,Object> ContentMap =  (Map<String,Object>)Ob;
                                            String AttId = String.valueof(ContentMap.get('id'));
                                            ContentVersion cv= new ContentVersion(id=cont.id);
                                            cv.JIRA_Attachment_Id__c =Decimal.valueOf(AttId);
                                            ConttoUpdate.add(cv);
                                            break;
                                        }
                                        
                                        if(cjhelperMap.containsKey(cont.id)){
                                            
                                        } else {
                                            issueskey=JiraToJira.get(jiraId);
                                            CaseJiraHelper__c cjhelp = new CaseJiraHelper__c ();
                                            cjhelp.Name = cont.id;
                                            cjhelp.Type__c='Attachment';
                                            cjhelp.jiraissueid__c = issueskey;
                                            cjhelperMap.put(cont.id,cjhelp);
                                        }
                                        
                                    }else{
                                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncAttachment',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'SendFilesToJira', res.getbody()));   
                                        
                                    }       
                                    
                                    //  }
                                }
                            }
                        }   
                        
                        
                    }catch(Exception ex){
                        String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncAttachment',null ,null, null, null , null, null, null, null, 'Case Send Files To Jira', Error));
                    } 
                }
            }
        }
        if(!cjhelperMap.isEmpty()){
            try{
                if(schema.sObjectType.CaseJiraHelper__c.isupdateable() && schema.sObjectType.CaseJiraHelper__c.isCreateable()){
                    upsert cjhelperMap.values();
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraAutoSyncAttachment',null, null, null,null,null, null , null, null, 'Upsert CaseJiraHelper', Error);
                
            }
        }
        if(!ConttoUpdate.isEmpty()){
            if(ContentVersion.sObjectType.getDescribe().isAccessible() &&
               ContentVersion.sObjectType.getDescribe().isupdateable() ){
                   update ConttoUpdate;
               }
        }
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
    
    public static Decimal size(){
        decimal sizeOfFile=0;
        decimal sizeOfFilee=0;
        JiraSalesforceDetail__c settingss1=JiraSalesforceDetail__c.getInstance('File_Size');
        String FileSize=settingss1.value__c;
        
        IF(FileSize.contains('MB')){
            
            FileSize=FileSize.remove('MB');
            sizeOfFile=decimal.valueOf(FileSize.trim());
            decimal d=(1024*1024)* sizeOfFile;
            sizeOfFilee=d;
        }ELSE{
            FileSize=FileSize.remove('KB');  
            sizeOfFile=decimal.valueOf(FileSize.trim());
            Decimal d=1024* sizeOfFile;
            sizeOfFilee=d;
        }       
        return sizeOfFilee;
    }
}
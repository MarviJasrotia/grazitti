public class FeedItemGateway{
    public static map<string ,set<string>> reverseMap(Map<String,Set<String>> CaseIdbyIssueKeyMap){
        
        Map<String, Set<String>> IssuesKeybyCaseIds = New 
            Map<String, set<String>>();
        
        For(String casId : CaseIdbyIssueKeyMap.keySet()){
            Set<String> Issues = CaseIdbyIssueKeyMap.get(casId);
            For(String key : Issues){
                Set<String> CaseIds = IssuesKeybyCaseIds.containsKey(key) ?
                    IssuesKeybyCaseIds.get(key) : new Set<String>();
                
                CaseIds.add(casId);
                IssuesKeybyCaseIds.put(key,CaseIds);
            }
        }
        return IssuesKeybyCaseIds;
    }
    
    @future(callout=true)
    public static void FinalizeData(String JsonMap, String JsonCase){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        Jira_login__c adminSettings=new Jira_login__c();
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            adminSettings = Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA'):new Jira_login__c(Name = 'JIRA');
        }
        Map<String,String> CaseNumberByCaseId = New Map<String, String>();
        Map<String,Object> Final_Map = (Map<String,Object>)JSON.deserializeUntyped(JsonMap);
        Map<String,Object> Case_Map = (Map<String,Object>)JSON.deserializeUntyped(JsonCase);
        String caseNumberApi ='test';
        //= CaseNumberField__c.getValues('FieldApi')!=Null?CaseNumberField__c.getValues('FieldApi').JiraFieldApi__c:'';
        String Key='';
        List<FeedItem> FeedstoInsert = New List<FeedItem>();
        Set<String> IssueKeySet = New Set<String>();
        if(caseNumberApi!= ''){
            For(String Map_Val : Final_Map.KeySet()){
                List<Object> IssueSet = (List<Object>)JSON.deserializeUntyped(JSON.Serialize(Final_Map.get(Map_Val)));
                for(Object IssueKey : IssueSet){                
                    if(!Key.contains(String.ValueOf(IssueKey))){
                        Key = Key + '"'+ String.ValueOf(IssueKey)+ '",';
                    }
                }
                if(key!=''){
                    HttpRequest getreq = new HttpRequest();
                    getreq = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+Map_Val, 'GET' ,'application/json');
                    Http gethttp = new Http();
                    HTTPResponse getresponse;
                    try {
                        getresponse = gethttp.send(getreq);
                        if(getresponse.getStatusCode() == 200 && getresponse.getbody()!= null){
                            
                            String responseBody = getresponse.getbody();
                            map<string,Object> obj=(map<string,Object>)JSON.deserializeUntyped(responseBody);
                            String CaseNosVal = FieldJsonHelper.getFieldData(caseNumberApi , obj);
                            if(CaseNosVal!= '' && CaseNosVal!='null'){
                                string existingCases = '';
                                for(String CaseNo:CaseNosVal.removeEnd(',').split(',')){
                                    existingCases+='"'+CaseNo+'",';                                    
                                }
                                for(string str : key.remove('"').Split(',')){
                                    if(!existingCases.contains(str)){
                                        CaseNosVal = existingCases.removeEnd(',') + ',' + Key.removeEnd(',');                                
                                    }
                                }                                
                            }
                            else{
                                CaseNosVal= Key.removeEnd(',');   
                            }
                            CaseNosVal = CaseNosVal.removeEnd(',');
                            String body='{"fields":{"' + caseNumberApi + '":['+ CaseNosVal+']}}';
                            HttpRequest req = new HttpRequest();
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+Map_Val, 'PUT' ,'application/json');
                            req.setBody(body);
                            Http http = new Http();
                            HTTPResponse res;
                            res = http.send(req);
                           
                            if(res.getStatusCode() == 201 || res.getStatusCode() == 204){
                                String postBody = Feedonjiracreation(responseBody);
                                FeedItem post = new FeedItem();
                                post.Body = postBody;
                                post.Title = Map_Val;
                                if(Schema.sObjectType.Jira_login__c.fields.End_Point__c.isAccessible()){
                                    post.LinkUrl = adminSettings.End_Point__c +'/browse/'+Map_Val;
                                }
                                post.ParentId = String.ValueOf(Case_Map.get(key.remove('"').removeEnd(',')));
                                post.Type = 'LinkPost';
                                post.IsRichText = true;
                                FeedstoInsert.add(post);
                            }else{
                                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('FeedItemGateway',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'FinalizeData', res.getbody()));   
                                
                            }
                        }else{
                            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('FeedItemGateway',getreq.getEndPoint(), getreq.getMethod(), String.valueof(getresponse.getstatusCode()),getresponse.getbody(),getresponse.getstatus(), getreq.getbody() , null, null, 'FinalizeData', getresponse.getBody()));   
                        }
                    }catch(Exception ex){
                        String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('FeedItemGateway',getreq.getEndPoint(), getreq.getMethod(), String.valueof(getresponse.getstatusCode()),getresponse.getbody(),getresponse.getstatus(), getreq.getbody() , null, null, 'FinalizeData', Error));   
                        
                    }
                }
            }
            if(!FeedstoInsert.isEmpty()){
                try{
                    if(schema.sObjectType.FeedItem.isCreateable()){
                        insert FeedstoInsert;
                    }
                }catch(Exception ex){
                    String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('FeedItemGateway',null, null, null,null,null, null , null, null, 'Insert FeedItem', Error);
                    
                }
            }
            
            if(!JiraLogsToInsert.isEmpty()){
                Insert JiraLogsToInsert;
            }
        }
    }
    
    public static map<string ,string> reverseCaseMap(Map<String,Case> 
                                                     CaseIdByCase){
                                                         
                                                         Map<String,String> CaseNumberByCaseId = New 
                                                             Map<String, String>();
                                                         
                                                         For(String casId : CaseIdByCase.keySet()){
                                                             CaseNumberByCaseId.put(CaseIdByCase.get(casId).CaseNumber , casId);
                                                         }
                                                         return CaseNumberByCaseId;
                                                     }
    
    public static string Feedonjiracreation(String JsonBody){
        
        Map<string,Object> obj=(map<string,Object>)JSON.deserializeUntyped(JsonBody);
        
        String summary = FieldJsonHelper.getFieldDataForReporting('summary' , obj);
        String status = FieldJsonHelper.getFieldDataForReporting('status' , obj);
        String priority = FieldJsonHelper.getFieldDataForReporting('priority' , obj);
        String reporter = FieldJsonHelper.getFieldDataForReporting('reporter' , obj);
        String assignee = FieldJsonHelper.getFieldDataForReporting('assignee' , obj);
        String body = '';
        Jira_login__c loginSettings=new Jira_login__c();
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            loginSettings = Jira_login__c.getValues('JIRA');
        }
        if(JiraSalesforceDetail__c.getValues('Chatter_Settings').value__c.tolowercase()=='true'){
            
            if(String.isNotEmpty(summary)){
                body = '<p>'+summary+'</p>';
            }
            if(String.isNotEmpty(priority)){
                body += '<p><b>Priority - </b>'+priority+'</p>';
            }
            if(String.isNotEmpty(status)){
                body += '<p><b>Status - </b>'+status+'</p>';
            }
            if(String.isNotEmpty(reporter)){
                body += '<p><b>Reporter - </b>'+reporter+'</p>';
            }
            if(String.isNotEmpty(assignee)){
                body += '<p><b>Assignee - </b>'+assignee+'</p>';
            }
        }
        return body;
    }
}
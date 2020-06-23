global with sharing class SearchJiraIssues{
    global string searchText{get;set;}
    global Map<String, Map<String, Object>> keySummaryMap;
    global List<fieldWrapper> wrapFieldList{get;set;}
    global List<SelectOption> options{get;set;}
    global string projectName{get; set;}
    global set<String> projectKeyNames{get;set;}
    global set<String> SelectedProjects{get;set;}
    global string[] SelectedProjectsSet{get;set;}
    global String keyProjects{get; set;}
    //public Id caseId{get;set;}
    global Id genericObjectID{get;set;}
    String genericObjectName;
    Schema.SobjectType ConvertType;
    
    global SearchJiraIssues(){
        
        keyProjects='';
        SelectedProjectsSet = new String[]{};
            options = new List<SelectOption>();
        options.add(new SelectOption('All', System.label.All_Label));        
        projectKeyNames = new set<String>();
        SelectedProjects = new set<String>();
        if(!Jira_Project__c.sObjectType.getDescribe().isAccessible()){
            return;
        }
        Map<String, Jira_Project__c> project =new Map<String, Jira_Project__c>([select id,Name,ProjectKey__c,ProjectId__c,DefaultIssueType__c, Component__c from Jira_Project__c LIMIT 1000]);
        List<String> projectNames = new List<String>();
        projectNames.addAll(project.keySet());
        projectNames.sort();
        
        // Create the Select Options.
        for (String proName : projectNames) {
            Jira_Project__c projectKey = project.get(proName);
            projectKeyNames.add(project.get(proName).ProjectKey__c);
            options.add(new SelectOption(projectKey.ProjectKey__c,projectKey.ProjectKey__c));
        }
        
        //fetch the generic Object Id
        genericObjectID=ApexPages.CurrentPage().getparameters().get('id');
        //fetch the Object Name 
        if(genericObjectID!=NULL ){
            
            genericObjectName=genericObjectID.getSObjectType().getDescribe().getName();
        }
        
        projectName = (ApexPages.currentPage().getParameters().get('projectName')==null || ApexPages.currentPage().getParameters().get('project') =='')?'-All-':ApexPages.currentPage().getParameters().get('projectName');
        
        searchText= (ApexPages.currentPage().getParameters().get('search')==null || ApexPages.currentPage().getParameters().get('search') =='')?'':ApexPages.currentPage().getParameters().get('search');  
        if(projectName=='-All-' && projectKeyNames.size()>0){
            for(string s : projectKeyNames){
                if(keyProjects == ''){
                    keyProjects ='%28' + s ;
                }
                else{
                    keyProjects+= '%2C' + s ;
                }
                SelectedProjects.add(s);
                SelectedProjectsSet.add(s);
            }
        }else{
            keyProjects='%28'+ projectName;
            SelectedProjects.add(projectName);
            SelectedProjectsSet.add(projectName);
        }
        if(keyProjects != ''){
            keyProjects+='%29';
        }
        //    SearchJiraData(searchText);
    }
    
    global List<fieldWrapper> SearchJiraData(String searchText){
        
        Jira_login__c jiralogin=Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA'):new Jira_login__c();
        wrapFieldList = new List<fieldWrapper>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String jsonInput;
        HttpRequest req = new HttpRequest();
        String encodedSearchText = EncodingUtil.urlEncode(searchText,'UTF-8');
        if(jiralogin.Basic_Authentication__c==true){
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=project%20in' + keyProjects+'%20and(summary~%27'+encodedSearchText+'*%27%20or%20description~%27'+encodedSearchText+'*%27)'+'&fields=id,issuetype,summary,description,priority,project,reporter,assignees', 'GET', 'application/json');
        }else if(jiralogin.Token_Authentication__c==true){
            
            String apiName ='id,issuetype,summary,description,priority,project,reporter,assignees' ;
            apiName=EncodingUtil.urlEncode(apiName, 'UTF-8');
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search?jql=project%20in'+keyProjects+'&Fields='+apiName, 'GET', 'application/json');
            
        }
        try{
            res = http.send(req);
            jsonInput = res.getBody();
            if(res.getStatusCode()==200){
                
                Map<String, Object> projectResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                
                List<Object> issueMap = (List<Object>)projectResponseMap.get('issues');
                Map<String, Object> issueTypesMap = new Map<String, Object>();
                keySummaryMap = new  Map<String, Map<String, Object>>();
                Map<String, Object> issueTypeDataMap = new Map<String, Object>();
                for(Object issue : issueMap){
                    issueTypeDataMap = (Map<String, Object>)issue;
                    if(issueTypeDataMap.get('fields') !=null){
                        issueTypesMap.put((String)issueTypeDataMap.get('key'), (Object)issueTypeDataMap.get('fields'));
                    }
                }
                for(String key: issueTypesMap.keySet()){
                    Object JsonObj=issueTypesMap.get(key);
                    string jsonstring = JSON.serialize(JsonObj);
                    Map<String, Object> descMap = (Map<String, Object>)JSON.deserializeUntyped(jsonstring);
                    
                    String descp = String.valueOf(descMap.get('description'));
                    String summary = String.valueOf(descMap.get('summary'));
                    
                    Object proj = descMap.get('project');
                    string jsonpro = JSON.serialize(proj);
                    Map<String, Object> KeyMap = (Map<String, Object>)JSON.deserializeUntyped(jsonpro);
                    String projKey = String.valueOf(KeyMap.get('key'));
                    if((descp !=null && descp !='' && descp.containsIgnoreCase(searchtext))||summary.containsIgnoreCase(searchtext)){
                        keySummaryMap.put(key,descMap);
                        fieldWrapper wrapFields = new fieldWrapper();
                        if(keySummaryMap.containskey(key)){
                            wrapFields.Id = key;
                            wrapFields.projectsName=projKey ;
                            wrapFields.Summary = (String)keySummaryMap.get(key).get('summary');
                            wrapFields.Description = (String)keySummaryMap.get(key).get('description');
                            wrapFieldList.add(wrapFields);
                        }
                    }
                }  
            }else{
                GenerateJiraLogs.CreateLogRealTime('SearchJiraIssues', req.getEndPoint() , req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), '', null, '', '');
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SearchJiraIssues', req.getEndPoint() , req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), '', null, 'Search Jira Data', Error);
            
        }
        return wrapFieldList;
    } 
    global PageReference SendSearchReqToJIRA(){
        if(searchText.length()>=4 || searchText==''){     
            SearchJiraData(searchText);
        }else{
            wrapFieldList = new List<fieldWrapper>();
        }
        return null;
    }
    
    global void SendProjectName(){
        
        
        projectName = (ApexPages.currentPage().getParameters().get('project')==null || ApexPages.currentPage().getParameters().get('project') =='')?'-All-':ApexPages.currentPage().getParameters().get('project');       
        if(projectName == 'All'){
            SelectedProjects = new set<string>();
            SelectedProjectsSet = new string[]{};
                SelectedProjectsSet.add('All');
            SelectedProjects.addAll(projectKeyNames);
        }else{
            SelectedProjectsSet = new string[]{};
                if(SelectedProjects.contains(projectName)){
                    SelectedProjects.remove(projectName);
                }else{
                    SelectedProjects.add(projectName);
                }
        }
        keyProjects ='';
        for(string s : SelectedProjects){
            SelectedProjectsSet.add(s);
            if(keyProjects == ''){
                keyProjects ='%28' + s ;
            }
            else{
                keyProjects+= '%2C' + s ;
            }
        }
        if(keyProjects != ''){
            keyProjects+='%29';
        }
        SearchJiraData(searchText);
    }
    
    global PageReference linkcasewithjirakey(){
        String returnData;
        String linkjirakey= ApexPages.currentPage().getParameters().get('linkjirakey');
        if(genericObjectID!=Null && linkjirakey!=null){
            returnData= EditAddJiraIssueController.linkIssue(linkjirakey,genericObjectID,genericObjectName);
            if(returnData!=null && returnData!='' ){
                PageReference PgRef = new PageReference('/'+genericObjectID);
                return PgRef;
            }
        }
        return null;
    }
    global PageReference Viewcasewithjirakey(){
        String ViewRelatedIssuesKey = ApexPages.currentPage().getParameters().get('ViewRelatedIssuesKey');
        if(genericObjectID!=Null && ViewRelatedIssuesKey!=null){
            //NameSpace removed Grz_Sf__ViewSearchJira to ViewSearchJira
            PageReference PgRef = new PageReference('/apex/ViewSearchJira?id='+ ViewRelatedIssuesKey+'&type=search&genericObjectID='+genericObjectID);
            PgRef.setRedirect(true);
            return PgRef;
        }
        return null;
    }
    
    global class fieldWrapper{
        public string Id{get;set;}
        public string Summary{get;set;}
        public string Description{get;set;}
        public string IssueType{get;set;}
        public string Reporter{get;set;}
        public string Assignee{get;set;}
        public string Priority{get;set;}
        public string projectsName{get;set;}
        public string JsonData{get;set;}
        
    }
}
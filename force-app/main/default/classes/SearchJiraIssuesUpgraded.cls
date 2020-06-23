global with Sharing class SearchJiraIssuesUpgraded {
        public String lang{get;set;}
    public string searchText{get;set;}
    public List<fieldWrapper> wrapFieldList{get;set;}
    public List<SelectOption> options{get;set;}
    public string projectName{get; set;}
    Public set<String> SelectedProjects{get;set;}
    Public string[] SelectedProjectsSet{get;set;}
    Public string[] SelectedIssueTypeSet{get;set;}   
    public Integer wrappersize{get;set;}
    public String keyProjects{get; set;}
    public Id caseId{get;set;}
    public string srchbtn{get;set;}
    Map<String,Jira_Project__c> ProjectMap=new Map<String,Jira_Project__c>();
    Set<String> selectedProjectsList=new Set<String>();
    public Integer total{get;set;}
    public integer index {get;set;}
    public integer SearchLimit =10;
    public integer TotalPages{get;set;}
    Public List<SelectOption> issuetypesOption{get;set;} 
    Public Set<String> issueTypeSet{get;set;}
    public String issuetypes{get;set;}
    public Integer offset{get;set;}
    public Boolean projectcount {get;set;}
    public Boolean Loaded{get;set;}
    String projectAndIssueTypeQuery;
    Integer count=0;
    public ID genericObjectID{get;set;}
    String genericObjectName{get;set;}
    public list<SelectOption> Languages {get;set;}
    
    global SearchJiraIssuesUpgraded(){
        lang=userinfo.getLanguage();
        Languages = JiraService.LanguageOptions();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
        offset=0;
        index = 0;
        TotalPages = 1;
        Loaded=false;
        projectcount=false;
        wrappersize=0;
        issuetypesOption=new List<SelectOption>();
        issueTypeSet=new Set<String>();
        wrapFieldList = new List<fieldWrapper>();
        keyProjects='';
        SelectedProjectsSet = new List<String>();
        SelectedIssueTypeSet = new List<String>();
        options = new List<SelectOption>();
        
        SelectedProjects = new set<String>();
        if(!Jira_Project__c.sObjectType.getDescribe().isAccessible() || !Jira_login__c.sObjectType.getDescribe().isAccessible()){
            return;
        }
        
        Map<String, Jira_Project__c> project =new Map<String, Jira_Project__c>([select id,Subtask__c,Name,ProjectKey__c,ProjectId__c,DefaultIssueType__c,IssueType__c, Component__c from Jira_Project__c LIMIT 1000]);
        Jira_login__c adminSetting= Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA'):new Jira_login__c(Name = 'JIRA');
        
        List<String> projectNames = new List<String>();
        projectNames.addAll(project.keySet());
        projectNames.sort();
        
        
        // Create the Select Options.
        for(String proName : projectNames) {
            Jira_Project__c projectKey = project.get(proName);
            options.add(new SelectOption(projectKey.Name,projectKey.Name));
            ProjectMap.put(projectKey.Name,projectKey);
            /*if(projectKey.ProjectKey__c==adminSetting.Default_Jira_Project__c){
SelectedProjectsSet.add(projectKey.Name);
}*/
        }
        options.sort();
        // updateIssueTypeList();
        
        //fetch the generic Object Id
        genericObjectID=ApexPages.CurrentPage().getparameters().get('id');
        
        
        //fetch the Object Name 
        if(genericObjectID!=NULL ){
            
            genericObjectName=genericObjectID.getSObjectType().getDescribe().getName();
            
        }
    }
    
    Public PageReference LangaugeReset(){
        return null;
    } 
    
    global List<fieldWrapper> SearchJiraData(String searchTextparam,String startAt){
        /*Start---Modified on 02-07-2019---When JiraIssue is Searched By jiraIssueKey then Hitting Search Botton Shows only those jiraIssues whose IssueType is available on Salesforce*/
        Set<String> IssueTypeval=new Set<String>();
        
        if(SelectedProjectsSet!=NULL && SelectedProjectsSet.size()>0){
            
            for(string pro : SelectedProjectsSet){
                
                if(ProjectMap.containsKey(pro)){
                    
                    String projectkey=ProjectMap.get(pro).ProjectKey__c;
                    if(ProjectMap.get(pro.trim()).IssueType__c!=null){
                        IssueTypeval.addAll(ProjectMap.get(pro.trim()).IssueType__c.split(','));
                    }
                    if(ProjectMap.get(pro.trim()).Subtask__c!=''&&ProjectMap.get(pro.trim()).Subtask__c!=null){
                        IssueTypeval.addAll(ProjectMap.get(pro.trim()).Subtask__c.split(','));
                    }
                }
            }
            
        }
        /*----------modification Ends--------------------*/
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        HttpRequest req = new HttpRequest(); 
        string searchText=searchTextparam.Trim();
        String encodedSearchText = EncodingUtil.urlEncode(searchText,'UTF-8');
        
        String apiName ='id,issuetype,summary,priority,status' ;
        apiName=EncodingUtil.urlEncode(apiName, 'UTF-8');
        //req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=Project%20in%20'+keyProjects+'%20AND%20issuetype%20in%20'+issuetypes+'%20and%28%20summary~%20%27'+encodedSearchText+'%2A%27%20or%20description~%20%27'+encodedSearchText+'%2A%27%29&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
        
        if(searchText.contains('+')){
            List<string> searchlist=searchText.split('\\+');
            integer listsize=searchlist.size();
            
            integer count=0;
            string query='TEXT~%27';
            if(searchlist.size()>0){
                for(string sl:searchlist){
                    query+=sl.Trim()+'%2A%27'; 
                    count++;
                    if(count<listsize)
                        query+='%20OR%20TEXT~%27';
                }
            }
            
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search?jql=%28'+query+'%29%20AND'+projectAndIssueTypeQuery+'%20&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
        }else if(searchText.contains(' ')){
            
            encodedSearchText=encodedSearchText.replaceAll('\\+','%20');
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=TEXT~%27'+encodedSearchText+'%2A%27AND'+projectAndIssueTypeQuery+'%20&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
            
        }else if(searchText.contains('-')){
            
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=%28KEY%3D'+encodedSearchText+'%20OR%20TEXT~%27'+encodedSearchText+'%2A%27%29AND'+projectAndIssueTypeQuery+'%20&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
            
        }else{
            
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=TEXT~%27'+encodedSearchText+'%2A%27AND'+projectAndIssueTypeQuery+'%20&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
            
        }
        try{
            res = http.send(req); 
            String jsonInput;
            jsonInput = res.getBody();
            
            if(res.getStatusCode()==200){
                
                Map<String, Object> projectResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                
                List<Object> issueMap = (List<Object>)projectResponseMap.get('issues');
                total=(Integer)projectResponseMap.get('total');
                TotalPages=Integer.valueOf(math.ceil(total/SearchLimit));
                if(math.mod(total,SearchLimit)>0 ){
                    TotalPages++;
                }  
                
                integer maxResults=(Integer)projectResponseMap.get('maxResults');
                Map<String, Object> IssueKeyToFieldsMap = new Map<String, Object>();
                Map<String, Object> issueTypeDataMap = new Map<String, Object>();
                if(issueMap.isEmpty()){
                    return wrapFieldList; 
                }
                for(Object issue : issueMap){
                    
                    issueTypeDataMap = (Map<String, Object>)issue;
                    if(issueTypeDataMap.get('fields') !=null){
                        IssueKeyToFieldsMap.put((String)issueTypeDataMap.get('key'), (Object)issueTypeDataMap.get('fields'));
                    }
                }
                for(String innerKey: IssueKeyToFieldsMap.keySet()){
                    
                    Object JsonObj=IssueKeyToFieldsMap.get(innerKey);
                    string jsonstring = JSON.serialize(JsonObj);
                    
                    Map<String, Object> descMap = (Map<String, Object>)JSON.deserializeUntyped(jsonstring);
                    object Priorityobject = (object)descMap.get('priority');
                    
                    Map<String, Object> PriorityMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(Priorityobject));
                    String descp=string.valueof(PriorityMap.get('name'));
                    // String descp = String.valueOf(descMap.get('description'));
                    String summary = String.valueOf(descMap.get('summary'));
                    object jirastatusObject =(object)descMap.get('status');
                    Map<String, Object> jiraStatusMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jirastatusObject));
                    string jirastatus='';
                    if(jiraStatusMap.containskey('name'))
                        jirastatus=string.valueof(jiraStatusMap.get('name'));
                    
                    object issuetypeobject = (object)descMap.get('issuetype');
                    Map<String, Object> issueTypeMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(issuetypeobject));
                    String issuetype=string.valueof(issueTypeMap.get('name'));
                    
                    fieldWrapper wrapFields = new fieldWrapper();
                    wrapFields.status = jirastatus;
                    wrapFields.key = innerKey;
                    wrapFields.Summary = summary;
                    wrapFields.Priority  =descp;
                    wrapFields.Issuetype=issuetype;
                    
                    //modified on 02-07-2019
                    if(IssueTypeval.contains(issuetype)){
                        wrapFieldList.add(wrapFields);
                        
                    }
                    
                }
                
            }else{
                GenerateJiraLogs.CreateLogRealTime('SearchJiraIssuesUpgraded', req.getEndPoint() , req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), '', null, '', '');
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SearchJiraIssuesUpgraded', req.getEndPoint() , req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), '', null, 'Search Jira Data', Error);
            
        }
        return wrapFieldList;
    } 
    
    global void SendSearchReqToJIRA(){  
        
        Loaded=true;
        wrapFieldList = new List<fieldWrapper>();
        index=0;
        TotalPages=1;
        integer count=0;
        integer listsize=SelectedProjectsSet.size();      
        projectcount=false;
        if(SelectedProjectsSet.size()>2){
            projectcount=true;
            
            return;
        }
        if(SelectedIssueTypeSet.size()>2){
            projectcount=true;
            return;
        }
        
        if(searchText!='' && searchText.length()>=3 && !searchText.contains('-')){
            wrapFieldList = new List<fieldWrapper>();
            issuetypes='';        
            keyProjects ='';
            projectAndIssueTypeQuery='%28%28%20project%20in%20%28';
            
            Boolean flag=false;
            
            if(SelectedProjectsSet!=NULL && SelectedProjectsSet.size()>0){
                
                for(string pro : SelectedProjectsSet){
                    
                    if(ProjectMap.containsKey(pro)){
                        
                        String projectkey=ProjectMap.get(pro).ProjectKey__c;
                        projectAndIssueTypeQuery+='%27'+projectkey+'%27%29' ;
                        count++;
                        
                        Set<String> IssueTypesSet = new set<String>();
                        String issuetypes='';
                        if(ProjectMap.get(pro.trim()).IssueType__c!=null){
                            IssueTypesSet.addAll(ProjectMap.get(pro.trim()).IssueType__c.split(','));
                            
                            if(ProjectMap.get(pro.trim()).Subtask__c!=null)
                                IssueTypesSet.addAll(ProjectMap.get(pro.trim()).Subtask__c.split(','));
                            for(String type:IssueTypesSet){
                                if(SelectedIssueTypeSet.contains(type)){
                                    flag=true;
                                    if(issuetypes==''){
                                        issuetypes ='%28' + '%27'+ type.replaceAll(' ','%20') +'%27'  ;
                                    }else{
                                        issuetypes+= '%2C' + '%27'+ type.replaceAll(' ','%20') +'%27'  ; 
                                    }
                                }
                            }
                            
                            if(flag==false){
                                if((ProjectMap.get(pro.trim()).DefaultIssueType__c!='') && (ProjectMap.get(pro.trim()).DefaultIssueType__c!=null)){
                                    for(String type:ProjectMap.get(pro.trim()).DefaultIssueType__c.split(',')){
                                        if(issuetypes==''){
                                            issuetypes ='%28' +'%27'+ type.replaceAll(' ','%20') + '%27' ;
                                        }else{
                                            issuetypes+= '%2C' + '%27'+ type.replaceAll(' ','%20') + '%27'  ; 
                                        }
                                    }
                                }
                            }
                            
                            
                            if(issuetypes != ''){
                                issuetypes+='%29';
                                projectAndIssueTypeQuery+='%20AND%20issuetype%20in'+issuetypes+'%29';
                            }
                            
                        }
                        
                    }
                    
                    if(count<listsize)
                        projectAndIssueTypeQuery+='%20OR%20%28project%20in%20%28';
                }
                projectAndIssueTypeQuery+='%29';
                
            }
        }else if(searchText.Trim().contains('-')){
            projectAndIssueTypeQuery='%20project%20in%20%28';
            if(SelectedProjectsSet!=NULL && SelectedProjectsSet.size()>0){
                for(string pro : SelectedProjectsSet){
                    if(ProjectMap.containsKey(pro)){
                        
                        String projectkey=ProjectMap.get(pro).ProjectKey__c;
                        projectAndIssueTypeQuery+='%27'+projectkey+'%27' ;
                        count++;
                        
                        if(count<listsize)
                            projectAndIssueTypeQuery+='%2c';
                        
                    }
                    projectAndIssueTypeQuery+='%29';        
                }
            }
            
        }
        
        if(searchText!='' && searchText.length()>0)
        	SearchJiraData(searchText,'0');
    }
    
    
    
    global PageReference updateIssueTypeList(){
        Set<String> IssueTypesSet = new set<String>();
        issuetypesOption = new List<SelectOption>();
        if(SelectedProjectsSet!=null && !SelectedProjectsSet.isEmpty()){
            for(String Project: SelectedProjectsSet){
                if(ProjectMap.get(Project.trim())!=null){
                    if(ProjectMap.get(Project.trim()).IssueType__c!=null){
                        IssueTypesSet.addAll(ProjectMap.get(Project.trim()).IssueType__c.split(','));
                    }
                    if(ProjectMap.get(Project.trim()).Subtask__c!=null){
                        IssueTypesSet.addAll(ProjectMap.get(Project.trim()).Subtask__c.split(','));
                    }          
                }
            }
            
            
        }
        List<String>IssueTypesSetToList = new LIst<string>();
        IssueTypesSetToList.addAll(IssueTypesSet);
        IssueTypesSetToList.sort();
        for(String Issue:IssueTypesSetToList){
            issuetypesOption.add(new SelectOption(Issue,Issue));
        }
        return null;
    }
    
    
    global PageReference linkcasewithjirakey(){
        
        String returnData;
        String linkjirakey= ApexPages.currentPage().getParameters().get('linkjirakey');
        if(genericObjectID!=Null && linkjirakey!=null){
            returnData= EditAddJiraIssueController.linkIssue(linkjirakey,genericObjectID,genericObjectName);
            
            if(returnData!=null && returnData!='' ){
                PageReference PgRef = new PageReference('/'+genericObjectID);
                PgRef.setRedirect(true);
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
        public string Key{get;set;}
        public string Summary{get;set;}
        public string Description{get;set;}
        public String Issuetype{get;set;}
        public String Status{get;set;}
        public String priority{get;set;}
    }
    
    global void nextPage() {
        wrapFieldList = new List<fieldWrapper>();
        index+=1;
        SearchJiraData(searchText,String.valueOF(index*SearchLimit)); 
        
    }
    global void previousPage() {
        wrapFieldList = new List<fieldWrapper>();
        if(index!=0){
            index-=1;
        }
        SearchJiraData(searchText,String.valueOF(index*SearchLimit));   
    }
}
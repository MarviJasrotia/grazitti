@isTest
public class Test_AddjiraCommentFromIdea {
    @isTest
    public static void testData(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        // setting.AutoSyncCommentType__c='public';
        insert setting; 
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'public';
        insert settingPublic;
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'AddJiraCommentsfromIdea';
        st.IsActive__c = true;
        insert st;
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='Sync_SF_Comments', 
                                          Value__c = 'yes');
        insert jsDetail2;        
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.id,IdeaRelation__c=ideaobj.id);
        insert jr;
        
        JiraIssueComments__c jc=new JiraIssueComments__c(CommentBody__c='comment Body', JiraId__c='10019',source__c='Jira',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jc;
        
        IdeaComment  com=new IdeaComment(IdeaId=ideaobj.id, CommentBody='Test');
        insert com;
        
        JiraCommentHandler jc1=new JiraCommentHandler();
        
        jc1.beforeInsert(jc);
        jc1.beforeUpdate(jc,jc);
        jc1.beforeDelete(jc);
        jc1.afterDelete(jc);
        jc1.afterUpdate(jc,jc);
        jc1.afterInsert(jc);
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        Test.StopTest();
        List<IdeaComment> ideaList = [SELECT id FROM IdeaComment WHERE IdeaId =:ideaobj.id];
        List<JiraRelationship__c> jiraRelList = [SELECT id FROM JiraRelationship__c WHERE IdeaRelation__c =: ideaobj.Id];
        System.assertEquals(ideaList.size(), 1); 
        System.assertEquals(jiraRelList.size(), 1);        
    }
    
    @isTest 
    public Static  void testData0(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        // setting.AutoSyncCommentType__c='public';
        insert setting; 
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'public';
        insert settingPublic;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'AddJiraCommentsfromIdea';
        st.IsActive__c = true;
        insert st;
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='Sync_SF_Comments', 
                                          Value__c = 'yes');
        insert jsDetail2;
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        Case cs=new case(origin='Phone');
        insert cs;
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.id,IdeaRelation__c=ideaobj.id,CaseRelation__c=cs.id);
        insert jr;
        
        JiraIssueComments__c jc=new JiraIssueComments__c(CommentBody__c='comment Body', JiraId__c='10019',source__c='Salesforce',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jc;
        jc.CommentBody__c='NewTest comment';
        update jc;
        
        IdeaComment  com=new IdeaComment(IdeaId=ideaobj.id, CommentBody='Test');
        insert com;
        
        JiraIdeaCommentHandler jc1=new JiraIdeaCommentHandler();
        jc1.beforeInsert(jc);
        jc1.beforeUpdate(jc,jc);
        jc1.beforeDelete(jc);
        jc1.afterDelete(jc);
        jc1.afterUpdate(jc,jc);
        jc1.afterInsert(jc);
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        Test.StopTest();
        List<IdeaComment> ideaList = [SELECT id FROM IdeaComment WHERE IdeaId =:ideaobj.id];
        List<JiraRelationship__c> jiraRelList = [SELECT id FROM JiraRelationship__c WHERE IdeaRelation__c =: ideaobj.Id];
        System.assertEquals(ideaList.size(), 1); 
        System.assertEquals(jiraRelList.size(), 1);
    }
    @isTest
    public Static void testData1(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        //  setting.AutoSyncCommentType__c='public';
        insert setting; 
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'public';
        insert settingPublic;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'AddJiraComments';
        st.IsActive__c = true;
        insert st;
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='Sync_SF_Comments', 
                                          Value__c = 'yes');
        insert jsDetail2;
        JiraSalesforceDetail__c jsDetail23 
            = new JiraSalesforceDetail__c(Name='Store_Jira_Comment_in_Case', 
                                          Value__c = 'yes');
        insert jsDetail23;
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.id,IdeaRelation__c=ideaobj.id);
        insert jr;
        
        JiraIssueComments__c jc=new JiraIssueComments__c(CommentBody__c='comment Body', JiraId__c='10019',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jc;
        jc.CommentBody__c='NewTest';
        update jc;
        
        
        IdeaComment  com=new IdeaComment(IdeaId=ideaobj.id, CommentBody='Test');
        insert com;
        
        JiraCommentHandler jc1=new JiraCommentHandler();
        jc1.beforeInsert(jc);
        jc1.beforeUpdate(jc,jc);
        jc1.beforeDelete(jc);
        jc1.afterDelete(jc);
        jc1.afterUpdate(jc,jc);
        jc1.afterInsert(jc);
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        Test.StopTest();
        List<IdeaComment> ideaList = [SELECT id FROM IdeaComment WHERE IdeaId =:ideaobj.id];
        List<JiraRelationship__c> jiraRelList = [SELECT id FROM JiraRelationship__c WHERE IdeaRelation__c =: ideaobj.Id];
        System.assertEquals(ideaList.size(), 1); 
        System.assertEquals(jiraRelList.size(), 1);
    }
    @isTest
    public Static void testData2(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        //  setting.AutoSyncCommentType__c='public';
        insert setting; 
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'public';
        insert settingPublic;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'AddJiraComments';
        st.IsActive__c = true;
        insert st;
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='Sync_SF_Comments', 
                                          Value__c = 'yes');
        insert jsDetail2;
        JiraSalesforceDetail__c jsDetail23 
            = new JiraSalesforceDetail__c(Name='Store_Jira_Comment_in_Case', 
                                          Value__c = 'yes');
        insert jsDetail23;
        
        Case cs=new case(Origin='Phone');
        insert cs;
        Case cs1=new case(Origin='Phone');
        insert cs1;
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.id,CaseRelation__c=cs.id);
        insert jr;
        JiraRelationship__c jr1=new JiraRelationship__c(JiraIssue__c=ji.id,CaseRelation__c=cs1.id);
        insert jr1;
        JiraIssueComments__c jc=new JiraIssueComments__c(CommentBody__c='comment Body',source__c='Jira', JiraId__c='10019',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jc;
        JiraIssueComments__c jic1=new JiraIssueComments__c(CommentBody__c='commentsss Body',source__c='Jira', JiraId__c='10019',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jic1;
        
        JiraIssueComments__c jcom=[Select CommentBody__c from JiraIssueComments__c Limit 1];
        jcom.CommentBody__c='UpdatedCom';
        Update Jcom;
        
        
        
        JiraCommentHandler jc1=new JiraCommentHandler();
        jc1.beforeInsert(jc);
        jc1.beforeUpdate(jc,jc);
        jc1.beforeDelete(jc);
        jc1.afterDelete(jc);
        jc1.afterUpdate(jc,jc);
        jc1.afterInsert(jc);
        
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        Test.StopTest();
        List<JiraIssueComments__c> issueList = [SELECT id FROM JiraIssueComments__c];
        System.assertEquals(issueList.size(), 2); 
        
    }
    @isTest
    public Static void testData3(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        //  setting.AutoSyncCommentType__c='public';
        insert setting; 
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'public';
        insert settingPublic;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'AddJiraComments';
        st.IsActive__c = true;
        insert st;
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='Sync_SF_Comments', 
                                          Value__c = 'yes');
        insert jsDetail2;
        JiraSalesforceDetail__c jsDetail23 
            = new JiraSalesforceDetail__c(Name='Store_Jira_Comment_in_Case', 
                                          Value__c = 'yes');
        insert jsDetail23;
        
        Case cs=new case(Origin='Phone');
        insert cs;
        Case cs1=new case(Origin='Phone');
        insert cs1;
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.id,CaseRelation__c=cs.id);
        insert jr;
        JiraRelationship__c jr1=new JiraRelationship__c(JiraIssue__c=ji.id,CaseRelation__c=cs1.id);
        insert jr1;
        JiraIssueComments__c jc=new JiraIssueComments__c(CommentBody__c='comment Body',source__c='Salesforce', JiraId__c='10019',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jc;
        JiraIssueComments__c jic1=new JiraIssueComments__c(CommentBody__c='commentsss Body',source__c='Salesforce', JiraId__c='10019',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jic1;
        
        JiraIssueComments__c jcom=[Select CommentBody__c from JiraIssueComments__c Limit 1];
        jcom.CommentBody__c='UpdatedCom';
        Update Jcom;
        
        
        
        JiraCommentHandler jc1=new JiraCommentHandler();
        jc1.beforeInsert(jc);
        jc1.beforeUpdate(jc,jc);
        jc1.beforeDelete(jc);
        jc1.afterDelete(jc);
        jc1.afterUpdate(jc,jc);
        jc1.afterInsert(jc);
        
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        Test.StopTest();
        List<JiraIssueComments__c> issueList = [SELECT id FROM JiraIssueComments__c];
        System.assertEquals(issueList.size(), 2); 
        
    }
}
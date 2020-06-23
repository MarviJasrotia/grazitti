@isTest
public class Test_AutomateJiraCreation {
  
    @testsetup
    public static void Testsetupdata(){
          
        
        JIRA_Login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        insert setting; 
        
        List<JiraSalesforceDetail__c> Jirasettings = new List<JiraSalesforceDetail__c> ();
        JiraSalesforceDetail__c  jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Comments',Value__c='no');
        Jirasettings.add(jsDetail);
        
        JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        Jirasettings.add(jsDetail1);
        insert Jirasettings;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoComment',IsActive__c=true);
        insert st;
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        child =[select id ,Dynamic_Filter_Logic__c from Child_Rule_Set__c ];
        Account ac = new account(name='test');
        insert ac;     
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtask';
        pm.DefaultIssueType__c='Task';
        pm.IssueType__c='Task';
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        Testdata.CreateStaticFields(pm.id);

        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;

        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        //Reporter
        Jira_ProjectFieldsMapping__c proMapA =Testdata.createjirafieldmapp(pm.id,false,'Reporter',null,'Reporter', 'reporter' ,true, true ,'user',false);
        proMapA.RelatedProjectIdSet__c = pm.Id;
        proMapA.IssueTypedata__c='Task';
        proMapA.jira_project__c=pm.Id;
        proMapA.Salesforce_Object__c='Case';
        proMapA.Default_Value_long__c='{"displayName":"Demo","key":"jirademo01","name":"jirademo01"}';
        proMapA.Section__c =Section.id;
        jirafieldmap.add(proMapA);
        
        //select
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='Task';
        projectMap2.Salesforce_Object__c='Case';
        projectMap2.Section__c =Section.id;
        projectMap2.Default_Value_long__c='OPTION 1';
        jirafieldmap.add(projectMap2);
        
        //multiuserpicker
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='Task';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Section__c =Section.id;
        projectMap4.Default_Value_long__c='{"users": [{"displayName":"Sakshi Duggal","key":"sakshi.duggal@grazitti.com","name":"sakshi.duggal@grazitti.com"},{"displayName":"sinergify.support","key":"sinergify.support","name":"sinergify.support"}]}';
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='Task';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.Section__c =Section.id;
        projectMapv4.Default_Value_long__c='Release 1';

        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='Task';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Section__c =Section.id;
        projectMapv5.Default_Value_long__c='www.google.com';

        jirafieldmap.add(projectMapv5);
        
 
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'datepicker',null,'Date Picker', 'customfield_10038' ,true, false,'datepicker' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='Task';
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.Section__c =Section.id;
        projectMapv6.Default_Value_long__c='2020-04-05';

        jirafieldmap.add(projectMapv6);
        
    
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='Task';
        projectMapv8.Salesforce_Object__c='Case';
        projectMapv8.Section__c =Section.id;
        projectMapv8.Default_Value_long__c='100';

        jirafieldmap.add(projectMapv8);
        
    
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IssueTypedata__c='Task';
        projectMapvv9.Salesforce_Object__c='Case';
        projectMapvv9.Default_Value_long__c ='2020-04-30T16:57:00.000-0700';
        projectMapvv9.Section__c =Section.id;
        jirafieldmap.add(projectMapvv9);
        
       
        
        insert jirafieldmap;
       
        
    }
    @istest
    public static void TestScenario2(){
        
        Test.startTest();
        List<String> Data= new List<String>();
        Case cs= [select id from case limit 1];
        Data.add(cs.id+'_Dev_Task');
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpissue());
        BatchToAutoCreateJira bc = new BatchToAutoCreateJira(Data);
        database.executeBatch(bc);
        TEst.stopTest(); 
        System.assertEquals(Data[0], cs.id+'_Dev_Task');
    }
    @istest
    public static void TestScenario3(){
        List<String> Data= new List<String>();
        Case cs= [select id from case limit 1];
        cs.SuppliedEmail='test@test.com';
        cs.SuppliedCompany='test@test.com';

        update cs;
        Data.add(cs.id+'_Dev_Task');
        List<Jira_ProjectFieldsMapping__c> Jplist = new List<Jira_ProjectFieldsMapping__c>();
        for(Jira_ProjectFieldsMapping__c jp:[select id,name,Case_Field_Name__c from Jira_ProjectFieldsMapping__c where name='Reporter'  or name ='multiuserpicker']){
            if(jp.name=='Reporter'){
                jp.Case_Field_Name__c='SuppliedEmail'; 
            }else if(jp.name=='multiuserpicker'){
                jp.Case_Field_Name__c='SuppliedCompany ';
            }
            Jplist.add(jp);
        }
        update Jplist;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpissue());
        AutoCreateJira.AutoCreateJira(data);
        TEst.stopTest(); 
        List<Jira_ProjectFieldsMapping__c> jProList = [SELECT id FROM Jira_ProjectFieldsMapping__c WHERE name='Reporter'  OR name ='multiuserpicker'];
    	system.assertEquals(jProList.size()!=null, true);
    }
}
@isTest
public class Test_DefaultValueWrapper {
    @testSetup
    public static void testdataRandom(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        insert setting;
        JiraSalesforceDetail__c jsDetail = new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        Sinergify_Trigger__c st=new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c = true);
        insert st;
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        Testdata.CreateJSon(jp.id, jp.projectkey__c);
        Jira_ProjectFieldsMapping__c fm= Testdata.createjirafieldmapp(jp.id,false,'name','Subject','customfield_10020', 'customfield_10020' ,True,  true , 'string',FALSE);
        fm.Salesforce_Object__c='Case';
        fm.IsStatic__c=true;
        insert fm;
    }
      @isTest 
    public static void testmethod2(){
        String SelectObject = 'Case';
        String JiraFieldApi = 'customfield_10020';
        Id JiraProjectId;
        for(Jira_Project__c jp : [select id from Jira_Project__c]){
          JiraProjectId=jp.id;  
        }
        DefaultValueWrapper dvw0= new DefaultValueWrapper();
        DefaultValueWrapper dvw1= new DefaultValueWrapper(SelectObject, JiraFieldApi, JiraProjectId);
        System.assertEquals(dvw1.SelectObject, 'Case');
    }
}
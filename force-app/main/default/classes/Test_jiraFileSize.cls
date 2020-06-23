@isTest
public class Test_jiraFileSize {
    
    public Static TestMethod void testData(){
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        insert setting; 
        
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'File_Size';
        jsd.Value__c = '10 MB';
        insert jsd;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpViewKey());
        JiraFileSizeCheck.SizeCheck();
        TEst.StopTest();
    }
}
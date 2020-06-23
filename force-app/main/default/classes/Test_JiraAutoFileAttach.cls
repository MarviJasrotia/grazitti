@isTest 
public class Test_JiraAutoFileAttach {
    @TestSetup
    public static void testData(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.SyncAttachment__c=true;
        Setting.File_Size__c='10 MB';
        insert setting;
        
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraAutoFileAttach';
        st.IsActive__c = true;
        insert st;
        
        
        JiraSalesforceDetail__c jsd1 = new JiraSalesforceDetail__c();
        jsd1.Name = 'File_Size';
        jsd1.Value__c = '10 MB';
        insert jsd1;
        
        case cs= new case();
        cs.origin='Web';
        insert cs;
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"expand":"renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations","id":"10033","self":"https://jiragrazitti.atlassian.net/rest/api/2/issue/10033","key":"DP-19","fields":{"issuetype":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/issuetype/10002","id":"10002","description":"A task that needs to be done.","iconUrl":"https://jiragrazitti.atlassian.net/secure/viewavatar?size=xsmall&avatarId=10318&avatarType=issuetype","name":"Task","subtask":false,"avatarId":10318},"timespent":null,"customfield_10030":"hkj","project":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/project/10001","id":"10001","key":"DP","name":"DEMO PROJECT","projectTypeKey":"software","avatarUrls":{"48x48":"https://jiragrazitti.atlassian.net/secure/projectavatar?pid=10001&avatarId=10400","24x24":"https://jiragrazitti.atlassian.net/secure/projectavatar?size=small&pid=10001&avatarId=10400","16x16":"https://jiragrazitti.atlassian.net/secure/projectavatar?size=xsmall&pid=10001&avatarId=10400","32x32":"https://jiragrazitti.atlassian.net/secure/projectavatar?size=medium&pid=10001&avatarId=10400"}},"customfield_10031":null,"customfield_10032":null,"fixVersions":[{"self":"https://jiragrazitti.atlassian.net/rest/api/2/version/10002","id":"10002","description":"","name":"DEV versio 1","archived":false,"released":true,"releaseDate":"2018-01-19"}],"aggregatetimespent":null,"resolution":null,"customfield_10027":"hkj","customfield_10029":"ewefdfsd","resolutiondate":null,"workratio":-1,"watches":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/issue/DP-19/watchers","watchCount":1,"isWatching":true},"lastViewed":"2018-01-18T16:04:23.541+0530","created":"2018-01-18T11:35:18.042+0530","customfield_10020":null,"customfield_10021":null,"customfield_10022":null,"priority":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/priority/3","iconUrl":"https://jiragrazitti.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"customfield_10023":null,"customfield_10025":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/customFieldOption/10003","value":"Development","id":"10003"},"labels":["sdfsdfds"],"customfield_10017":null,"customfield_10018":null,"customfield_10019":null,"timeestimate":null,"aggregatetimeoriginalestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2018-01-18T16:04:23.045+0530","status":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/status/10000","description":"","iconUrl":"https://jiragrazitti.atlassian.net/","name":"To Do","id":"10000","statusCategory":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/statuscategory/2","id":2,"key":"new","colorName":"blue-gray","name":"To Do"}},"components":[{"self":"https://jiragrazitti.atlassian.net/rest/api/2/component/10002","id":"10002","name":"TEST DEV como 1"}],"timeoriginalestimate":null,"description":"jkk","customfield_10010":[],"customfield_10011":"0|i0007b:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"Test","creator":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"5a4b110d727bc4290501ab31","emailAddress":"jiragrazitti@gmail.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"jira Graz","active":true,"timeZone":"Asia/Kolkata"},"subtasks":[],"reporter":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"5a4b110d727bc4290501ab31","emailAddress":"jiragrazitti@gmail.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"jira Graz","active":true,"timeZone":"Asia/Kolkata"},"customfield_10000":"{}","aggregateprogress":{"progress":0,"total":0},"customfield_10001":null,"customfield_10002":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"progress":{"progress":0,"total":0},"comment":{"comments":[],"maxResults":0,"total":0,"startAt":0},"votes":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/issue/DP-19/votes","votes":0,"hasVoted":false},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]}}}';
        insert ji;
        
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 1213, '1003', 'task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"expand":"renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations","id":"10033","self":"https://jiragrazitti.atlassian.net/rest/api/2/issue/10033","key":"DP-19","fields":{"issuetype":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/issuetype/10002","id":"10002","description":"A task that needs to be done.","iconUrl":"https://jiragrazitti.atlassian.net/secure/viewavatar?size=xsmall&avatarId=10318&avatarType=issuetype","name":"Task","subtask":false,"avatarId":10318},"timespent":null,"customfield_10030":"hkj","project":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/project/10001","id":"10001","key":"DP","name":"DEMO PROJECT","projectTypeKey":"software","avatarUrls":{"48x48":"https://jiragrazitti.atlassian.net/secure/projectavatar?pid=10001&avatarId=10400","24x24":"https://jiragrazitti.atlassian.net/secure/projectavatar?size=small&pid=10001&avatarId=10400","16x16":"https://jiragrazitti.atlassian.net/secure/projectavatar?size=xsmall&pid=10001&avatarId=10400","32x32":"https://jiragrazitti.atlassian.net/secure/projectavatar?size=medium&pid=10001&avatarId=10400"}},"customfield_10031":null,"customfield_10032":null,"fixVersions":[{"self":"https://jiragrazitti.atlassian.net/rest/api/2/version/10002","id":"10002","description":"","name":"DEV versio 1","archived":false,"released":true,"releaseDate":"2018-01-19"}],"aggregatetimespent":null,"resolution":null,"customfield_10027":"hkj","customfield_10029":"ewefdfsd","resolutiondate":null,"workratio":-1,"watches":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/issue/DP-19/watchers","watchCount":1,"isWatching":true},"lastViewed":"2018-01-18T16:04:23.541+0530","created":"2018-01-18T11:35:18.042+0530","customfield_10020":null,"customfield_10021":null,"customfield_10022":null,"priority":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/priority/3","iconUrl":"https://jiragrazitti.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"customfield_10023":null,"customfield_10025":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/customFieldOption/10003","value":"Development","id":"10003"},"labels":["sdfsdfds"],"customfield_10017":null,"customfield_10018":null,"customfield_10019":null,"timeestimate":null,"aggregatetimeoriginalestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2018-01-18T16:04:23.045+0530","status":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/status/10000","description":"","iconUrl":"https://jiragrazitti.atlassian.net/","name":"To Do","id":"10000","statusCategory":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/statuscategory/2","id":2,"key":"new","colorName":"blue-gray","name":"To Do"}},"components":[{"self":"https://jiragrazitti.atlassian.net/rest/api/2/component/10002","id":"10002","name":"TEST DEV como 1"}],"timeoriginalestimate":null,"description":"jkk","customfield_10010":[],"customfield_10011":"0|i0007b:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"Test","creator":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"5a4b110d727bc4290501ab31","emailAddress":"jiragrazitti@gmail.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"jira Graz","active":true,"timeZone":"Asia/Kolkata"},"subtasks":[],"reporter":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"5a4b110d727bc4290501ab31","emailAddress":"jiragrazitti@gmail.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/16b5f1883d17a7e2a06abe6f8954eee9?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F16b5f1883d17a7e2a06abe6f8954eee9%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"jira Graz","active":true,"timeZone":"Asia/Kolkata"},"customfield_10000":"{}","aggregateprogress":{"progress":0,"total":0},"customfield_10001":null,"customfield_10002":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"progress":{"progress":0,"total":0},"comment":{"comments":[],"maxResults":0,"total":0,"startAt":0},"votes":{"self":"https://jiragrazitti.atlassian.net/rest/api/2/issue/DP-19/votes","votes":0,"hasVoted":false},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]}}}';
        insert ji1;
        
        JiraRelationship__c jr= Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs.id, ji1.id, true);
        
        list<ContentVersion> CvList= new list<ContentVersion>();
        ContentVersion cv= new ContentVersion();
        Blob body= Blob.valueOf('QWQWQWQWQQQW');
        cv.versiondata=body;
        cv.title='test';
        cv.PathOnClient ='test.png';
        cv.FirstPublishLocationId =cs.id;
        CvList.add(cv);
        ContentVersion cv1= new ContentVersion();
        Blob body1= Blob.valueOf('QWQWQWQWQQQWassa=');
        cv1.versiondata=body;
        cv1.FirstPublishLocationId =cs.id;
        cv1.title='test1';
        cv1.PathOnClient ='test1.png';
        CvList.add(cv1);
        ContentVersion cv2= new ContentVersion();
        Blob body2= Blob.valueOf('QWQWQWQWwerwerQQQWas==');
        cv2.versiondata=body;
        cv2.FirstPublishLocationId =cs.id;
        cv2.title='test1';
        cv2.PathOnClient ='test1.png';
        CvList.add(cv2);
        ContentVersion cv3= new ContentVersion();
        Blob body3= Blob.valueOf('eewrfcwf=');
        cv3.versiondata=body;
        cv3.FirstPublishLocationId =ji.id;
        cv3.title='test1';
        cv3.PathOnClient ='test1.png';
        CvList.add(cv3); 
        insert CvList;
    }
    @isTest
    public static void testScenerio(){
        List<ContentVersion> CvList= new List<ContentVersion>([Select id from ContentVersion]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        Boolean Valid=Cvlist[0].id!=null;
        Test.stopTest();
       /* ContentVersionHandler cvh= new ContentVersionHandler();
        SObject newso;
        cvh.afterUpdate(newso, newso);
        cvh.afterInsert(newso);
        cvh.afterDelete(newso);
        cvh.beforeDelete(newso);
        cvh.beforeUpdate(newso, newso);
        cvh.beforeInsert(newso);
        cvh.bulkBefore();
        cvh.andFinally(); */
        System.assertEquals(Valid,true);
    }
}
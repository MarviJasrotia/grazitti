@isTest public class Test_AdminSettingController {
   
   @istest 
    public static void testScenerio0s(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=false;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        List<JiraSalesforceDetail__c> JiraSFDetails= new List<JiraSalesforceDetail__c>();
        JiraSalesforceDetail__c jsDetail = new JiraSalesforceDetail__c();
        jsDetail.Name='Sync_SF_Attachment';
        jsDetail.value__c='yes';
        JiraSFDetails.add(jsDetail);
        JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',value__c='public');
        JiraSFDetails.add(jsDetail1);
        JiraSalesforceDetail__c jsDetail2=new JiraSalesforceDetail__c(Name='Jira_Comment_As_Private',Value__c='yes');
        JiraSFDetails.add(jsDetail2);
        JiraSalesforceDetail__c jsDetail3=new JiraSalesforceDetail__c(Name='JiraCommentsSyncToJiraIssue',Value__c='yes');
        JiraSFDetails.add(jsDetail3);
       
        JiraSalesforceDetail__c jsDetail5 
            = new JiraSalesforceDetail__c(Name='Store_Jira_Comment_in_Case', 
                                          Value__c = 'no');
        JiraSFDetails.add(jsDetail5);
        insert JiraSFDetails;
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Admin.privatekey = 'AoGBALRiMLAh9iimur8VA7qVvdqxevEuUkW4K+2KdMXmnQbG9Aa7k7eBjK1S+0LYmVjPKlJGNXHDGuy5Fw/d7rjVJ0BLB+ubPK8iA/Tw3hLQgXMRRGRXXCn8ikfuQfjUS1uZSatdLB81mydBETlJhI6GH4twrbDJCR2Bwy/XWXgqgGRzAgMBAAECgYBYWVtleUzavkbrPjy0T5FMou8HX9u2AC2ry8vD/l7cqedtwMPp9k7TubgNFo+NGvKsl2ynyprOZR1xjQ7WgrgVB+mmuScOM/5HVceFuGRDhYTCObE+y1kxRloNYXnx3ei1zbeYLPCHdhxRYW7T0qcynNmwrn05/KO2RLjgQNalsQJBANeA3Q4Nugqy4QBUCEC09SqylT2K9FrrItqL2QKc9v0ZzO2uwllCbg0dwpVuYPYXYvikNHHg+aCWF+VXsb9rpPsCQQDWR9TT4ORdzoj+NccnqkMsDmzt0EfNaAOwHOmVJ2RVBspPcxt5iN4HI7HNeG6U5YsFBb+/GZbgfBT3kpNGWPTpAkBI+gFhjfJvRw38n3g/+UeAkwMI2TJQS4n8+hid0uus3/zOjDySH3XHCUnocn1xOJAyZODBo47E+67R4jV1/gzbAkEAklJaspRPXP877NssM5nAZMU0/O/NGCZ+3jPgDUno6WbJn5cqm8MqWhW1xGkImgRk+fkDBquiq4gPiT898jusgQJAd5Zrr6Q8AO/0isr/3aa6O6NLQxISLKcPDk2NOccAfS/xOtfOz4sJYM3+Bs4Io9+dZGSDCA54Lw03eHTNQghS0A==';   
        
       // AdminSettingController.fetchJiraUserList('grazitti');
        //Admin.addjirasffield();
        AdminSettingController.checkloginsuccess();
        //Admin.fillsfJiraFieldsWrapper();
        //Admin.fetchProjectData();
        Admin.RefreshRequestToken();
        Admin.checkUrlChange();
        
        
        Test.stopTest();
        System.assertEquals(Admin.showmodal,false);
    }
    @istest
    public static void testScenerio1s(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        //Admin.privatekey = '2KdMXmnQbG9Aa7k7eBjK1S+0LYmVjPKlJGNXHDGuy5Fw/d7rjVJ0BLB+ubPK8iA/Tw3hLQgXMRRGRXXCn8ikfuQfjUS1uZSatdLB81mydBETlJhI6GH4twrbDJCR2Bwy/XWXgqgGRzAgMBAAECgYBYWVtleUzavkbrPjy0T5FMou8HX9u2AC2ry8vD/l7cqedtwMPp9k7TubgNFo+NGvKsl2ynyprOZR1xjQ7WgrgVB+mmuScOM/5HVceFuGRDhYTCObE+y1kxRloNYXnx3ei1zbeYLPCHdhxRYW7T0qcynNmwrn05/KO2RLjgQNalsQJBANeA3Q4Nugqy4QBUCEC09SqylT2K9FrrItqL2QKc9v0ZzO2uwllCbg0dwpVuYPYXYvikNHHg+aCWF+VXsb9rpPsCQQDWR9TT4ORdzoj+NccnqkMsDmzt0EfNaAOwHOmVJ2RVBspPcxt5iN4HI7HNeG6U5YsFBb+/GZbgfBT3kpNGWPTpAkBI+gFhjfJvRw38n3g/+UeAkwMI2TJQS4n8+hid0uus3/zOjDySH3XHCUnocn1xOJAyZODBo47E+67R4jV1/gzbAkEAklJaspRPXP877NssM5nAZMU0/O/NGCZ+3jPgDUno6WbJn5cqm8MqWhW1xGkImgRk+fkDBquiq4gPiT898jusgQJAd5Zrr6Q8AO/0isr/3aa6O6NLQxISLKcPDk2NOccAfS/xOtfOz4sJYM3+Bs4Io9+dZGSDCA54Lw03eHTNQghS0A==';   
        
       // AdminSettingController.fetchJiraUserList('grazitti');
        //Admin.addjirasffield();
        AdminSettingController.checkloginsuccess();
        //Admin.fillsfJiraFieldsWrapper();
        //Admin.fetchProjectData();
        Admin.RefreshRequestToken();
        Admin.checkUrlChange();
        
        
        Test.stopTest();
        System.assertEquals(Admin.showmodal,false);
    }
    
    @isTest 
    public static void testScenerio2s(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Delete ji;
        Jira_login__c newjira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        Admin.adminSetting=newjira;
        Admin.privatekey = '2KdMXmnQbG9Aa7k7eBjK1S+0LYmVjPKlJGNXHDGuy5Fw/d7rjVJ0BLB+ubPK8iA/Tw3hLQgXMRRGRXXCn8ikfuQfjUS1uZSatdLB81mydBETlJhI6GH4twrbDJCR2Bwy/XWXgqgGRzAgMBAAECgYBYWVtleUzavkbrPjy0T5FMou8HX9u2AC2ry8vD/l7cqedtwMPp9k7TubgNFo+NGvKsl2ynyprOZR1xjQ7WgrgVB+mmuScOM/5HVceFuGRDhYTCObE+y1kxRloNYXnx3ei1zbeYLPCHdhxRYW7T0qcynNmwrn05/KO2RLjgQNalsQJBANeA3Q4Nugqy4QBUCEC09SqylT2K9FrrItqL2QKc9v0ZzO2uwllCbg0dwpVuYPYXYvikNHHg+aCWF+VXsb9rpPsCQQDWR9TT4ORdzoj+NccnqkMsDmzt0EfNaAOwHOmVJ2RVBspPcxt5iN4HI7HNeG6U5YsFBb+/GZbgfBT3kpNGWPTpAkBI+gFhjfJvRw38n3g/+UeAkwMI2TJQS4n8+hid0uus3/zOjDySH3XHCUnocn1xOJAyZODBo47E+67R4jV1/gzbAkEAklJaspRPXP877NssM5nAZMU0/O/NGCZ+3jPgDUno6WbJn5cqm8MqWhW1xGkImgRk+fkDBquiq4gPiT898jusgQJAd5Zrr6Q8AO/0isr/3aa6O6NLQxISLKcPDk2NOccAfS/xOtfOz4sJYM3+Bs4Io9+dZGSDCA54Lw03eHTNQghS0A==';   
        Admin.save();
        Admin.RefreshRequestToken();
        Admin.checkUrlChange(); 
        Jira_login__c newjira1= Testdata.createjirasetting('display',true, 'checktest.com', 'JIRA', 'password', 'license', true, 'username', false);
        Admin.adminSetting=newjira1;
        Admin.checkUrlChange_OnOK();
        Test.stopTest();
        Jira_login__c JiLs =[Select id, Password__c from Jira_login__c Limit 1];
        Boolean PasswordEncrypt=('password'!=JiLs.Password__c?true:false);
        System.assertEquals(PasswordEncrypt,true);
    }
    @istest
    public static void testScenerio3s(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=false;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c newjira= Testdata.createjirasetting('display',true, 'checktest.com', 'JIRA', 'password', 'license', true, 'username', false);
        Admin.adminSetting=newjira;      
        Admin.privatekey = 'AoGBALRiMLAh9iimur8VA7qVvdqxevEuUkW4K+2KdMXmnQbG9Aa7k7eBjK1S+0LYmVjPKlJGNXHDGuy5Fw/d7rjVJ0BLB+ubPK8iA/Tw3hLQgXMRRGRXXCn8ikfuQfjUS1uZSatdLB81mydBETlJhI6GH4twrbDJCR2Bwy/XWXgqgGRzAgMBAAECgYBYWVtleUzavkbrPjy0T5FMou8HX9u2AC2ry8vD/l7cqedtwMPp9k7TubgNFo+NGvKsl2ynyprOZR1xjQ7WgrgVB+mmuScOM/5HVceFuGRDhYTCObE+y1kxRloNYXnx3ei1zbeYLPCHdhxRYW7T0qcynNmwrn05/KO2RLjgQNalsQJBANeA3Q4Nugqy4QBUCEC09SqylT2K9FrrItqL2QKc9v0ZzO2uwllCbg0dwpVuYPYXYvikNHHg+aCWF+VXsb9rpPsCQQDWR9TT4ORdzoj+NccnqkMsDmzt0EfNaAOwHOmVJ2RVBspPcxt5iN4HI7HNeG6U5YsFBb+/GZbgfBT3kpNGWPTpAkBI+gFhjfJvRw38n3g/+UeAkwMI2TJQS4n8+hid0uus3/zOjDySH3XHCUnocn1xOJAyZODBo47E+67R4jV1/gzbAkEAklJaspRPXP877NssM5nAZMU0/O/NGCZ+3jPgDUno6WbJn5cqm8MqWhW1xGkImgRk+fkDBquiq4gPiT898jusgQJAd5Zrr6Q8AO/0isr/3aa6O6NLQxISLKcPDk2NOccAfS/xOtfOz4sJYM3+Bs4Io9+dZGSDCA54Lw03eHTNQghS0A==';   
        
      //  AdminSettingController.fetchJiraUserList('grazitti');
        //Admin.addjirasffield();
        AdminSettingController.checkloginsuccess();
        //Admin.fillsfJiraFieldsWrapper();
        //Admin.fetchProjectData();
        Admin.RefreshRequestToken();
        Admin.checkUrlChange();
        
        
        Test.stopTest();
        System.assertEquals(Admin.showmodal,true);
    }
    
    @isTest 
    public static void testScenerio0a(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Admin.privatekey = 'AoGBALRiMLAh9iimur8VA7qVvdqxevEuUkW4K+2KdMXmnQbG9Aa7k7eBjK1S+0LYmVjPKlJGNXHDGuy5Fw/d7rjVJ0BLB+ubPK8iA/Tw3hLQgXMRRGRXXCn8ikfuQfjUS1uZSatdLB81mydBETlJhI6GH4twrbDJCR2Bwy/XWXgqgGRzAgMBAAECgYBYWVtleUzavkbrPjy0T5FMou8HX9u2AC2ry8vD/l7cqedtwMPp9k7TubgNFo+NGvKsl2ynyprOZR1xjQ7WgrgVB+mmuScOM/5HVceFuGRDhYTCObE+y1kxRloNYXnx3ei1zbeYLPCHdhxRYW7T0qcynNmwrn05/KO2RLjgQNalsQJBANeA3Q4Nugqy4QBUCEC09SqylT2K9FrrItqL2QKc9v0ZzO2uwllCbg0dwpVuYPYXYvikNHHg+aCWF+VXsb9rpPsCQQDWR9TT4ORdzoj+NccnqkMsDmzt0EfNaAOwHOmVJ2RVBspPcxt5iN4HI7HNeG6U5YsFBb+/GZbgfBT3kpNGWPTpAkBI+gFhjfJvRw38n3g/+UeAkwMI2TJQS4n8+hid0uus3/zOjDySH3XHCUnocn1xOJAyZODBo47E+67R4jV1/gzbAkEAklJaspRPXP877NssM5nAZMU0/O/NGCZ+3jPgDUno6WbJn5cqm8MqWhW1xGkImgRk+fkDBquiq4gPiT898jusgQJAd5Zrr6Q8AO/0isr/3aa6O6NLQxISLKcPDk2NOccAfS/xOtfOz4sJYM3+Bs4Io9+dZGSDCA54Lw03eHTNQghS0A==';   
        
     //   AdminSettingController.fetchJiraUserList('grazitti');
        //Admin.addjirasffield();
        AdminSettingController.checkloginsuccess();
        //Admin.fillsfJiraFieldsWrapper();
        //Admin.fetchProjectData();
        Admin.checkUrlChange();
        
        
        Test.stopTest();
        System.assertEquals(Admin.showmodal,false);
    }
    @isTest 
    public static void testScenerio0aa(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Admin.privatekey = 'AoGBALRiMLAh9iimur8VA7qVvdqxevEuUkW4K+2KdMXmnQbG9Aa7k7eBjK1S+0LYmVjPKlJGNXHDGuy5Fw/d7rjVJ0BLB+ubPK8iA/Tw3hLQgXMRRGRXXCn8ikfuQfjUS1uZSatdLB81mydBETlJhI6GH4twrbDJCR2Bwy/XWXgqgGRzAgMBAAECgYBYWVtleUzavkbrPjy0T5FMou8HX9u2AC2ry8vD/l7cqedtwMPp9k7TubgNFo+NGvKsl2ynyprOZR1xjQ7WgrgVB+mmuScOM/5HVceFuGRDhYTCObE+y1kxRloNYXnx3ei1zbeYLPCHdhxRYW7T0qcynNmwrn05/KO2RLjgQNalsQJBANeA3Q4Nugqy4QBUCEC09SqylT2K9FrrItqL2QKc9v0ZzO2uwllCbg0dwpVuYPYXYvikNHHg+aCWF+VXsb9rpPsCQQDWR9TT4ORdzoj+NccnqkMsDmzt0EfNaAOwHOmVJ2RVBspPcxt5iN4HI7HNeG6U5YsFBb+/GZbgfBT3kpNGWPTpAkBI+gFhjfJvRw38n3g/+UeAkwMI2TJQS4n8+hid0uus3/zOjDySH3XHCUnocn1xOJAyZODBo47E+67R4jV1/gzbAkEAklJaspRPXP877NssM5nAZMU0/O/NGCZ+3jPgDUno6WbJn5cqm8MqWhW1xGkImgRk+fkDBquiq4gPiT898jusgQJAd5Zrr6Q8AO/0isr/3aa6O6NLQxISLKcPDk2NOccAfS/xOtfOz4sJYM3+Bs4Io9+dZGSDCA54Lw03eHTNQghS0A==';   
        //string consumerkey = 'JiraDemoRubrik';
        Admin.checkUrlChange();
        
       // AdminSettingController.fetchJiraUserList('grazitti');
        Admin.RefreshRequestToken();
        AdminSettingController.checkloginsuccess();
        //Admin.fillsfJiraFieldsWrapper();
        //Admin.fetchProjectData();
        //Admin.checkUrlChange();
        Test.stopTest();
        Jira_login__c JiLs =[Select id, LoginSuccess__c from Jira_login__c Limit 1];
        System.assertEquals(JiLs.LoginSuccess__c,true);
    }
    
    @isTest 
    public static void testScenerio0(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        ji.Password__c='newPassword';
        //Jira_login__c jiclone=ji;
        ji.End_Point__c='jira.com';
        
        ji.Basic_Authentication__c=false;
        //upsert ji;
        Admin.checkUrlChange();
        
        AdminSettingController.checkloginsuccess();
        //Admin.fillsfJiraFieldsWrapper();
        //Admin.fetchProjectData();
        
        
        Admin.checkUrlChange_OnOK();
        Test.stopTest();
        System.assertEquals(Admin.showmodal,false);
    }
    @isTest 
    public static void testScenerio1(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Delete ji;
        Jira_login__c newjira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        Admin.adminSetting=newjira;
        Admin.RefreshRequestToken();
        Admin.checkUrlChange(); 
        Test.stopTest();
        Jira_login__c JiLs =[Select id, Password__c from Jira_login__c Limit 1];
        Boolean PasswordEncrypt=('password'!=JiLs.Password__c?true:false);
        System.assertEquals(PasswordEncrypt,true);
    }
    @isTest 
    public static void testScenerio2(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        
        Jira_login__c newjira= Testdata.createjirasetting('display',true, 'test12.com', 'JIRA', 'password', 'license', true, 'username', false);
        Admin.adminSetting=newjira;
        Admin.checkUrlChange();
        Test.stopTest();
        System.assertEquals(newjira.password__c!='password',true);
    }
    @isTest 
    public static void testScenerio3(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        Jira_login__c newjira= Testdata.createjirasetting('display',true, 'test12.com', 'JIRA', 'password', 'license', true, 'username', false);
        Admin.adminSetting=newjira;
        Admin.save();
        Admin.checkUrlChange_OnOK();
        Admin.cancelSettings();
        
        Test.stopTest();
        
        
        List<ContentDocument> clist = [select id from ContentDocument where Title like '%_NotAllowedJson%'];
        System.assertEquals(clist.size(),0);
    }
    @isTest 
    public static void testScenerio4(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_Project__c pm11= Testdata.createjiraProject('10011', 'Dev', 'Dev');
        Testdata.CreateJSon(pm11.id,pm11.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        //Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        
        Jira_Project__c pm1 =new Jira_Project__c();
        pm1.ProjectId__c='10001';
        pm1.Name='TP';
        pm1.ProjectKey__c='TP';
        pm1.DefaultIssueType__c='Task';
        ProjectWrapper pr = new ProjectWrapper();
        pr.project=pm1;
        pr.selected=true;
        ProjectWrapper pr1 = new ProjectWrapper();
        pr1.project=pm;
        pr1.selected=false;
        list<ProjectWrapper> prowrapperlist= new list<ProjectWrapper>();
        prowrapperlist.add(pr1);
        prowrapperlist.add(pr);
        //Admin.projectsList=prowrapperlist;
        //Admin.saveProjects();
        Jira_Project__c PL=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c where ProjectId__c='10000' ];
        Testdata.CreateJSon(PL.id, PL.ProjectKey__c);
        Test.stopTest();
        System.assertEquals(PL.Name,'DP');
    }
    
    
    
    @isTest 
    public static void testScenerio5(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        //Testdata.createjiraProject('10001', 'TP', 'TP');
        PageReference pg=Page.AdminSetting;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        ApexPages.currentPage().getParameters().put('index','req_1_DP');
        // ApexPages.currentPage().getParameters().put('delObj','Case');
        // 
        
        
        map<string,ProjectAndFieldWrapper> prowraper= new   map<string,ProjectAndFieldWrapper>();
        //prowraper=Admin.ProjectFieldmaps;
        
        ProjectAndFieldWrapper prowrap= prowraper.get('DP');
        Jira_ProjectFieldsMapping__c jpmap=Testdata.createjirafieldmapp(prolist.id, true, 'Sprint', 'subject', 'Sprint','customfield_10010', false, true, 'string', false);
        ProjectFieldIdSet pfi= new ProjectFieldIdSet(jpmap,new map<id,id>());
        
        //prowrap.OpJiraFieldList.add(pfi);
        prowraper.put('DP',prowrap);
        //Admin.ProjectFieldmaps=prowraper;
        
        
        //Admin.selectproject='DP';
        //Admin.fetchProjectData();
        //Admin.fetchfields();
        
        //  Admin.addJiraSfField();
        // Admin.addJiraSfFieldwom();
        //Admin.saveFields();
        
        Admin.cancel();
        //Admin.deleteMappingForSelectedObj();
        AdminSettingController.ErrorMessage('Error');
        
        
        Test.stopTest();
        
        System.assertEquals(Admin.showmodal,false);
    }
    @isTest 
    public static void testScenerio6(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        Jira_ProjectFieldsMapping__c proMap11 = Testdata.createjirafieldmapp(pm.id,false,'customfield_10601','subject','customfield_10601', 'customfield_10206' ,true, true ,'cascadingselect',false);
        proMap11.RelatedProjectIdSet__c = pm.Id;
        proMap11.jira_project__c=pm.Id;
        proMap11.IssueTypedata__c='All';
        proMap11.Salesforce_Object__c='Case';
        proMap11.Section__c =Section.id;
        jirafieldmap.add(proMap11);
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=false;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        //Testdata.createjiraProject('10001', 'TP', 'TP');
        PageReference pg=Page.AdminSetting;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        ApexPages.currentPage().getParameters().put('index','op_1_DP');
        //Admin.selectproject='DP';
        //Admin.fetchfields();
        
        Test.stopTest();
        System.assertEquals(Admin.ObjectLimit,false);
    }
    
    @isTest 
    public static void testScenerio7(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10206' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMap11 = Testdata.createjirafieldmapp(pm.id,false,'customfield_10601','subject','customfield_10601', 'customfield_10206' ,true, true ,'cascadingselect',false);
        proMap11.RelatedProjectIdSet__c = pm.Id;
        proMap11.jira_project__c=pm.Id;
        proMap11.IssueTypedata__c='All';
        proMap11.Salesforce_Object__c='Case';
        proMap11.Section__c =Section.id;
        jirafieldmap.add(proMap11);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=false;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        //Testdata.createjiraProject('10001', 'TP', 'TP');
        PageReference pg=Page.AdminSetting;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        ApexPages.currentPage().getParameters().put('index','op_1_DP');
        ApexPages.currentPage().getParameters().put('indexop','op_1_DP');
        
        //Admin.selectproject='DP';
        //Admin.fetchfields();
        
        map<string,ProjectAndFieldWrapper> prowraper= new   map<string,ProjectAndFieldWrapper>();
        //prowraper=Admin.ProjectFieldmaps;
        ProjectAndFieldWrapper prowrap= prowraper.get('DP');
        
        //Jira_ProjectFieldsMapping__c jpmap= prowrap.OpJiraFieldList[1].Field;
        //map<id,id> relatedlist= prowrap.OpJiraFieldList[1].RelatedFields;
        
        //jpmap.Case_Field_Name__c='status';
        
        //prowrap.OpJiraFieldList[1].Field=jpmap;
        prowraper.put('DP',prowrap);
        
        //Admin.ProjectFieldmaps=prowraper;
        //Admin.saveFields();
        //admin.removejirasffield();
        
        Test.stopTest();
        System.assertEquals(Admin.showmodal,false);
    }
    
    @isTest 
    public static void testScenerio9(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        //Testdata.createjiraProject('10001', 'TP', 'TP');
        PageReference pg=Page.AdminSetting;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        ApexPages.currentPage().getParameters().put('index','op_1_DP');
        //Admin.selectproject='DP';
        //Admin.fetchfields();
        //Admin.addJiraSfField();
        //Admin.addJiraSfFieldwom();
        map<string,ProjectAndFieldWrapper> prowraper= new   map<string,ProjectAndFieldWrapper>();
        //prowraper=Admin.ProjectFieldmaps;
        
        ProjectAndFieldWrapper prowrap= prowraper.get('DP');
        Jira_ProjectFieldsMapping__c jpmap=Testdata.createjirafieldmapp(prolist.id, true, 'Sprint', 'subject', 'Sprint','customfield_10010', false, true, 'string', false);
        ProjectFieldIdSet pfi= new ProjectFieldIdSet(jpmap,new map<id,id>());
        
        //prowrap.OpJiraFieldList.add(pfi);
        prowraper.put('DP',prowrap);
        //Admin.ProjectFieldmaps=prowraper;
        
        //Admin.objectToBeDeleted='case';
        //Admin.saveFields();
        //Admin.DefaultSectionDataApex();
        //Admin.DefaultSave();
        Admin.ValidationCompRecall();
        //Admin.deleteobjectsMapping();
        //Admin.AsyncJobDone();
        //Admin.refreshFieldSettings();
        Test.stopTest();
        List<jira_projectfieldsmapping__c> jpmlist = [SELECT Id,salesforce_object__c from jira_projectfieldsmapping__c where salesforce_object__c ='case' ];
        
        System.assertEquals(jpmlist.size(),3);
    }    
    
    @isTest 
    public static void testScenerio10(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        //Testdata.createjiraProject('10001', 'TP', 'TP');
        PageReference pg=Page.AdminSetting;
        Test.setCurrentPage(pg);
        //Admin.refreshFieldSettings();
        Test.stopTest();
        System.assertEquals(prolist.name,'DP');
    }
    @isTest 
    public static void testScenerio11(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        
        
        insert jirafieldmap;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        AdminSettingController Admin = new AdminSettingController();
        Jira_login__c ji=[select id,password__c from Jira_login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        //Testdata.createjiraProject('10001', 'TP', 'TP');
        PageReference pg=Page.AdminSetting;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('projectkey','DP');
        ApexPages.currentPage().getParameters().put('index','op_1_DP');
        //Admin.selectproject='DP';
        //Admin.fetchfields();
        //Admin.addJiraSfField();
        //Admin.addJiraSfFieldwom();
        map<string,ProjectAndFieldWrapper> prowraper= new   map<string,ProjectAndFieldWrapper>();
        //prowraper=Admin.ProjectFieldmaps;
        ApexPages.currentPage().getParameters().put('indexop','op_1_DP');
        
        TEst.stopTest();
        
        List<Jira_Project__c> JLIST =[select id from Jira_Project__c Limit 1000] ;
        System.assertEquals(JLIST.size(),1);
    } 
    @isTest 
    public static void testScenerio12(){
        delete [Select id from Jira_Project__c];
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        jira.Basic_Authentication__c=false;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1 = new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c = 'true');
        insert jsDetail1;
        
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        //proMap.ReqInIssueTypeData__c='Task';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        Jira_ProjectFieldsMapping__c projectMapvv13 = Testdata.createjirafieldmapp(pm.id,false,'Key',null,'key', 'Key' ,true, false,'key' ,false);
        projectMapvv13.jira_project__c=pm.id;
        projectMapvv13.RelatedProjectIdSet__c = pm.id;
        projectMapvv13.IssueTypedata__c='All';
        projectMapvv13.Salesforce_Object__c='Case';
        projectMapvv13.Section__c =Section.id;
        jirafieldmap.add(projectMapvv13);
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'Status',null,'status', 'Status' ,true, false,'status' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.Salesforce_Object__c='Case';
        projectMapvv11.Section__c =Section.id;
        jirafieldmap.add(projectMapvv11);
        Jira_ProjectFieldsMapping__c projectMapvv14 = Testdata.createjirafieldmapp(pm.id,false,'Link',null,'link', 'Link' ,true, false,'link' ,false);
        projectMapvv14.jira_project__c=pm.id;
        projectMapvv14.RelatedProjectIdSet__c = pm.id;
        projectMapvv14.IssueTypedata__c='All';
        projectMapvv14.Salesforce_Object__c='Case';
        projectMapvv14.Section__c =Section.id;
        jirafieldmap.add(projectMapvv14);
        Jira_ProjectFieldsMapping__c projectMapvv15 = Testdata.createjirafieldmapp(pm.id,false,'Resolution Date',null,'resolutiondate', 'Resolution Date' ,true, false,'resolutiondate' ,false);
        projectMapvv15.jira_project__c=pm.id;
        projectMapvv15.RelatedProjectIdSet__c = pm.id;
        projectMapvv15.IssueTypedata__c='All';
        projectMapvv15.Salesforce_Object__c='Case';
        projectMapvv15.Section__c =Section.id;
        jirafieldmap.add(projectMapvv15);
        Jira_ProjectFieldsMapping__c projectMapvv16 = Testdata.createjirafieldmapp(pm.id,false,'Resolution',null,'resolution', 'Resolution' ,true, false,'resolution' ,false);
        projectMapvv16.jira_project__c=pm.id;
        projectMapvv16.RelatedProjectIdSet__c = pm.id;
        projectMapvv16.IssueTypedata__c='All';
        projectMapvv16.Salesforce_Object__c='Case';
        projectMapvv16.Section__c =Section.id;
        Jira_ProjectFieldsMapping__c projectMapvv17 = Testdata.createjirafieldmapp(pm.id,false,'Priority',null,'priority', 'Priority' ,true, false,'priority' ,false);
        projectMapvv17.jira_project__c=pm.id;
        projectMapvv17.RelatedProjectIdSet__c = pm.id;
        projectMapvv17.IssueTypedata__c='All';
        projectMapvv17.Salesforce_Object__c='Case';
        projectMapvv17.Section__c =Section.id;
        jirafieldmap.add(projectMapvv17);
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        projectMapv9.Section__c =Section.id;
        //projectMapv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv9);
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        insert jirafieldmap;   
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        RefreshFieldConfiguration RefFCong= new RefreshFieldConfiguration();
        RefFCong.FetchProjects();
        
        
        Test.stopTest();
        List<Jira_Project__c> JLIST =[select id from Jira_Project__c Limit 1000] ;
        System.assertEquals(JLIST.size(),1);
    }
     
}
({
    searchreqtojira : function(component, event, helper) {
         component.set("v.showcomponents",true);
        
        helper.showSpinner(component);
        helper.mainfunc(component);
    },
    
    keyCheck:function(component, event, helper) {
        if(event.which === 13){
            helper.showSpinner(component);
            helper.mainfunc(component);
        }
    },
    
    addComponent: function(component, event,helper) {
        var proName=component.get("v.projectName");
        var existingComponents=component.get("v.Component");
        
        var componentSelected=event.getSource().get("v.value");  
        var componentName=event.getSource().get("v.text");
        var componentTypeCheck=componentName.split('_');
        if(proName ='undefined'){
            document.getElementById(componentTypeCheck[0]+"_radio").checked  =true ;
            component.set("v.projectName",componentTypeCheck[0]);
        }
        var newIssueTypeList=[];
        if(componentSelected){
            existingComponents.push(componentName);
            component.set("v.Component",existingComponents);
        }else{
            for(var i =0;i<existingComponents.length;i++){
                if(existingComponents[i]!=componentName){
                    newIssueTypeList.push(existingComponents[i]);
                }
            }
            component.set("v.Component",newIssueTypeList);
        }
        
        
        var existingComp=component.get("v.Component");
        console.log('existingComp__'+existingComp);
        
        /*var checkboxstatus = component.find("checkbox");
        if(checkboxstatus.length!=undefined && checkboxstatus.length>0){
            for(var i=0;i<checkboxstatus.length;i++){
                if(datalist.has(checkboxstatus[i].get("v.name"))){
                    if(datalist.get(data[i].get("v.name")).length>0){
                        data[i].set("v.value",true);
                    }else{
                        data[i].set("v.value",false); 
                    }
                }
            }
        }*/
    },
    
    addIssueType: function(component, event,helper) {
        var proName=component.get("v.projectName");
        
        var existingissueTypes=component.get("v.IssueType");
        var selectedIssueType=event.getSource().get("v.value");
        var issueTypeName=event.getSource().get("v.text");
        var issuetypeCheck=issueTypeName.split('_');
        
        if(proName ='undefined'){
            document.getElementById(issuetypeCheck[0]+"_radio").checked  =true ;
            component.set("v.projectName",issuetypeCheck[0]);
        }
        
        var newIssueTypeList=[];
        if(selectedIssueType){
            existingissueTypes.push(issueTypeName);
            component.set("v.IssueType",existingissueTypes);
        }else{
            
            for(var i =0;i<existingissueTypes.length;i++){
                if(existingissueTypes[i]!=issueTypeName){
                    newIssueTypeList.push(existingissueTypes[i]);
                }
            }
            component.set("v.IssueType",newIssueTypeList);
        }
        
        
        var existingissue=component.get("v.IssueType");
        console.log('existingissue__'+existingissue);
        
        /*var data = component.find("checkbox");
        if(data.length!=undefined && data.length>0){
            for(var i=0;i<data.length;i++){
                if(datalist1.has(data[i].get("v.name"))){
                    if(datalist1.get(data[i].get("v.name")).issueTypelist.length>0){
                        data[i].set("v.value",true);
                    }else{
                        data[i].set("v.value",false); 
                    }
                }
            }
        }*/
        
    }, 
    
    addProject: function(component, event,helper) {
        var lastprojectSelectedName=component.get("v.lastprojectSelected");
        if(lastprojectSelectedName!=undefined){
            
            var divid= lastprojectSelectedName+'_issuediv';
            var plusid= lastprojectSelectedName+'_plus';
            var minusid= lastprojectSelectedName+'_minus';
            var cmpid= lastprojectSelectedName+'_componentdiv';
            document.getElementById(plusid).classList.remove('hide');
            document.getElementById(minusid).classList.add('hide');
            document.getElementById(divid).classList.add('hide');
            document.getElementById(cmpid).classList.add('hide');    
            
            var projectName = event.target.value ;
            
            component.set("v.projectName",projectName);
            
            var defaultIssueType;
            var componentlist=[];
            var issueTypelist=[];
            var prjWrapper=component.get("v.prjctvalues");
            var count=0;
            for(var i=0;i<prjWrapper.length;i++){
                if(prjWrapper[i].label==lastprojectSelectedName){
                    var checkboxstatus = component.find("IssueTypecheckbox");
                    
                    if(checkboxstatus.length!=undefined && checkboxstatus.length>0){
                        for(var i=0;i<checkboxstatus.length;i++){
                            
                            var val=checkboxstatus[i].get("v.name");
                            val=val.split('_');
                            if(count>1 && lastprojectSelectedName!=val[0]){
                                break;
                            }
                            if(lastprojectSelectedName==val[0]){
                                count=1;
                                // if(val[1]==defaultIssueType){
                                count=count+1;
                                checkboxstatus[i].set("v.value",false);
                                //}
                            }
                        }
                    }
                }
            }
            
            for(var i=0;i<prjWrapper.length;i++){
                if(prjWrapper[i].label==lastprojectSelectedName){
                    var CompoenentcheckboxStatus = component.find("checkbox2");
                    
                    if(CompoenentcheckboxStatus!=undefined && CompoenentcheckboxStatus.length!=undefined && CompoenentcheckboxStatus.length>0){
                        count=0;
                        for(var i=0;i<CompoenentcheckboxStatus.length;i++){
                            
                            var val=CompoenentcheckboxStatus[i].get("v.name");
                            val=val.split('_');
                            if(count>1 && lastprojectSelectedName!=val[0]){
                                break;
                            }
                            if(lastprojectSelectedName==val[0]){
                                count=1;
                                count=count+1;
                                CompoenentcheckboxStatus[i].set("v.value",false);
                                
                            }
                        }
                    }
                }
            }
            
            if(projectName){
                for(var i=0;i<prjWrapper.length;i++){
                    if(projectName==prjWrapper[i].label){
                        issueTypelist.push(projectName+'_'+prjWrapper[i].defaultissuetype);
                        defaultIssueType=prjWrapper[i].defaultissuetype;
                    }
                }
                component.set("v.IssueType",issueTypelist);
                component.set("v.lastprojectSelected",projectName);
                var divid= projectName+'_issuediv';
                var plusid= projectName+'_plus';
                var minusid= projectName+'_minus';
                var compid=projectName+'_componentdiv';
                document.getElementById(plusid).classList.add('hide');
                document.getElementById(divid).classList.remove('hide');
                document.getElementById(minusid).classList.remove('hide');
                document.getElementById(compid).classList.remove('hide');
            }
            
        }else{
            var projectName =event.target.value ;
            
            component.set("v.projectName",projectName);
            
            var defaultIssueType;
            var componentlist=[];
            var issueTypelist=[];
            var prjWrapper=component.get("v.prjctvalues");
            
            if(projectName){
                
                for(var i=0;i<prjWrapper.length;i++){
                    if(projectName==prjWrapper[i].label){
                        issueTypelist.push(projectName+'_'+prjWrapper[i].defaultissuetype);
                        defaultIssueType=prjWrapper[i].defaultissuetype;
                    }
                }
                component.set("v.IssueType",issueTypelist);
                component.set("v.lastprojectSelected",projectName);
                var divid= projectName+'_issuediv';
                var plusid= projectName+'_plus';
                var minusid= projectName+'_minus';
                var compid=projectName+'_componentdiv';
                document.getElementById(plusid).classList.add('hide');
                document.getElementById(divid).classList.remove('hide');
                document.getElementById(minusid).classList.remove('hide');
                document.getElementById(compid).classList.remove('hide');
            }
            
        }
        
        var checkboxstatus = component.find("IssueTypecheckbox");
        if(checkboxstatus.length!=undefined && checkboxstatus.length>0){
            for(var i=0;i<checkboxstatus.length;i++){
                var val=checkboxstatus[i].get("v.name");
                val=val.split('_');
                if(projectName==val[0]){
                    if(val[1]==defaultIssueType){
                        checkboxstatus[i].set("v.value",true);
                    }
                }
            }
        }
    },
    
    fetchComponent:function(component,event,helper){
        component.set("v.showcomponents",true);
        var projectselected=event.getSource().get("v.value");
        console.log('sdcfv'+projectselected);
		//------------------
        var mainmap = component.get("v.prjctvaluesMap");
        mainmap[projectselected]['fetchedcomponent']=true;
        component.set("v.prjctvaluesMap",mainmap);
        var resultlist =[];
        for(var i in mainmap){ resultlist.push(mainmap[i])}
        component.set("v.prjctvalues",resultlist);
        var divid= mainmap[projectselected].label+'_component';
        document.getElementById(divid).classList.remove('hide');
        var divid= event.target.id;
        var plusid= divid.split('_')[0]+'_Cplus';
        var minusid= mainmap[projectselected].label+'_Cminus';
        document.getElementById(plusid).classList.add('hide');
        document.getElementById(minusid).classList.remove('hide');
        
        //------------------
        var action=component.get("c.fetchComponents");
        action.setParams({
            'projectKey':projectselected
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
             
                var result = response.getReturnValue(); 
              
                mainmap[projectselected]['component']=result;
                mainmap[projectselected]['fetchedcomponent']=false;
                component.set("v.prjctvaluesMap",mainmap);
                
                var resultlist =[];
                for(var i in mainmap){ resultlist.push(mainmap[i])}
                component.set("v.prjctvalues",resultlist);
                var divid= mainmap[projectselected].label+'_component';
                document.getElementById(divid).classList.remove('hide');
                var divid= event.target.id;
                var plusid= divid.split('_')[0]+'_Cplus';
                var minusid= mainmap[projectselected].label+'_Cminus';
                document.getElementById(plusid).classList.add('hide');
                document.getElementById(minusid).classList.remove('hide');
            }
        });
      $A.enqueueAction(action);
        
    } ,
    
    doInit : function(component, event, helper) {
        
        var recordIdparameter=component.get("v.pageReference").state.ws;
        if(recordIdparameter.includes('/')){
        var obj = /[a-zA-Z0-9]{18}/.exec(recordIdparameter);
        component.set("v.recordId",obj[0]);
        }else{
            component.set("v.recordId",recordIdparameter);
        }
        var action=component.get("c.fetchAllProjects");
        
            
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.showprojects",false);
                var resultlist =[];
                for(var i in result){ resultlist.push(result[i])}
                
                component.set("v.prjctvalues",resultlist);
                component.set("v.prjctvaluesMap",result);
                
            }
        });
        $A.enqueueAction(action);
    }, 
    
    showIssueSection: function (component, event, helper) {
        var data= component.get('v.prjctvalues');
        var tempdata=[];
        component.set('v.prjctvalues',tempdata);
        component.set('v.prjctvalues',data);
        
        var divid= event.target.id;
        setTimeout(function(){ 
            var minusid= divid.split('_')[0]+'_minus';
            var Issuediv= divid.split('_')[0]+'_issuediv';
            var cmpdiv= divid.split('_')[0]+'_componentdiv';
            document.getElementById(minusid).classList.remove('hide');
            document.getElementById(divid).classList.add('hide');
            document.getElementById(Issuediv).classList.remove('hide');
            document.getElementById(cmpdiv).classList.remove('hide'); 
        }, 500);
        
        
        
    },
    
    hideIssueSection: function (component, event, helper) {
        
        var divid= event.target.id;
        var plusid= divid.split('_')[0]+'_plus';
        var Issuediv= divid.split('_')[0]+'_issuediv';
        var cmpdiv= divid.split('_')[0]+'_componentdiv';
        document.getElementById(plusid).classList.remove('hide');
        document.getElementById(divid).classList.add('hide');
        document.getElementById(Issuediv).classList.add('hide');
        document.getElementById(cmpdiv).classList.add('hide');
    },
    
    hideComponentSection: function(component, event, helper){
        var divid= event.target.id;
        var plusid= divid.split('_')[0]+'_Cplus';
        var cmpdiv= divid.split('_')[0]+'_component';
        document.getElementById(divid).classList.add('hide');
        document.getElementById(cmpdiv).classList.add('hide');
        document.getElementById(plusid).classList.remove('hide');
    },
    
    showall: function (component, event, helper) {
        var projects=component.get("v.prjctvalues");
        for(var i=0;i<projects.length;i++){
            var divid=projects[i].label+'_minus';
            console.log(divid);
            var plusid= projects[i].label+'_plus';
            var Issuediv= projects[i].label+'_issuediv';
            document.getElementById(plusid).classList.add('hide');
            document.getElementById(divid).classList.remove('hide');
            document.getElementById(Issuediv).classList.remove('hide');
        }
    },
    
    Previous : function(component, event, helper) {
        var action=component.get("c.previousPage")
        
        action.setParams({
            'searchtext':component.get("v.searchtxt"),
            'componentList':JSON.stringify(component.get("v.Component")),
            'issueTypeList':JSON.stringify(component.get("v.IssueType")),
            'projectName':component.get("v.projectName"),
            'indexv': component.get("v.indexvalue")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                console.log('+@'+result);
                component.set("v.srchvalues", result.fieldWrapperList);
                console.log('result'+result.indexval);
                component.set("v.indexvalue",result.indexval);
                component.set("v.Likedisable",false);
                if(result.indexval==0){
                    component.set("v.prevdisable",true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    Next : function(component, event, helper) {
        var action=component.get("c.nextPage")
        
        action.setParams({ 
            'searchtext':component.get("v.searchtxt"),
            'componentList':JSON.stringify(component.get("v.Component")),
            'issueTypeList':JSON.stringify(component.get("v.IssueType")),
            'projectName':component.get("v.projectName"),
            'indexv': component.get("v.indexvalue")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                console.log('+@'+result);
                component.set("v.srchvalues", result.fieldWrapperList);
                console.log('result'+result.indexval);
                component.set("v.indexvalue",result.indexval);
                console.log('result'+result.totalpage);
                if(result.indexval==result.totalpage-1){
                    component.set("v.Likedisable",true);
                }
                component.set("v.prevdisable",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'Link':
                
                helper.linkJiraIssue(component, row.Key);
                break;
            case 'View Detail':
                
                helper.viewJiraIssue(component, row.Key);
                break;
        }
        
    },
    closeModel: function (component, event, helper) {
        component.set("v.isModalOpen", "false");                
        component.set("v.showError", '');    
        
    }
})
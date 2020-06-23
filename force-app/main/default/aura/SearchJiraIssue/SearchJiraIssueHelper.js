({
    mainfunc: function (component, event, helper) {
        var actions = [
            { label: 'View Detail', name: 'View Detail' },
            { label: 'Link', name: 'Link' }
        ]
        component.set('v.mycolumns', [
            {type: 'action', typeAttributes: { rowActions: actions } },
            {label: 'Key', fieldName: 'Key', type: 'text',sortable : true,initialWidth :120},
            {label: 'IssueType', fieldName: 'Issuetype', type: 'text',sortable : true,initialWidth :120},
            {label: 'Component', fieldName: 'components', type: 'text',sortable : true},
            {label: 'Status', fieldName: 'Status', type: 'text',sortable : true,initialWidth :120},
            {label: 'Summary', fieldName: 'Summary', type: 'text',sortable : true},
            {label: 'Description', fieldName: 'Description', type: 'text',sortable : true}
        ]);
        
        
        
        var action=component.get("c.SendSearchReqToJIRA")
        if(component.get("v.searchtxt")!=null){
            component.set("v.showsearch",false);
        }
        action.setParams({
            'searchtext':component.get("v.searchtxt"),
            'componentList':JSON.stringify(component.get("v.Component")),
            'issueTypeList':JSON.stringify(component.get("v.IssueType")),
            'projectName':component.get("v.projectName")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                this.hideSpinner(component,event);
                var result = response.getReturnValue(); 
                component.set("v.srchvalues", result.fieldWrapperList);
                if( result.fieldWrapperList.length==0){
                    component.set("v.NoRecordfound",'No Records Found');
                }else{
                    
                    component.set("v.NoRecordfound",'');
                }
                
                if(result.totalpage==1 && result.indexval==undefined){
                    component.set("v.Likedisable",true);
                    component.set("v.prevdisable",true);
                }
                else if(result.indexval==undefined){
                    component.set("v.prevdisable",true);
                    component.set("v.Likedisable",false);
                }
            }else if (state === "ERROR") {
                var errorMsg = action.getError()[0].message;
                component.set("v.isModalOpen","true");                
                component.set("v.showError", errorMsg);  
                this.hideSpinner(component,event);
            }
        });
        $A.enqueueAction(action);
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.srchvalues");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.srchvalues", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    linkJiraIssue:function(component, event, helper){
        var rows = event;
        var caseID=component.get("v.recordId");
        var action=component.get("c.linkcasewithjirakey")
        
        action.setParams({
            'caseID':component.get("v.recordId"),
            'row':rows  
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var appEvent = $A.get("e.c:RefreshJiraRelatedListEvent");
                appEvent.setParams({
                    "refreshjiralist" : true });
                appEvent.fire();
                var rows = event;
                var caseID=component.get("v.recordId");
                var workspaceAPI = component.find("workspace");
                var isinconsole=false;
                workspaceAPI
                .isConsoleNavigation()
                .then(function(isConsole) {
                    if (isConsole) {
                     
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    }else{
                       
                        window.open('/'+caseID,"_self");
                    }
                });
                
                
            }
        });
        $A.enqueueAction(action);
    },
    
    viewJiraIssue:function(component, event, helper){
       
        var rows = event;
        var caseID=component.get("v.recordId");
        var workspaceAPI = component.find("workspace");
        var isinconsole=false;
        workspaceAPI
        .isConsoleNavigation()
        .then(function(isConsole) {
            if (isConsole) {
               
                isinconsole=true;
                workspaceAPI.openTab({
                    url: '/lightning/r/case/'+caseID+'/view',
                    focus: true
                }).then(function(response) {
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: '/apex/Grz_Sf__ViewSearchJira?id='+rows+'&type=search&Objectid='+caseID,
                        focus: true
                    });
                }) 
            }else
            {
                window.open('/apex/Grz_Sf__ViewSearchJira?id='+rows+'&type=search&Objectid='+caseID);
            }
        })
        .catch(function(error) {
            console.log(error);
        }); 
    }
})
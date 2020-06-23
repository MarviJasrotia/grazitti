
$(document).ready(function() {
            console.log('ready ',document.getElementById('ep'));
           document.getElementById('ep').firstChild.nextSibling.firstChild.nextSibling.style.display='none';
});

function showEditMode(compid,btnid,editaddid) {
            console.log(btnid+':viewjira');
            document.getElementById(compid).classList.add('abc');
            document.getElementById(btnid).classList.add('abc');
             document.getElementById(editaddid).classList.remove('abc');
        }

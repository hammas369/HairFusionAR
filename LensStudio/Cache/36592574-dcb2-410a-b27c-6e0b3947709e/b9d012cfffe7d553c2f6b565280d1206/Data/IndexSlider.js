// -----JS CODE-----
//@input SceneObject[] items;

script.setItem = function(index){
    for(var i = 0;i < script.items.length; i++){
        if(i == index){
            script.items[i].enabled = true;
        }
        else{
            script.items[i].enabled = false;
        }
    }
}
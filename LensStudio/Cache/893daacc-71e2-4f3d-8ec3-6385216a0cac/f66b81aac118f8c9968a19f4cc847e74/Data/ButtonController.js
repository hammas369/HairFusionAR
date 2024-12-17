//@input SceneObject[] carousals
//@input SceneObject baldML;
//@input SceneObject headBindingHair;
//@input SceneObject headBindingHats;
//@input SceneObject headBindingGlasses;
script.api.ButtonClicked = function (i) {
    
    print(i);
    
    for(let i=0;i<script.carousals.length;i++)
        {
             script.carousals[i].enabled = false;
        }
 
    script.carousals[i].enabled = true;
    
    if(i==0 || i==1)
    {
        script.baldML.enabled = true;
        script.headBindingHair.enabled = true;
        script.headBindingHats.enabled = false;
        script.headBindingGlasses.enabled = false;

        
    }
  
    if(i==2)
    {
        script.baldML.enabled = false;
        script.headBindingHair.enabled = false;
        script.headBindingHats.enabled = true;
        script.headBindingGlasses.enabled = false;
    }
    
     if(i==3)
    {
        script.baldML.enabled = false;
        script.headBindingHair.enabled = false;
        script.headBindingHats.enabled = false;
        script.headBindingGlasses.enabled = true;
    }
    
}
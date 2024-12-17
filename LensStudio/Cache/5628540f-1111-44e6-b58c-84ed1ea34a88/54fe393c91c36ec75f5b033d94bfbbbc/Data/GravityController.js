// GravityController.js
// Version: 0.0.1
// Event: On Awake
// Description: Add gravity based on dt to the hair element

// @input SceneObject hairComponents
// @input float gravityForce = 1.0

var dt = script.getSceneObject().createComponent("Component.DeviceTracking");
dt.requestDeviceTrackingMode(DeviceTrackingMode.Rotation);
dt.rotationOptions.invertRotation = false;

if (!script.hairComponents) {
    print("HairFallbacksettings: ERROR, Please link Hair Elements object!");
    return;
}
var hairVisuals = [];
getActiveHairVisuals(script.hairComponents, hairVisuals);

function onUpdate() {
    for (var i = 0; i < hairVisuals.length; i++) {
        updateGravity(hairVisuals[i]);
    }
}

function updateGravity(hv) {
    hv.gravity = dt.getTransform().down.uniformScale(script.gravityForce);
}

function getActiveHairVisuals(sceneObject, hairVisualsOut) {
    if (sceneObject.enabled) {
        var currentHairVisuals = sceneObject.getComponents("Component.HairVisual");
        for (var i = 0; i < currentHairVisuals.length; i++) {
            if (currentHairVisuals[i].enabled) {
                hairVisualsOut.push(currentHairVisuals[i]);
            }
        }
        for (var j = 0; j < sceneObject.getChildrenCount(); j++) {
            getActiveHairVisuals(sceneObject.getChild(j), hairVisualsOut);
        }
    }
}

var updateEvent = script.createEvent("UpdateEvent");
updateEvent.bind(onUpdate);

# Unity-Planet-Shader
Here is a shader that creates a planet with an atmosphere for Unity.

Planet.shader - Independent shader for the planet, uses two textures for the earth with normals and a mask for mixing them. One texture for clouds with a normal and a mixing mask. And the parameters of the atmosphere and its color.

Post Effect - Here the atmosphere is drawn after processing the frame in the post effect: /n
PlanetOnly.shader - Draws the surface of the planet.
PlanetAtmosphere.shader - vertex shader draws the atmosphere (only directional light).
PlanetAtmosphereS.shader - surface shader for the atmosphere of the planet (Simple Specular).
PostOutline.shader - Mixes the frames with the main picture and where only the atmosphere.
PostEffectAtmosphere.cs - A script for the camera, uses a shader to draw the atmosphere (PlanetAtmosphere.shader or PlanetAtmosphereS.shader) and a shader for mixing two frames (PostOutline.shader).

The post effect can be used for soft selection of objects (for this the name PostOutline). To work properly, you need to use the PlanetOnly shader on the object - the planet, the PostEffectAtmosphere script on the camera and in it to specify the atmosphere shader and PostOutline. In the script, specify a layer of objects for which to draw the atmosphere and assign this layer to the planet.
Post-effect problems: objects in front of the planet will not obscure the atmosphere. To fix this, you need to draw other objects in black in the shader of the atmosphere.

The shader was made by Gridnev Sergey Olegovich.

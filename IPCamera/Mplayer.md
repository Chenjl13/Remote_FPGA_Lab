# Here's the instruction of Mplayer!

## 1. Enable camera driver
```
sudo raspi-config
```
<img src="../images/IPCamera/Mplayer1.png">

## 2. Before turning on, make sure you connect the Usb of Raspberry with the Usb of camera!

## 3. Find external camera
```
ls /dev/video*
```
## 4. install mplayer driver
```
sudo apt-get install mplayer -y
```
## 5. install fswebcam driver
```
sudo apt-get install fswebcam -y
```
<img src="../images/IPCamera/Mplayer2.png">

## 6. watch the video
```
sudo mplayer tv://
```
<img src="../images/IPCamera/Mplayer3.png">


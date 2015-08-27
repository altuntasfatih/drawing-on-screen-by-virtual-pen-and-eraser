%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name : Drawing on screen using Camera by virtual pen (IMAGE Processing)
% Author       : M.Fatih Altunta?                                          
% Description  : In this program,using smal  red objects as pen,drawing  anything  on screen
% and using smal blue objects as eraser ,erasering  your's drawings on screen with  Camera
% Video :https://www.youtube.com/watch?v=OOzMhrHIu10&feature=share
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%* if white regions in binary image (Blue objects) is one and it's area
% Area >1000 and  Area<14000 ,is  eraser objects ,else ignore 
%*
%* if white regions(red objects) is  single  and it's area
% Area >300 and  Area<18000 ,is  pen object  ,else ignore 
%*
vidDevice = imaq.VideoDevice('macvideo', 1, 'YCbCr422_1280x720', ... % Acquire input video stream
                    'ROI', [1 1 640 480], ...
                     'ReturnedDataType','uint8',...
                    'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hVideoIn = vision.VideoPlayer('Name', 'Drawing on screen', ... % Output video player
                                'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 1; % Frame number initialization
Cordinate=0;
Cordinate2=0;
%% Processing Loop
while(nFrame < 200)
    rgbFrame = step(vidDevice); % Acquire single frame
    rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
    rgbFrame3=rgbFrame;% Acquire  frame for test red compenent
    rgbFrame2=rgbFrame;% Acquire  frame for test blue compenent
    diffFrame2 = imsubtract(rgbFrame2(:,:,3), rgb2gray(rgbFrame2)); % Get blue component of the frame(fresh frame)
    diffFrame2 = medfilt2(diffFrame2, [3 3]); % Filter out the noise by using median filter
    bw2 = im2bw(diffFrame2,0.15);% Converting binary image 
    bw2 = bwareaopen(bw2,50);%wiping white regions that is smal 50 pixels in binary image
    se2 = strel('disk',3);%Morphologically close image
    bw2 = imclose(bw2,se2);%Morphologically close image
    statsforblue = regionprops(bw2,'Area');%how many pixels in binary image by covered white regions(Blue objects).
    
    %* if white regions(Blue objects) is  single  and it's area
    % Area >1000 and  Area<14000 ,is  eraser object ,else ignore 
    %*
  if(length(statsforblue)==1 && statsforblue.Area(1)>1000 && statsforblue.Area(1)<14000)
   [x2,y2]=find(bw2);% get white region's indexs(Eraser objects);
   Cordinate2 = [x2 y2];% indexs added array  
   % this Processing loop  is erasing.Remove red color's  index ,
   % if eraser's index is equal red color index(wrinting by pen)
   
    for y=1:length(Cordinate2)-1
       [xind,yind]=find(Cordinate(:,1)==Cordinate2(y,1) & Cordinate(:,2)==Cordinate2(y,2));
       Cordinate(xind,:)=[]; %Removing red color's  index in Array 
     end
  end
    % this Processing loop  is writting on screen by red objects(pen)
    % Cordinate is assigned  in below   
    for x=1:length(Cordinate)-1
        %painting pixels  red color  with Cordinates
        rgbFrame(Cordinate(x,1),Cordinate(x,2),1)=225;
        rgbFrame(Cordinate(x,1),Cordinate(x,2),2)=62;
        rgbFrame(Cordinate(x,1),Cordinate(x,2),3)=69;
    end
        
   diffFrame = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the current image(may be painted by pen)
   diffFrame = medfilt2(diffFrame, [3 3]); % Filter out the noise by using median filter
   bw = im2bw(diffFrame,0.30);% Converting binary image 
   bw = bwareaopen(bw,50); %wiping white regions(red regions by writing by pen) that is smal 50 pixels in binary image
   se = strel('disk',2);%Morphologically close image
   bw = imclose(bw,se);%%Morphologically close image
              
                    
   diffFrame3 = imsubtract(rgbFrame3(:,:,1), rgb2gray(rgbFrame3)); % Get red component of the frame(fresh frame)
   diffFrame3 = medfilt2(diffFrame3, [3 3]); % Filter out the noise by using median filter
   bw3 = im2bw(diffFrame3,0.30);% Converting binary image
   bw3 = bwareaopen(bw3,50);% wiping white regions(pen objects(pen is red objects) that is smal 50 pixels in binary image
   se3 = strel('disk',3);%Morphologically close image
   bw3 = imclose(bw3,se3);%Morphologically close image
   statsforred = regionprops(bw3,'Area');%how many pixels in binary image by covered white regions in binary image(red objects).
   
      
    %* if white regions(red objects) is  single  and it's area
    % Area >300 and  Area<18000 ,is  pen object  ,else ignore 
    %*
   if(length(statsforred)==1 && statsforred.Area(1)>300 && statsforred.Area(1)<18000)
       
      [x,y]=find(bw);% get white region's indexs(pen objects or region's that painted by pen);
      Cordinate = [x y];%adding  array,This array using writting above (adding red color this pixels );
   end
                  
    step(hVideoIn, rgbFrame); % Output video stream
    nFrame = nFrame+1;
end
%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
% clear all;
clc;
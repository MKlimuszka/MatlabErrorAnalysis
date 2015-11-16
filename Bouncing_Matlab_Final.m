%Matthew Klimuszka
%#4223034
%ezxmk6@nottingham.ac.uk

%This code will plot the height of a bouncing ball over time. It can run as
% many simulations as required with random error added to the startingheight 
% and then plot summary data of all simulations. It gives users the option
% to animate the trials or not. It is recommended not to animate more than
% one trial since it takes a signifigant amount of time. If only one
% simulation is animated, it also gives the user the option of recording
% the animation as an .avi file at a location specified. The entire path
% must be entered by the user since matlab runs on a read-only directory on
% Uni computers.

%reset everything
close all;
clear all;
clc;

%user input

ypos = input('Enter initial heigh in cm. ');
COR = input('Enter coeffecient of restitution. ');
repeat = input('How many times should the simulation repeat? ');
errq = input('How much random error should be added to each drop in cm? ');       
anim = input('Animate drops? [Y/N] ','s');
     animbin = strcmp(anim, 'Y'); %check to see if the user entered 'Y' or 'y', otherwise do not animate. 
        if animbin == 0
            animbin = strcmp(anim, 'y');
        end
if animbin == 1 && repeat == 1     %don't ask to record a video if there is no animation to record or if there will be multiple simulations.
vrecord = input('Should video be recorded? [Y/N] ','s');
    recbin = strcmp(vrecord, 'Y'); %check to see if the user entered 'Y' or 'y', otherwise do not record. 
        if recbin == 0
            recbin = strcmp(vrecord, 'y');
        end
else 
    recbin=0; %if there is no animation, dont ask to record it
end

if recbin == 1
   path = input('Enter the complete path location including filename to save the animation. ','s');    %This can be a little tricky. largely since there are file permission issues on Uni lab computers.
end

%constants
g = -981; %gravity
dt = 1/100; %Time step this can be changed to make the graphs animate faster, but this value gives a nice smooth curve.   

%Prepare animation file
if recbin == 1
    writerObj = VideoWriter(path);
    writerObj.FrameRate=1/dt;
    writerObj.Quality=95;
    open(writerObj);
    %Generate initial data and set axes and figure properties.
  
end

xaxislength = COR^3*(0.046*ypos+4.8); %scale axis according to drop height and COR. Equation was experimentally chosen to represent data over a range of COR and drop heights

for n = 1:repeat %repeat simulation as many times as asked. %n is the index for # of simulations that have occurred

    if animbin == 1
      %  figure %make a new figure if we are animiating things. This is
      %  required in older versions of Matlab (such as those in the
      %  graduate center in the ESLC. Uncomment that command if figures aren't
      %  being drawn correctly. 
    end
    
%Set initial values
bendi = 0; %Has the ball bounced 10 times? No, so just initialize this to zero
y(n,1) = ypos + (rand-0.5)*errq*2 ; %initial Height with random error +- whatever was entered initially.   
tt(n,1)=0; %initial time
i = 2; %initial time index
peaky(n,1) =  y(n,1); %set starting drop height in peak matrix. This matrix keeps track of peak heights. 
peakt(n,1) = 0; %ball is dropped at t=0. This matrix keeps track of peak times. 
j=2; %peak index. For numbering peaks, the drop counts as the first peak.
bounce = 0; %Number of bounces that have occurred
yvel = 0; %initial velocity
    
while bounce < 15 %bounce 15 times because we care about 10 bounces, but this gives time for the viewer to take in the entire data set before moving on.
   
   y(n,i) = y(n,i-1) + yvel*dt+ 0.5*g*dt.^2; %update height using standard mechanics equation
   tt(n,i)= tt(n,i-1) + dt; %update time by incrementing it by dt
  
   %%%%%%%%%% Test for peaks %%%%%%%%%%%%
   if i > 2 && j < 11 %make sure we don't check first few data values for peaks, and ignore peaks past 10th bounce, since those are there only to pad the animation
       
   if y(n,i) < y(n,i-1) && y(n,i-2) < y(n,i-1) %last point was peak since the middle point was higher than the ones adjacent to it
      peakt(n,j) = tt(n,i-1); %record peak time
      peaky(n,j) = y(n,i-1); %record peak height
      j = j+1; %increment number of peaks that have occurred
   end    
   end
   %%%%%%%%%% End Test for peaks %%%%%%%%
   
   
   %%%%%%%%%%Test for bounces%%%%%%%%%%%%%
   
   if y(n,i) < 0 % A bounce occurred
      y(n,i)=0 ; %Reset the height to zero
      tt(n,i) = tt(n,i-1) + (sqrt( yvel.^2 -4*0.5*g*-y(n,i-1)) + yvel)/(g); %Change the time of the data point to where it would have been at y=0
      yvel = -COR*(yvel + g*(tt(n,i)-tt(n,i-1))); %accelerate the ball and use COR
      bounce = bounce+1; %Count the bounce
      if bounce < 11
      bouncet(n,bounce) = tt(n,i); %record the time of the bounce for summary data
      end
      if bounce > 9 && bounce < 11 %mark when the 10th bounce happens so we can change the color of the plot
          bendi = i;
      end   
   else %A bounce has not occurred
       yvel = yvel + g*dt; %accelerate ball normally
   end
   
   i = i+1; %Increment time index
   
   %%%%%%%%%%End Test for bounces%%%%%%%%%%%
   
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%PLOTTING%%%%%%%%%%%%%%%%%%%%%%%%%%
   if animbin == 1 %if we are animating
       
       if tt(n,i-1) > xaxislength %if parameters are chosen that cause plotting outside the predefined range, extend the range. 
           xaxislength = xaxislength*1.5;
       end
       
    clf %clear the figure
    subplot (2,1,1);
    if bounce < 10 %we still care about bounces, so plot it in red
         scatter3(tt(n,i-1),0,y(n,i-1),200,'r','filled')
    else %we don't care so plot it in black
         scatter3(tt(n,i-1),0,y(n,i-1),200,'k','filled')
    end       
    axis([0,xaxislength,-1,1,0,ypos*1.25])
    title('3D Bouncing Ball Animation')
    xlabel('Time (s)')
    ylabel('AU')
    zlabel('Height (cm)')
    
    subplot(2,1,2)
    if bounce < 10 %just plot the height v time data
        scatter(tt(n,1:i-1),y(n,1:i-1),5,'r','filled')
    else %plot the first ten bounces in red, then the rest in black
        hold on
        scatter(tt(n,1:bendi),y(n,1:bendi),5,'r','filled')
        scatter(tt(n,bendi:i-1),y(n,bendi:i-1),5,'k','filled')
        hold off
    end    
    
    text(0.1, y(n,1)+ypos/13, num2str(y(n,1),3)) %label the drop height
    
    if j > 1  %peaks have happened, so label them slightly above where they happened to the nearest cm
        for w = 2:(j-1)
            if peaky(n,w) > 100 %Keep the number of signifigant digits to the cm place. 
                text(peakt(n,w),peaky(n,w)+ ypos/13,num2str(peaky(n,w),3),'HorizontalAlignment','center');
            else
                text(peakt(n,w),peaky(n,w)+ ypos/13,num2str(peaky(n,w),2),'HorizontalAlignment','center');
            end
         end
    end
    
    %format axes and titles
    axis([0,xaxislength,0,ypos*1.25])
    title(['Bouncing Ball Simulation ' num2str(n)])
    xlabel('Time (s)')
    ylabel('Height (cm)')
    drawnow  %force figure update % add "limitrate" on newer matlab versions if available
    if recbin == 1 %grab frames for video
        frame = getframe(gcf);    
        writeVideo(writerObj,frame);
    end
    
   end
    %%%%%%%%%%%%%%%%%%%%%%%END PLOTTING%%%%%%%%%%%%%%%%%%%%%%
 
end
if recbin == 1
    close(writerObj); %close video object
end

disp([num2str(n) ' Done']); %print out which simulation has finished to keep track. 
end

%%%%%%%%%%%Summary data from multiple simulations%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if repeat > 1
    meanpeak = mean(peaky); %Mean bounce heights
    stddevpeak = std(peaky); %Standard deviation of bounce heights
    meanpeakt = mean(peakt); %Mean bounce peak times
    stddevpeakt = std(peakt); %Standard deviation of bounce peak times
    meanbouncet = mean(bouncet);%mean bounce times
    stddevbouncet = std(bouncet);%standard deviation of bounce times
    
    
 %Prepare data table in correct format. This puts everything in one big
 %matrix. 
    
 statdata(1,:) = meanpeakt;
 statdata(2,:) = stddevpeakt;
 statdata(3,:) = meanpeak;
 statdata(4,:) = stddevpeak;
 statdata(5,:) = meanbouncet;
 statdata(6,:) = stddevbouncet;
     
%plot data table of summary values. 
 scrsz = get(0,'ScreenSize'); %Get screen resolution
 f = figure('Position',[scrsz(3)/8 scrsz(4)/8 scrsz(3)*.8 scrsz(4)*.8]);%make figure a large portion of the screen. Otherwise labels will overlap. 
 cnames = {'1','2','3','4','5','6','7','8','9','10'};
 rnames = {'Peak Time Mean(s)', 'Peak Time Stdev (s)', 'Peak Height Mean (cm)',  'Peak Height Stdev (cm)','Bounce Time Mean (s)','Bounce Time Stdev (s)'};
 t = uitable ('Parent',f, 'Data', statdata, 'ColumnName', cnames, 'RowName',rnames,'Position',[scrsz(3)*.3 scrsz(4)*.55 scrsz(3)*.38 scrsz(4)*.15]);
 set(t,'ColumnWidth',{45})
  
 
 hold on
     %Set graph properties
    axis([0,xaxislength,0,ypos*1.25])
    title({'Bouncing Ball Mean Data ';'Rectangles show standard deviations of values. If a standard deviation is less than 0.01, it is plotted as 0.01 to be visible.'; ...
        'There is no uncertainty in bounce height (it is defined as height = 0), but it is set to 0.01 to be visible';'Accurate numbers are shown in the table.'})
    xlabel('Time (s)')
    ylabel('Height (cm)')
   
    
    %%%If stdev is less than 0.01, set it to 0.01 so it will show up on
    %%%plot. 
     for c = 1:10
     if stddevpeakt(c) < 0.01
         stddevpeakt(c)= 0.01;
     end
     if stddevpeak(c)  < 0.01
         stddevpeak(c)= 0.01;
     end
     if stddevbouncet(c)  < 0.01
         stddevbouncet(c)= 0.01;
     end
     end
    
    %%%plot points with error using rectangles to represent error range
    for d = 1:10
       rectangle('Position',[meanpeakt(d) - stddevpeakt(d) ,meanpeak(d) - stddevpeak(d),stddevpeakt(d)*2,stddevpeak(d)*2],'FaceColor','b')
       rectangle('Position',[meanbouncet(d) - stddevbouncet(d) ,0,stddevbouncet(d)*2,0.02],'FaceColor','b')
    end
    
    
    %label coordinates of points
     text(0.1, meanpeak(1)+meanpeak(1)/50, ['(' num2str(meanpeakt(1),3) ' , ' num2str(meanpeak(1),3) ')']) %label drop to the right so it can be seen on plot
     
     for w = 2:(10)%label the drop seperately
         %peak labels
            if peaky(w) > 100
                text(meanpeakt(w),meanpeak(w)+ meanpeak(1)/50,['(' num2str(meanpeakt(w),3) ',' num2str(meanpeak(w),3) ')'],'HorizontalAlignment','center');
            else
                text(meanpeakt(w),meanpeak(w)+ meanpeak(1)/50,['(' num2str(meanpeakt(w),3) ',' num2str(meanpeak(w),2) ')'],'HorizontalAlignment','center');
            end
     end
     for w = 1:(10)
         %bounce labels
                text(meanbouncet(w),meanpeak(1)/50,[num2str(meanbouncet(w),3)],'HorizontalAlignment','center');
     end

    hold off
 
end %End statistical section that requires multiple runs

disp('All Done'); %report that all simulations have finished. 



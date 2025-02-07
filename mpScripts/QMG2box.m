% QMG2box.m

% DOING PHYSICS WITH MATLAB
% https://d-arora.github.io/Doing-Physics-With-Matlab/
% Documentation
% https://d-arora.github.io/Doing-Physics-With-Matlab/mpDocs/QMG2B.htm
% IAN COOPER
% matlabvisualphysics@gmail.com
% 2300504   Matlab R2021b

clear; close all;clc

% ANIMATION SETUP =======================================================
% (0 no)  (1 yes) for flag1
   flag1 = 1;    
% file name for animated gif   
    ag_name = 'agBox23.gif'; 
% Delay in seconds before displaying the next image  
    delay = 0.00; 
% Frame to start
    frame1 = 0;

% INPUTS =============================================================
% Enter: quantum numbers M and N  /  coeff cM and cN  /  width of box L
  M = 1; N = 2;
  cM = 1; cN = 2;
  L = 0.5e-9;
  numX = 299;
  numT = 99;
  tScale = 2;   % time scaling factor for tMax
  tPause = 0.1; % time for pause in animation

% SETUP ===============================================================  
  kM = M*pi/L; kN = N*pi/(L); 
  x1 = -L/2; x2 = L/2; 
  x = linspace(x1,x2,numX);
  dx = x(2)-x(1);
% Flag for <x> = 0
  flagX = 0;
  if mod(N+M,2) == 0; flagX = 1; end
% Constants
  h    = 6.62607015e-34;
  hbar = 1.05457182e-34;
  m    = 9.1093837e-31;
  e    = 1.60217663e-19;
  E0   = h^2/(8*m*L^2);
  K    = -hbar^2/(2*m);

% total energies E [J]  /  frequencies w [rad/s] / period P [s]
  EM = M^2*E0; EN = N^2*E0;
  wM = EM/hbar; wN = EN/hbar; 
  fM = wM/(2*pi); fN = wN/(2*pi);
  PM = 1/fM; PN = 1/fN;

% Stationary state Wavefunctions  
  psiM = sqrt(2/L).*sin(kM*(L/2-x));
  psiN = sqrt(2/L).*sin(kN*(L/2-x)); 
% Check normalize of stationary state wavefuntions
  normM = simpson1d(psiM.^2,x1,x2);
  normN = simpson1d(psiN.^2,x1,x2);
  orthonormal = abs(simpson1d(psiM.*psiN,x1,x2));
% Time dependence
   tMax = PM;
   if PN > PM; tMax = PN; end
   t = linspace(0,tScale*tMax,numT);
   dt = t(2)-t(1);
    PSIM = zeros(numX,numT);
    PSIN = zeros(numX,numT);
   for ct = 1:numT
      PSIM(:,ct) = psiM.*exp(-1i*wM*t(ct));
      PSIN(:,ct) = psiN.*exp(-1i*wN*t(ct));
   end

% WAVEFUNCTION: linear combination
  PSI = cM.*PSIM + cN.*PSIN;
% Normalize function
  A = simpson1d((conj(PSI(:,1)).*PSI(:,1))',-L/2,L/2);
  AMN = 1/sqrt(A);
  PSI = PSI./sqrt(A);
  normMN = simpson1d((conj(PSI(:,1)).*PSI(:,1))',-L/2,L/2);
  pdMN = conj(PSI).*PSI;
  cM = cM*AMN; cN = cN*AMN;
  
% Probability densities
  pdM = conj(PSIM).*PSIM;
  pdN = conj(PSIN).*PSIN;

% Fourier transform
  tMin = 0;
  fMax = 1.5*max([fM fN]); fMin= -fMax; nF = 2001;
  f = linspace(fMin,fMax,nF);

% Expectation value <x> and <E>
  xAVG = zeros(numT,1); 
  if flagX == 0 
  for ct = 1:numT
    AVG = conj(PSI(:,ct)).*x'.*PSI(:,ct);
    xAVG(ct) = simpson1d(AVG',-L/2,L/2);
  end
   [~,peaklocs] = findpeaks(real(xAVG));
   dp = mean(diff(peaklocs));
   Ppeaks = dt*dp;

  hX = xAVG'; HX = zeros(1,nF);
  for c = 1:nF
     g = hX.* exp(1i*2*pi*f(c)*t);
     HX(c) = simpson1d(g,tMin,tMax);
   end
     HX = HX./max(HX);
  [~,peaklocs] = findpeaks(real(HX),'MinPeakHeight',0.5);
      fPeak = max(f(peaklocs));
  end

  EAVG = zeros(numT,1);
  for ct = 1:numT
    G = PSI(:,ct);
    G1 = gradient(G,dx); G2 = gradient(G1,dx);
    GG = conj(G).*G2;
    EAVG(ct) = K*simpson1d(GG',-L/2,L/2);
  end
 
  % Fourier transform PSI at x(105)
    hP = PSI(105,:); HP = zeros(1,nF);
   for c = 1:nF
     g = hP.* exp(1i*2*pi*f(c)*t);
     HP(c) = simpson1d(g,tMin,tMax);
   end
     HP = HP./max(HP);
     psd = conj(HP).*HP;


% Dipole radiation
  flagDR = 0;
  dn = abs(M-N);
  dE = abs(EM-EN)/e;
  if mod(dn,2) == 0; flagDR = 1; end

% OUTPUT
   fprintf('Quantum numbers, M = %2.0f   N  = %2.0f  \n',M,N)
   fprintf('Check normalization: normM = %2.4f  normN = %2.4f  normMN = %2.4f  \n', ...
       normM, normN, normMN)
   fprintf('Orthonormal = %1.4f  \n',orthonormal)
   disp('STATIONARY STATES M and N')
   fprintf('  Total energies:  EM = %2.4f eV   EN = %2.4f eV  \n', EM/e,EN/e)
   fprintf('  Ang. frequencies omegaM = %2.2e rad/s   omegaN = %2.2e rad/s  \n', wM,wN)
   fprintf('  Frequencies fM = %2.2e Hz  fN = %2.2e Hz  \n', fM,fN)
   fprintf('  Periods     PM = %2.2f fs   PN = %2.2f fs  \n', PM/1e-15,PN/1e-15)
   disp('COMPOUND STATE MN')
   fprintf('  coeff: cM^2 = %2.4f  cN^2 = %2.4f  cM^2+cN^2 = %2.4f  \n', cM^2, cN^2, cM^2+cN^2)
   fprintf('  Total energy  <EMN> = %2.4f eV  \n', max(EAVG)/e)
   if flagX == 1; disp('   <x> = 0'); end
   if flagX == 0
   fprintf('  <x> period    = %2.4f fs  \n', Ppeaks/1e-15) 
   fprintf('  <x> frequency = %2.4e Hz  \n', fPeak) 
   end
   if flagDR == 0; fprintf('   Dipole radiation dE = %1.4f eV \n',dE); end
   if flagDR == 1; disp('   Dipole radiation forbidden')
   end
 

% GRAPHICS  ===============================================================
figure(1)
  set(gcf,'units','normalized');
  set(gcf,'position',[0.1 0.1 0.30 0.60]);
  set(gcf,'color','w');
  FS = 14;

for ct = 1: numT  

subplot(3,2,1)  
  xP = x./1e-9; yP = real(PSIM(:,ct));
  plot(xP,yP,'b','LineWidth',2)
  ylim([-8e4 8e4])
  grid on
  txt = sprintf('\\psi_{%1.0f }',M);
  ylabel(txt)
  set(gca,'FontSize',FS)
  title('     Wavefunction','FontWeight','normal','FontSize',12)

  subplot(3,2,3)  
   yP = real(PSIN(:,ct));
   plot(xP,yP,'b','LineWidth',2)
   ylim([-8e4 8e4])
   grid on
   txt = sprintf('\\psi_{%1.0f }',N);
   ylabel(txt)
   set(gca,'FontSize',FS)
subplot(3,2,5)  
   yP = real(PSI(:,ct));
   plot(xP,yP,'r','LineWidth',2)
   ylim([-8e4 8e4])
   grid on
   xlabel('x  [nm]')
   ylabel('\psi')
   set(gca,'FontSize',FS)

subplot(3,2,2)  
  xP = x./1e-9; yP = pdM(:,ct);
  plot(xP,yP,'b','LineWidth',2)
  ylim([0 6e9])
  grid on
  txt = sprintf('|\\psi_{%1.0f }|^2',M);
  ylabel(txt)
  set(gca,'FontSize',FS)
  title('     Prob. density','FontWeight','normal','FontSize',12)
  subplot(3,2,4)  
   yP = pdN(:,ct);
   plot(xP,yP,'b','LineWidth',2)
   ylim([0 6e9])
   grid on
   txt = sprintf('|\\psi_{%1.0f }|^2',N);
   ylabel(txt)
   set(gca,'FontSize',FS)
subplot(3,2,6)  
   yP = pdMN(:,ct);
   plot(xP,yP,'r','LineWidth',2)
   ylim([0 8e9])
   grid on
   xlabel('x  [nm]')
   ylabel('|\psi|^2')
   txt = sprintf('c_M^2 = %0.2f  c_N^2 = %0.2f  \n',cM^2,cN^2);
   title(txt,'FontWeight','normal')
   set(gca,'FontSize',FS)

    if flag1 > 0
         frame1 = frame1 + 1;
         frame = getframe(1);
         im = frame2im(frame);
         [imind,cm] = rgb2ind(im,256);
      % On the first loop, create the file. In subsequent loops, append.
         if frame1 == 1
           imwrite(imind,cm,ag_name,'gif','DelayTime',delay,'loopcount',inf);
         else
          imwrite(imind,cm,ag_name,'gif','DelayTime',delay,'writemode','append');
         end
    end 
   pause(tPause)
end

figure(3)    % Total energy plots
  set(gcf,'units','normalized');
  set(gcf,'position',[0.63 0.1 0.20 0.6]);
  set(gcf,'color','w');
  FS = 14;  
subplot(2,1,1)
  xP = t./1e-15; yP = real(EAVG./e);
  plot(xP,yP,'b','LineWidth',2)
  ylim([0 max([EM EN]./e)])
  xlim('tight')
  grid on
  txt = '<E>  [ eV ]';
  xlabel('t  [ fs ]')
  ylabel(txt)
  txt = sprintf('<E_{%0.0f%0.0f}>  \n', M,N);
  title(txt,'FontWeight','normal')
  set(gca,'FontSize',FS) 

subplot(2,1,2)
  xP = [0 1]; yP = [E0 E0]./e;
  plot(xP,yP,'r','LineWidth',2)
  hold on
  yP = [E0 E0].*(4/e); 
  plot(xP,yP,'LineWidth',2)
  yP = [E0 E0].*(9/e); 
  plot(xP,yP,'LineWidth',2)
  yP = [E0 E0].*(16/e); 
  plot(xP,yP,'LineWidth',2)
  yP = [max(real(EAVG)) max(real(EAVG))]./e; 
  plot(xP,yP,'b','LineWidth',2)
  xticks([])
  ylabel('E  [eV]')
  title('Energy spectrum','FontWeight','normal')
  legend('E_1','E_2','E_3','E_4','<E>')
  set(gca,'FontSize',FS) 

figure(4)
  set(gcf,'units','normalized');
  set(gcf,'position',[0.63 0.51 0.20 0.30]);
  set(gcf,'color','w');
  FS = 14;  

  xP = f; yP = conj(HP).*HP;
  plot(xP,yP,'b','LineWidth',2)
  grid on
  xlim([0 fMax])
  xlabel('f  [Hz ]')
  ylabel('\Psi  psd')
  txt = sprintf('f_M = %1.2e Hz  f_N = %1.2e Hz \n',fM, fN);
  set(gca,'FontSize',FS) 
  title(txt,'FontWeight','normal','FontSize',12)

% Expection position <x>  
  if flagX == 0     
figure(5)
  set(gcf,'units','normalized');
  set(gcf,'position',[0.43 0.1 0.20 0.55]);
  set(gcf,'color','w');
  FS = 14;  
subplot(2,1,1)
  xP = t./1e-15; yP = real(xAVG./1e-9);
  plot(xP,yP,'b','LineWidth',2)
  grid on
  txt = '<x>  [ nm ]';
  xlabel('t  [ fs ]')
  ylabel(txt)
  ylim([-L/4 L/4]./1e-9)
  xlim('tight')
  txt = sprintf('<x>  period = %1.2f  fs  \n',Ppeaks/1e-15);
  title(txt,'FontWeight','normal')
  set(gca,'FontSize',FS)
subplot(2,1,2)  
  xP = f; yP = conj(HX).*HX;
  plot(xP,yP,'b','LineWidth',2)
  grid on
  xlim([0 fMax])
  xlabel('f  [Hz ]')
  ylabel('<x>  psd')
  txt = sprintf('<x>  frequency = %1.2e  Hz  \n',fPeak);
  title(txt,'FontWeight','normal')
  set(gca,'FontSize',FS)   
  end

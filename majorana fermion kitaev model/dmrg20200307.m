% By Huang Weijie @ SCUT, 2020.03.027
% Running on MATLAB R2019b
clear
clc
format long
%������ʼ��----------------------------------------------------------------%
noftk=10;%���µ������������Ŀ
niter=29;%���ĳ���
Bz=0;%�ų�
%--------------------------------------------------------------------------%
%�������� û��U�Ͳ��ÿ��Ǹ���������
%--------------------------------------------------------------------------%
j.t=1;
j.delta=1;
j.mu=0;
j.u=0;
deltaT = 0.1;%ʱ���ݻ��Ĳ���
steps =50 ;%ʱ���ݻ��Ĳ���
%���������������ʼ��%-----------------------------------------------------%
measure1 = zeros(niter*2+2, 50);%�����������
measure2 = zeros(niter*2+2, 50);
%block��2��site��ʼ ѭ��һ��ϵͳ��һ��site superblockһ��2*Niter+2��site
%����
tot_sites=2*niter+2;
half_sites=niter+1;
sites_in_system=niter;
% Energymin=zeros(1000,1);
% Energy = 0;
% ExactEnergy = -2;
%Sz=zeros(tot_sites,1);
%���ݼ�¼
%��ʼ������   stuct H�������������� ��������͹��ܶ���(I,Sz,Sp,SM,H)�Լ�һ������basis_size)
BLOCK.basis_size = 2;
BLOCK.I = eye(2);
BLOCK.C = [0,0;1,0];%lambda1
BLOCK.Cdag = [0,1;0,0];%lambda2
BLOCK.H = [0,0;0,0];
BLOCK.N = [0,0;0,1];%lambda1*lambda2
EMPTY.basis_size = 1;
EMPTY.I = 1;
EMPTY.C = 1;
EMPTY.Cdag = 1;
EMPTY.H = 1;
EMPTY.N = 1;
%������ʼ��  ��ÿ�����ĳ�ʼ�������뵽sys_block��environment_block�н��д���
%�ڳ������׺�β����һ����λ���󷽱���洦�� ���Զ����������i����� ����sys_block{i+1}����
system_block = cell(tot_sites + 2, 2 );environment_block = cell(tot_sites + 2, 2 );
for i_1 = 1 : tot_sites+2
    %BLOCK.H=[0,0;0,-10*(mod(i_1,2)-0.5)];
    system_block{i_1, 1} = BLOCK;environment_block{i_1, 1} = BLOCK;
end
for i_2 = 1 : tot_sites+2
    system_block{i_2, 2} = BLOCK;environment_block{i_2, 2} = BLOCK;
end
system_block{1, 1} = EMPTY;environment_block{1, 1} = EMPTY;
system_block{end, 1} = EMPTY;environment_block{end, 1} = EMPTY;
%����ϵͳѭ��--------------------------------------------------------------%
Psi = 0;PsiL = 0; PsiR = 0;
mEnergy = [];
Block_L = BLOCK;Block_R = BLOCK;
for i = 1 : niter
    %��i��ѭ����ʱ�� ��ʱ��Free_siteΪ���Ϊ1+i , niter*2-i-1 ���������
    Free_site_L = system_block{i + 2, 2};
    Free_site_R = system_block{niter * 2 + 3 - i, 2 };
    [Block_L, Block_R] = BlockBuilding_hubbard(Block_L, Free_site_L, Free_site_R, Block_R, j);
    %�Խǻ����ܶ���
    [PsiL, EnergyL, JL] = svd_L(Block_L ,Block_R , j , PsiL);
    [PsiR, EnergyR, JR] = svd_R(Block_L ,Block_R , j , PsiR);
    mEnergy = [mEnergy; EnergyL, EnergyR];
    %���л��任
    [Block_L, Block_R,~,~ ] = Rotate_operator(Block_L , Block_R, PsiL, PsiR, noftk);
    system_block{i+2, 1} = Block_L;
    environment_block{i+2, 1} = Block_R;
end
% m1 = PsiL'*kron(BLOCK.N,eye(32))*PsiR
% m2 = PsiL'*kron(kron(eye(2),BLOCK.N),eye(16))*PsiR
% m3 = PsiL'*kron(kron(eye(4),BLOCK.N),eye(8))*PsiR
% m4 = PsiL'*kron(kron(eye(8),BLOCK.N),eye(4))*PsiR
% m5 = PsiL'*kron(kron(eye(16),BLOCK.N),eye(2))*PsiR
% m6 = PsiL'*kron(kron(eye(32),BLOCK.N),eye(1))*PsiR
% m = [m1,m2,m3,m4,m5,m6];
% plot(m)
%���޲���ѭ��
%��Ϊ����------------------------------------------------------------------%
%Energy2 = Energy;
sites_in_environment = tot_sites - sites_in_system - 2;
counter = 0;Mark2=[];sweep = 1;
mEnergy = [mEnergy; 33, 33];
%for sweep = 1 : 10
while (sweep < 10)||((sum(abs(PsiEnergy(:, 1)-PsiEnergy(:, 2)))>10^(-6))&&(sweep < 10))
    for ii = 1 : 3%iiָ�귴ӳ��Ӧ��ɨ��ʱ����ƶ����� �������� ż������
        change = [ 1 , -1 , 1  ];
        while counter<1000000
            Mark2=[Mark2; sites_in_system, sites_in_environment,sweep, 1, ii];
            %��ɨ����С�Ŀ�����û�и���ʱ��ͻ�����
            if (sites_in_system==0&&ii==2)||(sites_in_environment==0&&ii==1)||(sites_in_environment==0&&ii==3)
                Mark2=[Mark2;0,0,0,2,ii];
                break
            end
            %����һ��sweep
            if ii == 3 && sites_in_system == half_sites-1
                Mark2=[Mark2;0,0,0,3,ii];
                break
            end
            Block_L = system_block{ sites_in_system + 1 , 1 };
            Block_R = environment_block{sites_in_environment + 1 , 1 };
            Free_site_L = system_block{ sites_in_system + 2 , 2 };
            Free_site_R = system_block{ sites_in_system + 3 , 2 };
            %������ܶ���
            [Block_L, Block_R] = BlockBuilding_hubbard(Block_L, Free_site_L, Free_site_R, Block_R, j);
            %�Խǻ�superblock���ܶ��� ���̬
            [PsiL,EnergyL] = svd_L(Block_L, Block_R, j, PsiL);
            [PsiR,EnergyR] = svd_R(Block_L, Block_R, j, PsiR);
            mEnergy = [mEnergy;EnergyL, EnergyR]; 
            %�����̬ ��������
%             PsiEnergy(mod(counter,niter*4)+1,2) = PsiEnergy(mod(counter,niter*4)+1,1); 
%             PsiEnergy(mod(counter,niter*4)+1,1) = Energy; 
            %����
            [measure_temp1, measure_temp2] = Measure(Block_L, Free_site_L, Free_site_R, Block_R, PsiL, PsiR);
            %���ܶȾ��� Լ���ܶȾ��� ��任���� ���ر任����
            [Block_L, Block_R, transform1, transform2] = Rotate_operator(Block_L, Block_R, PsiL, PsiR, noftk);
            if  ii == 1|| ii == 3
                system_block{sites_in_system + 2, 1 } = Block_L;
            elseif ii == 2
                environment_block{sites_in_environment + 2, 1 } = Block_R;
            end
            if ii == 2||(ii==3&&sites_in_system==0)
                measure1(sites_in_system+1, sweep) = measure_temp1;
                measure1(sites_in_system+2, sweep) = measure_temp2;
            end
            %��¼ÿ��������ĸ�����仯  ii����changeΪ1 ��Ӧ�����system���� �ұ�environment��С
            sites_in_environment = sites_in_environment - change(ii);
            sites_in_system = sites_in_system + change(ii);
            counter = counter + 1 ;
        end
    end
    sweep = sweep + 1;
end
figure(1)
plot(measure1(:,1));





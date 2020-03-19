

clear
clc
format long
%������ʼ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noftk=100;%���µ������������Ŀ
niter=29;%���ĳ���
Bz=0;%�ų�
j.t=1;
j.delta=1;
j.mu=1.5;
j.u=1.6;
deltaT = 0.1;%ʱ���ݻ��Ĳ���
steps =50 ;%ʱ���ݻ��Ĳ���

%���������������ʼ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
measure1 = zeros(niter*2, 10);%�����������
measure2 = zeros(niter*2, steps);
PsiEnergy = zeros(4*niter,2);%�����������
%measure3 = zeros(niter*2, 10);
%block��2��site��ʼ ѭ��һ��ϵͳ��һ��site superblockһ��2*Niter+2��site
%����
tot_sites=2*niter+2;
half_sites=niter+1;
sites_in_system=niter;
Energymin=zeros(1000,1);
Energy = 0;
ExactEnergy = -2;
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
system_block = cell( tot_sites + 2 , 2 );environment_block = cell( tot_sites + 2 , 2 );
for i_1 = 1 : tot_sites+2
    %BLOCK.H=[0,0;0,-10*(mod(i_1,2)-0.5)];
    system_block{ i_1 , 1 } = BLOCK;environment_block{ i_1 , 1 } = BLOCK;
end
for i_2 = 1 : tot_sites+2
    system_block{ i_2 , 2 } = BLOCK;environment_block{ i_2 , 2 } = BLOCK;
end
system_block{ 1 , 1 } = EMPTY;environment_block{ 1 , 1 } = EMPTY;
system_block{ end , 1 } = EMPTY;environment_block{ end , 1 } = EMPTY;
%����ϵͳѭ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Psi = 0;
mEnergy = [];
Block_L = BLOCK;Block_R = BLOCK;
for i = 1 : niter
    %��i��ѭ����ʱ�� ��ʱ��Free_siteΪ���Ϊ1+i , niter*2-i-1 ���������
    Free_site_L = system_block{ i + 2 , 2 };
    Free_site_R = system_block{ niter * 2 + 3 - i , 2 };
    %�����ǽ����ҿ���������ɸ�㵱��������������ص���ϵͳ���ܶ����������������ɸ��Ŀ�
    [ Block_L , Block_R ] = BlockBuilding_hubbard ( Block_L , Free_site_L , Free_site_R , Block_R , j  , Bz );
    %�Խǻ����ܶ���
    %LastEnergy = Energy;
    [HL1,HL4,HR1,HR4] = nonhermitian(Block_L ,Block_R);
    [PsiL,EnergyL] = lanczos(HL1 ,HL4 , j );
    [PsiR,EnergyR] = lanczos(HR1 ,HR4 , j );
    mEnergy = [mEnergy;EnergyL, EnergyR];
    %EnergyPerBond = ( Energy - LastEnergy ) / 2;
    %�˺����ǽ��л��任��������������Ĺ��ܶ�����������б任  ������ǻ�̬ �������溬�����ܶȾ����Լ���ܶȾ���Ĳ���
    [ Block_L , Block_R,~,~ ] = Rotate_operator( Block_L , Block_R , PsiL , PsiR  , noftk );
    system_block{ i+2 , 1 } = Block_L;
    environment_block{ i+2 , 1 } = Block_R;
end


%���޲���ѭ��
%��Ϊ����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Energy2 = Energy;
sites_in_environment = tot_sites - sites_in_system - 2;
counter = 0;Mark2=[];sweep = 1;
mEnergy = [mEnergy;33,33];
%for sweep = 1 : 10
while (sweep <10)||((sum(abs(PsiEnergy(:,1)-PsiEnergy(:,2)))>10^(-6))&&(sweep<30))
    for ii = 1 : 3%iiָ�귴ӳ��Ӧ��ɨ��ʱ����ƶ����� �������� ż������
        change = [ 1 , -1 , 1  ];
        while counter<1000000
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
            [ Block_L , Block_R ] = BlockBuilding_hubbard ( Block_L , Free_site_L , Free_site_R , Block_R , j ,Bz );
            %�Խǻ�superblock���ܶ��� ���̬
            LastEnergy2 = Energy2;
            [HL1,HL4,HR1,HR4] = nonhermitian(Block_L ,Block_R);
            [PsiL,Energy] = lanczos(HL1 ,HL4 , j );
            [PsiR,Energy] = lanczos(HR1 ,HR4 , j );
            %�����̬ ��������
            mEnergy = [mEnergy;EnergyL, EnergyR];
            %����
            [ measure_temp1 , measure_temp2 ] = Measure ( Block_L , Free_site_L , Free_site_R , Block_R , PsiL , PsiR );
            %���ܶȾ��� Լ���ܶȾ��� ��任���� ���ر任����
            [ Block_L , Block_R , transform1 , transform2] = Rotate_operator( Block_L , Block_R , PsiL , PsiR  , noftk );
            %�洢�任����
            if mod(ii,2)==1
                transform_L{sites_in_system+2} = transform1;
            else
                transform_R{sites_in_environment+2} = transform2;
            end
            %��ÿ��sweep�� ѡ��ii����2��ʱ����еĲ����������
            if  ii == 1|| ii == 3
                system_block{ sites_in_system + 2 , 1 } = Block_L;
            elseif ii == 2
                environment_block{ sites_in_environment + 2 , 1 } = Block_R;
                measure1(sites_in_system+1, sweep) = abs(measure_temp1);
                measure2(sites_in_system+2, sweep) = measure_temp2;
            end
            %��¼ÿ��������ĸ�����仯  ii����changeΪ1 ��Ӧ�����system���� �ұ�environment��С
            sites_in_environment = sites_in_environment - change(ii);
            sites_in_system = sites_in_system + change(ii);
            Mark2=[Mark2; sites_in_system,sites_in_environment,sweep,1,ii];
            counter = counter + 1 ;
        end
    end
    sweep = sweep + 1;PsiEnergy;
end
figure(1)
plot(measure1(3:end,9));
figure(2)
plot(measure2(3:end,9));



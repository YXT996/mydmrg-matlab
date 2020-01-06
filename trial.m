clear
clc
format long
t=1;
noftk=40;%���µ������������Ŀ
niter=29;%���ĳ���
Bz=0;j=1;deltaT = 0.2;%�ų�
measure1 = zeros(niter*2, 10);%�����������
measure2 = zeros(niter*2, 20);
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
BLOCK.C = [0,1;0,0];
BLOCK.Cdag = [0,0;1,0];
BLOCK.H = [0,0;0,0];
BLOCK.N = [0,0;0,1];
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
%����Ŷ�����
K.basis_size = 2;
K.I = eye(2);
K.C = [0,1;0,0];
K.Cdag = [0,0;1,0];
K.H = [0,0;0,-20];
K.N = [0,0;0,1];
system_block{1+half_sites,2} = K;
system_block{-2+half_sites,2} = K;
system_block{1+half_sites,1} = K;
system_block{-2+half_sites,1} = K;
groundstate = cell(tot_sites+2,1);
transform_L = cell(tot_sites+2,1);transform_L{2,1}=eye(2);transform_L{1,1}=1;
transform_R = cell(tot_sites+2,1);transform_R{2,1}=eye(2);transform_R{1,1}=1;
%����ϵͳѭ��
Block_L = BLOCK;Block_R = BLOCK;
for i = 1 : niter
    %��i��ѭ����ʱ�� ��ʱ��Free_siteΪ���Ϊ1+i , niter*2-i-1 ���������
    Free_site_L = system_block{ i + 2 , 2 };
    Free_site_R = system_block{ niter * 2 + 3 - i , 2 };
    %�Խǻ����ܶ���
    LastEnergy = Energy;
    [Psi,Energy] = lanczos2(Block_L , Free_site_L , Free_site_R , Block_R ,j);
    %�����ǽ����ҿ���������ɸ�㵱��������������ص���ϵͳ���ܶ����������������ɸ��Ŀ�
    [ H_super , Block_L , Block_R ] = BlockBuilding_hubbard ( Block_L , Free_site_L , Free_site_R , Block_R , j  , Bz );
    %[ Psi , Energy ] = eigs ( H_super , 1 , 'SR' );
    EnergyPerBond = ( Energy - LastEnergy ) / 2;
    %�˺����ǽ��л��任��������������Ĺ��ܶ�����������б任  ������ǻ�̬ �������溬�����ܶȾ����Լ���ܶȾ���Ĳ���
    [ Block_L , Block_R ] = Rotate_hubbard( Block_L , Block_R , Psi  , noftk );
    system_block{ i+2 , 1 } = Block_L;
    environment_block{ i+2 , 1 } = Block_R;
end

%���޲�������
Energy2 = Energy;
sites_in_environment = tot_sites - sites_in_system - 2;
counter = 0;Mark2=[];
for sweep = 1 : 1
    for iw = 1 : 3%iiָ�귴ӳ��Ӧ��ɨ��ʱ����ƶ����� �������� ż������
        change = [ 1 , -1 , 1  ];
        while sites_in_system ~= -1 && sites_in_environment ~= -1
            Block_L = system_block{ sites_in_system + 1 , 1 };
            Block_R = environment_block{sites_in_environment + 1 , 1 };
            Free_site_L = system_block{ sites_in_system + 2 , 2 };
            Free_site_R = system_block{ sites_in_system + 3 , 2 };
            %�Խǻ�superblock���ܶ��� ���̬
            LastEnergy2 = Energy2;
            [Psi,Energy] = lanczos2(Block_L , Free_site_L , Free_site_R , Block_R ,j );
            %������ܶ���
            [ H_super , Block_L , Block_R ] = BlockBuilding_hubbard ( Block_L , Free_site_L , Free_site_R , Block_R , j ,Bz );
            %[ Psi , Energy2 ] = eigs( H_super , 1 , 'SR' );
            %�����̬
            groundstate{sites_in_system+1} = Psi;
            convergence = ( Energy2 - LastEnergy2 ) / 2;
            EnergyPerBond2 = Energy2 / ( tot_sites - 1 );
            %����
            [ measure_temp1 , measure_temp2 ] = Measure_hubbard ( Block_L , Free_site_L , Free_site_R , Block_R , Psi );
            %���ܶȾ��� Լ���ܶȾ��� ��任���� ���ر任����
            transform_input1 = transform_L{sites_in_system+1};
            transform_input2 = transform_R{sites_in_environment+1};
            [ Block_L,Block_R,transform1,transform2] = Rotate_hubbard_transformation( Block_L,Block_R,Psi,noftk);
            %�洢�任����
            if mod(iw,2)==1
                transform_L{sites_in_system+2} = transform1;
            else
                transform_R{sites_in_environment+2} = transform2;
            end
            %��ÿ��sweep�� ѡ��ii����2��ʱ����еĲ����������
            if  iw == 1|| iw == 3
                system_block{ sites_in_system + 2 , 1 } = Block_L;
            elseif iw == 2
                environment_block{ sites_in_environment + 2 , 1 } = Block_R;
                measure1(sites_in_system+2, sweep) = measure_temp1;
            end
            %��¼ÿ��������ĸ�����仯  ii����changeΪ1 ��Ӧ�����system���� �ұ�environment��С
            sites_in_environment = sites_in_environment - change(iw);
            sites_in_system = sites_in_system + change(iw);
            Mark2=[Mark2; sites_in_system,sites_in_environment,sweep,iw];
            counter = counter + 1 ;
            if iw == 3 && sites_in_system == half_sites-1
                Mark2=[Mark2;0,0,0,0];
                break
            end
        end
        if iw==1
            sites_in_environment = 1;
            sites_in_system = tot_sites-3;
        elseif iw==2
            sites_in_system = 1;
            sites_in_environment = tot_sites-3;
        end
    end
end

%���޲���ѭ�� ʹ����һ�ֵĲ���������
Energy2 = Energy;
sites_in_environment = tot_sites - sites_in_system - 2;
counter = 0;Mark2=[];
Psi_lanczos = rand(noftk^2*4,1);
for sweep = 1 : 10
    for ii = 1 : 3%iiָ�귴ӳ��Ӧ��ɨ��ʱ����ƶ����� �������� ż������
        change = [ 1 , -1 , 1  ];
        while sites_in_system ~= 1 && sites_in_environment ~= 1
            Block_L = system_block{ sites_in_system + 1 , 1 };
            Block_R = environment_block{sites_in_environment + 1 , 1 };
            Free_site_L = system_block{ sites_in_system + 2 , 2 };
            Free_site_R = system_block{ sites_in_system + 3 , 2 };
            %�Խǻ�superblock���ܶ��� ���̬
            LastEnergy2 = Energy2;
            [Psi,Energy] = lanczos_Psi(Block_L , Free_site_L , Free_site_R , Block_R ,j , Psi_lanczos);
            %������ܶ���
            [ H_super , Block_L , Block_R ] = BlockBuilding_hubbard ( Block_L , Free_site_L , Free_site_R , Block_R , j ,Bz );
            %[ Psi , Energy2 ] = eigs( H_super , 1 , 'SR' );
            %�����̬
            groundstate{sites_in_system+1} = Psi;
            convergence = ( Energy2 - LastEnergy2 ) / 2;
            EnergyPerBond2 = Energy2 / ( tot_sites - 1 );
            %����
            [ measure_temp1 , measure_temp2 ] = Measure_hubbard ( Block_L , Free_site_L , Free_site_R , Block_R , Psi );
            %���ܶȾ��� Լ���ܶȾ��� ��任���� ���ر任����
            transform_input1 = transform_L{sites_in_system+1};
            transform_input2 = transform_R{sites_in_environment+1};
            [Block_L,Block_R,transform1,transform2,Psi_L,Psi_R] = Rotate_hubbard_transformation_fast(Block_L,Block_R,Psi,noftk,transform_input1,transform_input2);
            if  ii == 1||ii==3
                Psi_lanczos = Psi_L;
            elseif ii == 2||ii==4
                Psi_lanczos = Psi_R;
            end
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
                measure1(sites_in_system+2, sweep) = measure_temp1;
            end
            %��¼ÿ��������ĸ�����仯  ii����changeΪ1 ��Ӧ�����system���� �ұ�environment��С
            sites_in_environment = sites_in_environment - change(ii);
            sites_in_system = sites_in_system + change(ii);
            Mark2=[Mark2; sites_in_system,sites_in_environment,sweep,ii];
            counter = counter + 1 ;
            if ii == 3 && sites_in_system == half_sites-1
                Mark2=[Mark2;0,0,0,0];
                break
            end
        end
        if ii==1
            sites_in_environment = 1;
            sites_in_system = tot_sites-3;
        elseif ii==2
            sites_in_system = 1;
            sites_in_environment = tot_sites-3;
        end
    end
end
%ʱ���ݻ�����

Energy3 = Energy;
%ѡ�����߿�����û�и��Ϊʱ���ݻ��Ŀ�ʼ
sites_in_system = 0  ;
sites_in_environment = tot_sites - sites_in_system - 2;
counter2 = 0;Mark1=[];
%��ȡ��ʼ��̬ �����ɸ������
Free_site_L = system_block{ 8 , 2 };
Free_site_R = system_block{ 8 , 2 };
Psi = groundstate{sites_in_system+1};
for sweep = 1 : 20
    %iii��ʾɨ��ʱ���ƶ��ķ���
    for iii = 1 : 4
        change = [ 1 , -1 , 1 , -1 , 1 ];
        while counter2<3000
            %��ɨ����С�Ŀ�����û�и���ʱ��ͻ�����
            if (sites_in_system==0&&iii==2)||(sites_in_environment==0&&iii==1)||(sites_in_environment==0&&iii==3)
                Mark1=[Mark1;0,0,0,0,3,iii];
                break
            end
            %����һ��sweep
            if iii == 4 && sites_in_system == 0
                Mark1=[Mark1;0,0,0,0,2,iii];
                break
            end
            Block_L = system_block{ sites_in_system + 1 , 1 };
            Block_R = environment_block{sites_in_environment + 1 , 1 };
            %����ʱ���ݻ���� iii==1��2����ʱ���ݻ�  iii=3��ʱ����в���
            %iii=4��������Ϊ��ʹ��ÿ��sweep�������ͬ��
            if iii==1||iii==2
                U = Uoperator_hubbard( Block_L , Free_site_L , Free_site_R , Block_R , j , deltaT );
            else
                U = 1;
            end
            Psi = U * Psi;
            %����
            if iii == 3
                [ measure_temp1 , measure_temp2 ] = Measure_hubbard_time ( Block_L , Free_site_L , Free_site_R , Block_R , Psi );
                measure2(sites_in_system+2, sweep) = measure_temp1;
            end
            %��ȡ�任����
            transform_input1 = transform_L{sites_in_system+1};
            transform_input2 = transform_R{sites_in_environment+1};
            %�����ݻ�֮���̬ ���о���任 �任����
            %Psi_L Psi_R��������������������̬
            [ Psi_L , Psi_R ,transform1 , transform2 ] = Rotate_state( Block_L , Block_R , Psi  , noftk ,transform_input1 ,transform_input2 );
            %������Ŀ�ı任������д���
            if iii==1||iii==2
                if mod(iii,2)==1
                    transform_L{sites_in_system+2} = transform1;
                else
                    transform_R{sites_in_environment+2} = transform2;
                end
            end
            %����̬Psi
            if  iii == 1||iii==3
                Psi = Psi_L;
            elseif iii == 2||iii==4
                Psi= Psi_R;
            end
            sites_in_environment = sites_in_environment - change(iii);
            sites_in_system = sites_in_system + change(iii);
            counter2 = counter2 + 1;
            Mark1=[Mark1; sites_in_system,sites_in_environment,size(Psi),1,iii];
        end
    end
end



fprintf('%.8f\t%.8f\t%.8f\n%.8f\t%.8f\t%.8f\n%.8f\n', Energy, EnergyPerBond,ExactEnergy-EnergyPerBond,Energy2,EnergyPerBond2,ExactEnergy-EnergyPerBond2 ,convergence);
figure(1)
plot(measure1(2:end,10));
hold on
plot(measure2(2:end,1:13))
% %figure(2)
% for index = 1:13
%     figure(index)
% plot(measure2(2:end,index));
% end

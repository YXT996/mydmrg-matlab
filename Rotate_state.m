function [ Psi_L , Psi_R , T1 , T2 ] = Rotate_state ( A , B , Psi , noftk ,transform1 , transform2  )
Block1 = A;
Block2 = B;
a1 = Block1.basis_size*2;
b1 = Block2.basis_size*2;
%��ߵ�BLOCK�Ĵ���
Psimatrix = reshape ( Psi , b1 , a1 );
%conj ��Ϊ�˴���������   Psimatrix����ȡ��ת�ù��� �ڹ���Լ���ܶȾ����ʱ����Ҫ���⴦��һ��
RDM = conj(Psimatrix' * Psimatrix);
[ vector ,eigenvalues ] = eig ( RDM );
[ ~ , index ] = sort ( diag ( eigenvalues ) ,'descend' );
vector = vector ( : , index ); 
numbers_to_keep1 = min ( size ( vector , 1 ) , noftk );
T1 = vector ( : , 1 : numbers_to_keep1 );
%�ұߵ�BLOCK�Ĵ���
Psimatrix = reshape ( Psi , b1 , a1 );
RDM = Psimatrix * Psimatrix';
[ vector , eigenvalues ] = eig( RDM );
[ ~ , index ] = sort( diag ( eigenvalues ) , 'descend' );
vector = vector( : , index );
numbers_to_keep2 = min( size ( vector , 1 ) , noftk );
T2 = vector ( : , 1 : numbers_to_keep2 );
Psi_L = kron(kron(T1',eye(2)),transform2)*Psi;
Psi_R = kron(kron(transform1,eye(2)),T2')*Psi;%eye(2)����Ϊtransmform������һ��ѭ�� ��Ӧ���Сһ����� 
%��Ҫһ��eye��2����Ӧ�ո�����������Ĵ�С
Psi_L = Psi_L./norm(Psi_L);
Psi_R = Psi_R./norm(Psi_R);
end
function [Block1,Block2,T1,T2] = Rotate_hubbard_transformation (A,B,Psi,noftk)
Block1 = A;
Block2 = B;
a1 = Block1.basis_size;
b1 = Block2.basis_size;
%��ߵ�BLOCK�Ĵ���
Psimatrix = reshape ( Psi , b1 , a1 );
RDM = Psimatrix' * Psimatrix;
%�Խǻ�Լ���ܶȾ��� ������ߵĿ�
[ vector1 ,eigenvalues ] = eig ( RDM );
[ ~ , index ] = sort ( diag ( eigenvalues ) ,'descend' );
vector1 = vector1 ( : , index );
numbers_to_keep = min ( size ( vector1 , 1 ) , noftk );
T1 = vector1 ( : , 1 : numbers_to_keep );
Block1.basis_size = numbers_to_keep;
Block1.H  = T1' * Block1.H * T1;
Block1.C = T1' * Block1.C * T1;
Block1.Cdag = T1' * Block1.Cdag * T1;
Block1.N = T1' * Block1.N * T1;
Block1.I = T1' * Block1.I * T1;
%�ұߵ�BLOCK�Ĵ���
Psimatrix = reshape ( Psi , b1 , a1 );
RDM = Psimatrix * Psimatrix';
[ vector2 , eigenvalues ] = eig( RDM );
[ ~ , index ] = sort( diag ( eigenvalues ) , 'descend' );
vector2 = vector2( : , index );
numbers_to_keep = min( size ( vector2 , 1 ) , noftk );
T2 = vector2( : , 1 : numbers_to_keep );
Block2.basis_size = numbers_to_keep;
Block2.H  = T2' * Block2.H * T2;
Block2.C = T2' * Block2.C * T2;
Block2.Cdag = T2' * Block2.Cdag * T2;
Block2.N = T2' * Block2.N * T2;
Block2.I = T2' * Block2.I * T2;
end
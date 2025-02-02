function [j1Hat,j2Hat,x_j] = estimative_j_gauss(x_j, g1, g2, step_batch, ordem)
    
    persistent firstRun_j

    Jac = zeros(step_batch,4);
    E_j = zeros(step_batch,1);
    
    j1Hat_ant = [cos(x_j(1))*cos(x_j(2)),cos(x_j(1))*sin(x_j(2)),sin(x_j(1))]';
    j2Hat_ant = [cos(x_j(3))*cos(x_j(4)),cos(x_j(3))*sin(x_j(4)),sin(x_j(3))]';

    for l = 1:ordem
        % J1 e J2 - Seel 2014 - Eq. 4 e 5
        j1Hat = [cos(x_j(1))*cos(x_j(2)),cos(x_j(1))*sin(x_j(2)),sin(x_j(1))]';
        j2Hat = [cos(x_j(3))*cos(x_j(4)),cos(x_j(3))*sin(x_j(4)),sin(x_j(3))]';

        for j = 1:step_batch
            % Auxiliar para calcular de/dj - Seel 2012 - Eq. 2
            normJ1 = (norm( cross(g1(j,:),j1Hat)));
            normJ2 = (norm(cross(g2(j,:),j2Hat)));

            % Derivadas do Erro em rela��o J1 e J2 - Seel 2012 - Eq. 2
            dj1 = (cross((cross(g1(j,:),j1Hat)),g1(j,:)))/normJ1;
            dj2 = -(cross((cross(g2(j,:),j2Hat)),g2(j,:)))/normJ2;

            % Derivadas de J1 e J2 em rela��o a X
            % X � o vator com os valores de phi1,phi2,theta1 e theta2
            dj1dx = [-sin(x_j(1))*cos(x_j(2)) -cos(x_j(1))*sin(x_j(2)) 0 0
                     -sin(x_j(1))*sin(x_j(2))  cos(x_j(1))*cos(x_j(2)) 0 0
                      cos(x_j(1))              0                       0 0];
            dj2dx = [0 0 -sin(x_j(3))*cos(x_j(4)) -cos(x_j(3))*sin(x_j(4))
                     0 0 -sin(x_j(3))*sin(x_j(4))  cos(x_j(3))*cos(x_j(4))
                     0 0  cos(x_j(3))              0];

           % Regra da cadeia derivada do Erro em rela��o a X
           Jac(j,:) = (dj1*dj1dx + dj2*dj2dx);   

           % Calculo do erro

           E_j(j) = (norm(cross(g1(j,:),j1Hat))-norm(cross(g2(j,:),j2Hat)));
        end 
        % Moore-Penrose-pseudoinverse
        % Jac^-1 = Jac'(Jac*Jac')^-1    
        dx_j = pinv(Jac)*(E_j);
        % Atualizacao dos valores
        x_j = x_j - dx_j;
    end
    
    j1Hat = [cos(x_j(1))*cos(x_j(2)),cos(x_j(1))*sin(x_j(2)),sin(x_j(1))]';
    j2Hat = [cos(x_j(3))*cos(x_j(4)),cos(x_j(3))*sin(x_j(4)),sin(x_j(3))]';
    
    if isempty(firstRun_j)
        firstRun_j = 1;
    else
        for j = 1:step_batch
            E_j_ant(j) = (norm(cross(g1(j,:),j1Hat_ant))-norm(cross(g2(j,:),j2Hat_ant)));
        end
        rmse = sqrt(sum(E_j.^2)/length(E_j));
        rmse_ant = sqrt(sum(E_j_ant.^2)/length(E_j_ant));
        if rmse_ant <= rmse
            j1Hat = j1Hat_ant;
            j2Hat = j2Hat_ant;
        end
        
    end
    x_j = inclinacao_orientacao(x_j);
    j1Hat = [cos(x_j(1))*cos(x_j(2)),cos(x_j(1))*sin(x_j(2)),sin(x_j(1))]';
    j2Hat = [cos(x_j(3))*cos(x_j(4)),cos(x_j(3))*sin(x_j(4)),sin(x_j(3))]';
end
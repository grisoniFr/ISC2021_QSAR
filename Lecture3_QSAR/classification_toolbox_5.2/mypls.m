function [T,P,W,U,Q,B,ssq,Ro,Rv,Lo,Lv] = mypls(X,Y,nF,options)
% function [T,P,W,U,Q,B,ssq,Ro,Rv,Lo,Lv] = mypls(X,Y,nF,options)
% 020828 FvdB
% Partial Least Squares regression bilinear factor model.
%
% in :
% X (objects x m-variables) data-block
% Y (objects x p-variables) data-block
% nF (1 x 1) number of factors (latent variables)
% options (1 x 2) tolerance for convergence and maximum number of iterations (default 1e-8 and 2000)
%
% out :
% T (objects x nF) X-scores
% P (m-var x nF) X-loadings
% W (m-var x nF) X-weights
% U (objects x nF) Y-scores
% Q (p-var x nF) Y-weights
% B (m-var x nF) regression vectors
% ssq (nF x 2) cumulative sum of squares X and Y
% Ro (objects x nF) object residuals
% Rv (variables x nF) variable residuals
% Lo (objects x nF) object leverages
% Lv (variables x nF) variable leverages       

if nargin < 3
    help mypls
    return
elseif nargin == 3
    options = [1e-8 2000];
end

[nX,mX] = size(X);
[nY,pY] = size(Y);
if nF > nX
    s = ['ERROR: number of objects (' int2str(nX) ') is to small to compute ' int2str(nF) ' LV''s'];
    error(s)
end
if nF > mX
    s = ['ERROR: number of variables (' int2str(mX) ') is to small to compute ' int2str(nF) ' LV''s'];
    error(s)
end
if nX ~= nY
    s = ['ERROR: number of objects in X (' int2str(nX) ') and Y (' int2str(nY) ') must be the same'];
    error(s)
end
MV = sum(sum(isnan(X))) + sum(sum(isnan(Y)));
if MV
    Xmv = sparse(isnan(X));
    X(Xmv) = 0;
    Ymv = sparse(isnan(Y));
    Y(Ymv) = 0;
end

U = zeros(nX,nF);
W = zeros(mX,nF);
T = zeros(nX,nF);
Q = zeros(pY,nF);
P = zeros(mX,nF);
B = zeros(mX,nF*pY);
ssq = zeros(nF,2);
ssqX = sum(sum(X.^2));
ssqY = sum(sum(Y.^2));
Ro = zeros(nX,nF);
Rv = zeros(mX,nF);
Lo = zeros(nX,nF);
Lv = zeros(mX,nF);

for a=1:nF
    iter = 0;
    [aa,aaa] = max(sum(Y.^2,1));
    U(:,a) = Y(:,aaa);
    [aa,aaa] = max(sum(X.^2,1));
    T(:,a) = X(:,aaa);
    t_old = T(:,a)*100;
    if MV
        while (sum((t_old - T(:,a)).^2)/sum(t_old.^2) > options(1)) & (iter < options(2))
            iter = iter + 1;
            t_old = T(:,a);
            W(:,a) = X'*U(:,a);
            for aa=1:mX
                c = (U(~Xmv(:,aa),a)'*U(~Xmv(:,aa),a));
                if (abs(c) > eps)
                    W(aa,a) = W(aa,a)/c;
                end
            end
            W(:,a) = W(:,a)/norm(W(:,a));
            T(:,a) = X*W(:,a);
            for aa=1:nX
                c = (W(~Xmv(aa,:),a)'*W(~Xmv(aa,:),a));
                if (abs(c) > eps)
                    T(aa,a) = T(aa,a)/c;
                end
            end
            Q(:,a) = Y'*T(:,a);
            for aa=1:pY
                c = (T(~Ymv(:,aa),a)'*T(~Ymv(:,aa),a));
                if (abs(c) > eps)
                    Q(aa,a) = Q(aa,a)/c;
                end
            end
            U(:,a) = Y*Q(:,a);
            for aa=1:nX
                c = (Q(~Ymv(aa,:),a)'*Q(~Ymv(aa,:),a));
                if (abs(c) > eps)
                    U(aa,a) = U(aa,a)/c;
                end
            end
        end
        P(:,a) = X'*T(:,a);
        for aa=1:mX
            c = (T(~Xmv(:,aa),a)'*T(~Xmv(:,aa),a));
            if (abs(c) > eps)
                P(aa,a) = P(aa,a)/c;
            end
        end
    else
        while (sum((t_old - T(:,a)).^2)/sum(t_old.^2) > options(1)) & (iter < options(2))
            iter = iter + 1;
            t_old = T(:,a);
            W(:,a) = X'*U(:,a)/(U(:,a)'*U(:,a));
            W(:,a) = W(:,a)/norm(W(:,a));
            T(:,a) = X*W(:,a)/(W(:,a)'*W(:,a));
            Q(:,a) = Y'*T(:,a)/(T(:,a)'*T(:,a));
            U(:,a) = Y*Q(:,a)/(Q(:,a)'*Q(:,a));
        end
        P(:,a) = X'*T(:,a)/(T(:,a)'*T(:,a));
    end
    if iter == options(2)
        s = ['WARNING: maximum number of iterations (' num2str(options(2)) ') reached before convergence'];
        disp(s)
    end
    B(:,(a-1)*pY+1:(a-1)*pY+pY) = W(:,1:a)*inv(P(:,1:a)'*W(:,1:a))*Q(:,1:a)';
    X = X - T(:,a)*P(:,a)';
    Y = Y - T(:,a)*Q(:,a)';
    if MV
        X(Xmv) = 0;
        Y(Ymv) = 0;
    end
    ssq(a,1) = (ssqX - sum(sum(X.^2)))/ssqX;
    ssq(a,2) = (ssqY - sum(sum(Y.^2)))/ssqY;
    Ro(:,a) = sqrt(sum(X.^2,2));
    Rv(:,a) = sqrt(sum(X.^2,1))';
    Lo(:,a) = diag(T(:,1:a)*pinv(T(:,1:a)'*T(:,1:a))*T(:,1:a)');
    Lv(:,a) = diag(P(:,1:a)*P(:,1:a)');
end
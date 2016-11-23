function M=RandOrthMat3(n, seed, dist, tol)
% M = RANDORTHMAT(n)
% generates a random n x n orthogonal real matrix.
%
% M = RANDORTHMAT(n,tol)
% explicitly specifies a thresh value that measures linear dependence
% of a newly formed column with the existing columns. Defaults to 1e-6.
%
% In this version the generated matrix distribution *is* uniform over the manifold
% O(n) w.r.t. the induced R^(n^2) Lebesgue measure, at a slight computational
% overhead (randn + normalization, as opposed to rand ).
%
% (c) Ofek Shilon , 2006.
% 
% This file is a modification of RandOrthMat() by Ofek Shilon
% edited 2014-11-18 by Torben Wendt:
%
% additional input parameters:
%	seed		random seed; if empty, the seed sum(100*clock) is used
%	dist		propability distribution; 0: rand, 1: randn (optional, default: 0)


if nargin < 4
	tol=1e-6;
	if nargin < 3
		dist = 0;
		if nargin < 2
			seed = [];
		end
	end
end

if isempty(seed)
	seed = sum(100*clock);
end

init_rng(seed);

M = zeros(n);

% gram-schmidt on random column vectors
if dist == 1
	vi = randn([n,1]);
else
	vi = rand([n,1])*2-1;
end
% the n-dimensional normal distribution has spherical symmetry, which implies
% that after normalization the drawn vectors would be uniformly distributed on the
% n-dimensional unit sphere.

M(:,1) = vi ./ norm(vi);

for i=2:n
	nrm = 0;
	while nrm<tol
		
		if dist == 1
			vi = randn([n,1]);
		else
			vi = rand([n,1])*2-1;
		end
		
		
		vi = vi -  M(:,1:i-1)  * ( M(:,1:i-1).' * vi )  ;
		nrm = norm(vi);
	end
	M(:,i) = vi ./ nrm;
	
end %i

end  % RandOrthMat


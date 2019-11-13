function hyp = sample_separate_prior(priors, parms)
    n = size(priors, 1);
    hyps = cell(n, 1);
    
    for i=1:n
        hyps{i} = sample_prior(priors{i});
    end
    
    hyp = hyps{1};
    hyp.mean = zeros(2*n+parms.nfirm,1);
%     hyp.cov = zeros(2*n+parms.nfirm,1);
%     hyp.lik = zeros(n,1);
    for i=1:n
        hyp.mean(i) = hyps{i}.mean(1);
        hyp.mean(i+n) = hyps{i}.mean(2);
%         hyp.cov(i) = hyps{i}.cov(1);
%         hyp.cov(i+n) = hyps{i}.cov(2);
%         hyp.lik(i) = hyps{i}.lik;
    end
    
    for i=1:parms.nfirm
       hyp.mean(i+2*n) = hyps{1}.mean(2+i);
%        hyp.cov(i+2*n) = hyps{1}.cov(2+i);
    end
end
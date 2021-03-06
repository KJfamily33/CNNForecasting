function [meanfunc, covfunc, likfunc, inffunc, prior] = model(parms)
% 
%     % define mean function and kernel
%     meanmask = [true, false, false, false, false];
%     covmask = [false, true, true, false, false];
%     firmbiasmask = [false, false, false, true, true];
%     firmmask = [false, false, false, true, false];
%     mc = {@meanConst};
%     ml = {@meanLinear};
%     md = {@meanDiscrete, parms.nfirm};
%     mp = {@meanDiscretePartisian, parms.nfirm};
%     mb = {@logsqrtbinom};
%     mml = {@meanMask, meanmask, ml};
%     mmc = {@meanMask, meanmask, mc};
%     % mmd = {@meanMask, firmmask, md};
%     mmp = {@meanMask, firmbiasmask, mp};
%     meanfunc = {@meanSum, {mml, mmc, mmp}};
%     
%     % try no firm
%     meanfunc = {@meanSum, {mml, mmc}};
%     cm = {@covMaterniso, 3};
%     cdb = {@covDiag, mb};
%     cdf = {@covDiag, md};
%     cmf = {@covMask, {firmmask, cdf}};
%     cmd = {@covMask, {covmask, cdb}};
%     cmm = {@covMask, {meanmask, cm}};
%     covfunc = {@covSum, {cmm, cmd, cmf}};
%     
%     % try no firm
%     covfunc = {@covSum, {cmm, cmd}};
%     likfunc = @likGauss;
%     inffunc = @infExact;
% 
%     % setting hyperpriors
%     % using linear model as hyperpriors for mean prior
%     
%     % priors = cell(parms.ncandidates, 1);
%     % prior.mean = cell(parms.ncandidates, 1);
%     % for k=1:parms.ncandidates
%     % prior.mean = cell(2*parms.ncandidates + parms.nfirm,1);
%         mu_ml = 0.0; sigma_ml = 0.002;
%         % mu_mc = parms.mc(k); sigma_mc = 0.05;
%         mu_mc = 0.5; sigma_mc = 0.1;
%         pg_ml = {@priorGauss, mu_ml, sigma_ml^2};
%         pg_mc = {@priorGauss, mu_mc, sigma_mc^2};
%         prior.mean = {pg_ml, pg_mc};
% 
%         pbs = [-0.0065
%         0.0014
%        -0.0005
%         0.0039
%        -0.0040
%         0.0009
%         0.0006
%         0.0120
%         0.0057
%        -0.0082
%        -0.0023
%        -0.0098
%         0.0025
%         0.0043
%         0.0004
%        -0.0043
%        -0.0029
%        -0.0028
%        -0.0005
%        -0.0018
%        -0.0118
%         0.0029
%         0.0021
%        -0.0001
%        -0.0041
%        -0.0004
%        -0.0028
%         0.0025
%        -0.0011
%         0.0002
%         0.0077
%        -0.0056
%         0.0001
%         0.0013
%        -0.0082
%         0.0062
%        -0.0002
%        -0.0021
%         0.0058
%        -0.0064
%        -0.0026];
%        
%    % try no firm
% %         for i=1:parms.nfirm
% %             mu_md = pbs(i); sigma_md = 0.05;
% %             pg_md = {@priorGauss, mu_md, sigma_md^2};
% %             prior.mean{2+i} = pg_md;
% %         end 
%     % end
% 
%         % length scale: 30 days in average,
%         % no less than 10 days, no more than 90 days
%         % output scale: binomial variance
%         % prior.mean = cell(2*parms.ncandidates + parms.nfirm,1);
%         mu_ls = log(30); sigma_ls = log(90/30)/2;
%         mu_os = log(1/40); sigma_os = log(2);
%         pg_ls = {@priorGauss, mu_ls, sigma_ls^2};
%         pg_os = {@priorGauss, mu_os, sigma_os^2};
%         prior.cov = {pg_ls, pg_os};
% 
%         % try no firm
% %         for i=1:parms.nfirm
% %             mu_vf = log(0.01); sigma_vf = log(3);
% %             pg_vf = {@priorGauss, mu_vf, sigma_vf^2};
% %             prior.cov{2+i} = pg_vf;
% %         end
% 
%         % total variance: CI for unknown sigma (chi-squared)
%         mu_lik = log(0.04); sigma_lik = log(2);
%         pg_lik = {@priorGauss, mu_lik, sigma_lik^2};
%         prior.lik = {pg_lik};
%         
% %         priors{k} = prior;
% %     end


       meanmask = [true, false, false, false, false];
    covmask = [false, true, true, false, false];
    mc = {@meanConst};
    ml = {@meanLinear};
    mml = {@meanMask, meanmask, ml};
    mmc = {@meanMask, meanmask, mc};

    % try no firm
    meanfunc = {@meanSum, {mml, mmc}};
    cm = {@covMaterniso, 3};
    mb = {@logsqrtbinom};
    cdb = {@covDiag, mb};
    cmd = {@covMask, {covmask, cdb}};
    cmm = {@covMask, {meanmask, cm}};

    cs = {@covLINiso};
    ci = {@covConst};
    cms = {@covMask, {meanmask, cs}};

    % try no firm
    covfunc = {@covSum, {cmm, cmd, cms, ci}};
    likfunc = @likGauss;
    inffunc = @infExact;

    mu_ml = 0.0; sigma_ml = 0.002;
    mu_mc = 0.5; sigma_mc = 0.1;
    pc_ml = {@priorClamped};
    pc_mc = {@priorClamped};
    prior.mean = {pc_ml, pc_mc};


    mu_ls = log(30); sigma_ls = log(90/30)/2;
    mu_os = log(1/40); sigma_os = log(2);
    pg_ls = {@priorGauss, mu_ls, sigma_ls^2};
    pg_os = {@priorGauss, mu_os, sigma_os^2};

    pg_ml = {@priorClamped};
    pg_mc = {@priorClamped};

    prior.cov = {pg_ls, pg_os, pg_ml, pg_mc};

    mu_lik = log(0.03); sigma_lik = log(2);
    pg_lik = {@priorGauss, mu_lik, sigma_lik^2};
    prior.lik = {pg_lik};
end

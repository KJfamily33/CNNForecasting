% CNN Forecasting generic model
addpath("/Users/yahoo/Documents/WashU/CSE515T/Code/gpml-matlab-v3.6-2015-07-07");
addpath("/Users/yahoo/Documents/WashU/CSE515T/Code/Gaussian Process");
addpath("/Users/yahoo/Documents/WashU/CSE515T/Code/Gaussian Process/utilities");
startup;

% reading race data from all years and states
CNNdata = readData("CNNdata1992to2018.csv");
CNNdata = indexPollster(CNNdata, 50, "Gaussian Process/CNNdata1992to2018idx.csv");
plot_path = "/Users/yahoo/Documents/WashU/CSE515T/Code/Gaussian Process/plots/genericwith2018";

parms.mode = true;
% pollsters having less than threshold of polls will be indexed by nfirm
parms.nfirm = max(CNNdata.pollsteridx);
parms.days = min(CNNdata.daysLeft);
years = unique(CNNdata.cycle);
states = unique(CNNdata.state);

% build training cell arrays
xs = cell(1000,1);
ys = cell(1000,1);
raceinfos = cell(1000,1);
counter = 1;
candidateid = 1;
for i = 1:numel(years)
   for j = 1:numel(states)
      [x, y, candidateNames, v, candidateid] = getRaceCandidateData(CNNdata, years(i), states(j), candidateid);
      if isempty(x), continue; end
      for k = 1:numel(x)
         xs{counter} = x{k};
         ys{counter} = y{k};
         raceinfos{counter} = {years(i), states(j), candidateNames(k), v(k)};
         counter = counter + 1;
      end
   end
end

counter = counter - 1;
candidateid = candidateid - 1;
xs = xs(1:counter);
ys = ys(1:counter);
raceinfos = raceinfos(1:counter);
parms.ncandidates = counter;
parms.mc = zeros(counter,1);
parms.sl = zeros(counter,1);
parms.mp = zeros(counter,1);

for i=1:counter
   parms.mc(i) = mean(xs{i}(:,2));
   parms.sl(i) = 0.05 / abs(min(xs{i}(:,1)));
end

[meanfunc, covfunc, likfunc, inffunc, priors] = model(parms);
im = {@infPrior, inffunc, priors};
par = {meanfunc,covfunc,likfunc, xs, ys};

% training
disp("start training...");
bestnlZ = 0;

% for i=1:1
%     % hyp = sample_prior(prior);
%     hyp = sample_separate_prior(priors, parms);
%     hyp = feval(mfun, hyp,  @gp_likelihood_independent, p, im, par{:});
%     [nlZ, ~] = gp_likelihood_independent(hyp, im, par{:});
%     if nlZ < bestnlZ, bestnlZ = nlZ; besthyp = hyp; end
% end

iter = 10;
hyp = sample_separate_prior(priors, parms);
hyp = fixLearn(hyp, im, par{:}, iter);

% for i=1:1
%     % hyp = sample_prior(prior);
%     for it=1:iter
%         hyp = feval(mfun, hyp,  @fixLearn, p, im, par{:}, sharedflag);
%         hyp = feval(mfun, hyp,  @fixLearn, p, im, par{:}, unsharedflag);
%     end
%     [nlZ, ~] = gp_likelihood_independent(hyp, im, par{:});
%     if nlZ < bestnlZ, bestnlZ = nlZ; besthyp = hyp; end
% end

% iterate cycle/state race
allRaces = struct;
nz = 200;
for i = 1:numel(xs)
    id = xs{i}(1,6);
    republican = xs{i}(1,5);
    xstar = [linspace(xs{i}(1,1)-10,0,nz).',zeros(1,nz)',ones(1,nz)',...
        parms.nfirm*ones(1,nz)',republican*ones(1,nz)', id*republican*ones(1,nz)'];
    
    hyp = full2one(besthyp, id, counter, parms.nfirm);
    im = {@infPrior, inffunc, priors{id}};
    [~, ~, fmu, fs2] = gp(hyp, im, meanfunc, covfunc, likfunc, xs{i}, ys{i}, xstar);
    fig = plot_posterior(fmu, fs2, xs{i}(:,1), ys{i}, xstar(:,1), i);
    predPoll = fmu(end);
    year = raceinfos{i}{1};
    state = raceinfos{i}{2}{1};
    candidateName = raceinfos{i}{3};
    trueVote = raceinfos{i}{4};
    plot_title = year + " " + state + " " + candidateName;
    title(plot_title);
    yearFolder = fullfile(plot_path, num2str(year));
    stateFolder = fullfile(yearFolder, state);
    if ~exist(plot_path, 'dir')
        mkdir(plot_path);
    end
    if ~exist(yearFolder, 'dir')
        mkdir(yearFolder);
    end
    if ~exist(stateFolder, 'dir')
        mkdir(stateFolder);
    end
    filename = fullfile(stateFolder, plot_title + ".jpg");
    saveas(fig, filename);
    close;
    disp(plot_title + " predicted winning rate: " + predPoll);
    disp(plot_title + " actual votes won: " + trueVote + newline);
    
    fn = char(state+""+year);
    fn = fn(~isspace(fn));
    if ~isfield(allRaces, fn)
        allRaces.(fn) = [predPoll, trueVote];
    else
        allRaces.(fn) = [allRaces.(fn), predPoll, trueVote];
    end
end

N = 0; nsuc = 0;

fn = fieldnames(allRaces);
for i=1:numel(fn)
    pvs = allRaces.(fn{i});
    ps = pvs(1:2:end);
    vs = pvs(2:2:end);
    [~, p_idx] = max(ps);
    [~, t_idx] = max(vs);
    if p_idx == t_idx
       nsuc = nsuc + 1;
    end
    N = N + 1;
end

disp(N + " races run.");
disp(nsuc + " successful predictions.");
disp("Prediction rate: " + nsuc/N);

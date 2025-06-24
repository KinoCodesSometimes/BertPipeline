function mad = F_Triangulation(mad)
    
    % Storage and params
        mad.Triang.Camera = {1, mad.Trials}; % File name per trial
        x2_full = []; % Concatenated animal data
        x3ml = zeros(3, length(mad.Mouse.LandName), ...
            mad.Trials*mad.TrialLen);
        sigmaml = zeros(length(mad.Mouse.LandName), ...
            mad.Trials*mad.TrialLen);
        lhood_full = [];
        options = [];

    % Correcting the P matrices - No clue why they're not generated like
    % this to start off with but oh well...
    for c_ix = 1:mad.NCams
        mad.PCorr{c_ix} = mad.P{c_ix}([2, 1, 3], :);
    end


    %% Identifying and organising all the folders
        files = string({dir(mad.DLCFolder + "\*.csv").name});
    
    % Organising the CSVs
        for t_ix = 1:mad.Trials
            mad.Triang.Camera{t_ix} = mad.DLCFolder + "\" + ...
                files(~cellfun(@isempty, ...
                regexp(files, ['trial_' num2str(t_ix) '_'],'match')));
        end

    %% Triangulating
    mad.Mouse.Triangulated = [];
    c_ = 1;
    for t_ix = 1:mad.Trials % Trial
        t_ix

        % mad.Mouse.Triangulated = cat(3, mad.Mouse.Triangulated, ...
        %     triangulate_DLC(mad.Triang.Camera{t_ix}, mad.P));     % JRPP - No that's the old version....
   
        % Reading DLC data from .csvs
        for c_ix = 1:mad.NCams % Camera
            c_ix
            m = readmatrix(mad.Triang.Camera{t_ix}{c_ix});
            [Nrow, Ncol] = size(m);
            N_Land = (Ncol - 1)/3;


            % Deriving coordinates and likelyhoods
                x2(c_ix,:,:,1) = m(:,2:3:end); %#ok<*AGROW>
                x2(c_ix,:,:,2) = m(:,3:3:end); 
                lhood(c_ix,:,:) = m(:,4:3:end);
        end

        % Concatenating
        x2_full = cat(2,x2_full,x2);
        lhood_full = cat(2, lhood_full, lhood);
        for fr_ix = 1:Nrow
            x2tmp = squeeze(x2(:, fr_ix, :, :));
            x2tmp = permute(x2tmp, [3 2 1]);
            lhoodtmp = squeeze(lhood(:, fr_ix, :))';
            %%Triangulate by Maximum Likelihood
            % Serves to generate a sample set of 3D landmark estimates, from which the
            % prior distribution of these landmarks can be estimated.
            [x3ml_temp,sigmaml_temp] = ...
                triangulate_map1(x2tmp, lhoodtmp, mad.PCorr, ...
                [], [], options);
            x3ml(:, :, (c_-1)*mad.TrialLen + fr_ix) = x3ml_temp;
            sigmaml(:, (c_-1)*mad.TrialLen + fr_ix) = sigmaml_temp;
        end
        c_ = c_ + 1;
    end
    % save("READSECT", "x2_full", "x3ml", "sigmaml", "lhood_full", "x2tmp") % Have neve4r seen this being saved anywhere... Why did I even do this?

    %% Prior parameter estimation
        options = [];
        options.doplot = true;
        [priormiu3cat,priorsigma3cat] = triangulate_prior(x3ml,options);

    %% Triangulation by Maximum A Posteriori (MAP):
        Nf = size(x3ml, 3);
        options = [];
        x3map = zeros(3,N_Land,Nf);
        mad.Triang.SigmaMap = zeros(N_Land,Nf);
        wb = waitbar(0, "Triangulating");
        for fr_ix = 1:Nf % Frame
            waitbar(fr_ix/Nf)
            x2tmp = squeeze(x2_full(:,fr_ix,:,:));
            x2tmp = permute(x2tmp,[3 2 1]);
            lhoodtmp = squeeze(lhood_full(:,fr_ix,:))';
            [x3map(:,:,fr_ix), mad.Triang.SigmaMap(:,fr_ix)] = ...
                triangulate_map1(x2tmp, lhoodtmp, mad.PCorr, ...
                priormiu3cat, priorsigma3cat, options);
        end
        close(wb)
        mad.Triang.Concat = permute(x3map,[2 1 3]);
        mad.Prog.MouseTrian = datetime("now");

    %% Removing first frame and refining the landmarks
        [mad.Triangulated, mad.Sigma] = ...
            prep_3D(mad.Triang.Concat, mad.Triang.SigmaMap, mad.Trials);
        mad.Mouse.Refined = refine_triP_output(mad.Triangulated);

    %% Excluding the implant
    if mad.RunParams.ExcludeImplant
        mad = F_ExcludeLandmarks(mad, "Implant");
    end
     
    % %% Storing
    save(mad.RunParams.SaveLoc, "mad")

end

